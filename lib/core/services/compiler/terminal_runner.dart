import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_pty/flutter_pty.dart';

// PTY support. Requires adding `flutter_pty` package to pubspec.yaml.
// This file exposes a small abstraction `TerminalProcess` and a factory
// `runWithPty` which will try to start a real PTY and fall back to a
// regular `Process` (optionally via `stdbuf -oL`).

abstract class TerminalProcess {
  Stream<String> get output;
  Sink<String> get input;
  Future<int> get exitCode;
  Future<void> kill([ProcessSignal signal = ProcessSignal.sigterm]);
}

/// Try to start a PTY-backed terminal process. If PTY is unavailable,
/// falls back to starting a normal `Process` and wrapping stdout/stderr.
Future<TerminalProcess> runWithPty(
  String executable,
  List<String> args, {
  Map<String, String>? environment,
  String? workingDirectory,
}) async {
  // Try PTY first
  try {
    // Importing `pty` at runtime; if the package isn't available this will
    // throw and we will fallback to stdbuf/direct process.
    final ptyLib = await _tryStartPty(
      executable,
      args,
      environment: environment,
      workingDirectory: workingDirectory,
    );
    if (ptyLib != null) return ptyLib;
  } catch (_) {
    // ignore and fallback
  }

  // Try to use `stdbuf -oL` only when a usable `stdbuf` can be located.
  try {
    final stdbufPath = await _findStdBuf();
    if (stdbufPath != null) {
      try {
        final proc = await Process.start(
          stdbufPath,
          ['-oL', executable, ...args],
          environment: environment,
          workingDirectory: workingDirectory,
        );
        return _ProcessTerminal(proc);
      } catch (e) {
        try {
          stderr.writeln('Warning: failed to start stdbuf at $stdbufPath: $e');
        } catch (_) {}
        // fall through to direct Process.start below
      }
    }
  } catch (_) {
    // ignore and fall through to direct Process.start below
  }

  // Final fallback: direct Process.start
  final proc = await Process.start(
    executable,
    args,
    environment: environment,
    workingDirectory: workingDirectory,
  );
  return _ProcessTerminal(proc);
}

/// Try to locate a usable `stdbuf` executable and return its absolute path,
/// or `null` if none found. This probes `which` and a small set of common
/// locations (Homebrew prefixes + system paths).
Future<String?> _findStdBuf() async {
  if (Platform.isWindows) return null;

  try {
    final which = await Process.run('which', ['stdbuf']);
    if (which.exitCode == 0) {
      final out = (which.stdout as String).trim();
      if (out.isNotEmpty) return out.split('\n').first.trim();
    }
  } catch (_) {
    // ignore
  }

  final candidates = <String>[
    '/opt/homebrew/bin/stdbuf',
    '/usr/local/bin/stdbuf',
    '/usr/bin/stdbuf',
    '/bin/stdbuf',
  ];
  for (final p in candidates) {
    try {
      final f = File(p);
      if (await f.exists()) return p;
    } catch (_) {}
  }

  return null;
}

// Implementation using Process pipes
class _ProcessTerminal implements TerminalProcess {
  final Process _proc;
  final StreamController<String> _out = StreamController.broadcast();
  final StreamController<String> _in = StreamController();
  final Completer<void> _outputDone = Completer<void>();
  late final StreamSubscription<String> _stdinSub;
  late final StreamSubscription<String> _stdoutSub;
  late final StreamSubscription<String> _stderrSub;
  var _completedOutputPipes = 0;
  var _disposed = false;

  _ProcessTerminal(this._proc) {
    _stdoutSub = _proc.stdout
        .transform(utf8.decoder)
        .listen(_safeAddOutput, onDone: _onPipeDone, onError: _safeAddError);
    _stderrSub = _proc.stderr
        .transform(utf8.decoder)
        .listen(_safeAddOutput, onDone: _onPipeDone, onError: _safeAddError);
    _stdinSub = _in.stream.listen((s) {
      try {
        _proc.stdin.write(s);
      } catch (_) {}
    });
  }

  void _safeAddOutput(String data) {
    if (!_out.isClosed) {
      _out.add(data);
    }
  }

  void _safeAddError(Object error, [StackTrace? stackTrace]) {
    if (!_out.isClosed) {
      _out.addError(error, stackTrace);
    }
  }

  void _onPipeDone() {
    _completedOutputPipes++;
    if (_completedOutputPipes >= 2 && !_out.isClosed) {
      _out.close();
    }
    if (_completedOutputPipes >= 2 && !_outputDone.isCompleted) {
      _outputDone.complete();
    }
  }

  Future<void> _disposeStreams({required bool cancelOutputSubs}) async {
    if (_disposed) return;
    _disposed = true;

    try {
      await _stdinSub.cancel();
    } catch (_) {}
    if (cancelOutputSubs) {
      try {
        await _stdoutSub.cancel();
      } catch (_) {}
      try {
        await _stderrSub.cancel();
      } catch (_) {}
    }
    try {
      await _in.close();
    } catch (_) {}
    if (!_out.isClosed) {
      await _out.close();
    }
  }

  @override
  Sink<String> get input => _in.sink;

  @override
  Stream<String> get output => _out.stream;

  @override
  Future<int> get exitCode async {
    final code = await _proc.exitCode;
    try {
      await _outputDone.future;
    } catch (_) {}
    await _disposeStreams(cancelOutputSubs: false);
    return code;
  }

  @override
  Future<void> kill([ProcessSignal signal = ProcessSignal.sigterm]) async {
    try {
      _proc.kill(signal);
    } catch (_) {}
    await _disposeStreams(cancelOutputSubs: true);
  }
}

// Try to start a pty using the `flutter_pty` package. Returns null if not available.
Future<TerminalProcess?> _tryStartPty(
  String executable,
  List<String> args, {
  Map<String, String>? environment,
  String? workingDirectory,
}) async {
  try {
    final ptyLib = await _startPtyDynamic(
      executable,
      args,
      environment: environment,
      workingDirectory: workingDirectory,
    );
    return ptyLib;
  } catch (e) {
    return null;
  }
}

class _PtyTerminal implements TerminalProcess {
  final Pty _pty;
  final StreamController<String> _out = StreamController.broadcast();
  final StreamController<String> _in = StreamController();
  final Completer<void> _outputDone = Completer<void>();
  late final StreamSubscription<String> _stdinSub;
  late final StreamSubscription<Uint8List> _stdoutSub;
  var _disposed = false;

  _PtyTerminal(this._pty) {
    _stdoutSub = _pty.output.listen(
      (chunk) {
        if (!_out.isClosed) {
          _out.add(utf8.decode(chunk, allowMalformed: true));
        }
      },
      onDone: () {
        if (!_outputDone.isCompleted) {
          _outputDone.complete();
        }
        if (!_out.isClosed) {
          _out.close();
        }
      },
      onError: (error, stackTrace) {
        if (!_out.isClosed) {
          _out.addError(error, stackTrace);
        }
      },
    );

    _stdinSub = _in.stream.listen((text) {
      try {
        _pty.write(Uint8List.fromList(utf8.encode(text)));
      } catch (_) {}
    });
  }

  Future<void> _disposeStreams({required bool cancelOutputSub}) async {
    if (_disposed) return;
    _disposed = true;

    try {
      await _stdinSub.cancel();
    } catch (_) {}
    if (cancelOutputSub) {
      try {
        await _stdoutSub.cancel();
      } catch (_) {}
    }
    try {
      await _in.close();
    } catch (_) {}
    if (!_out.isClosed) {
      await _out.close();
    }
  }

  @override
  Sink<String> get input => _in.sink;

  @override
  Stream<String> get output => _out.stream;

  @override
  Future<int> get exitCode async {
    final code = await _pty.exitCode;
    try {
      await _outputDone.future;
    } catch (_) {}
    await _disposeStreams(cancelOutputSub: false);
    return code;
  }

  @override
  Future<void> kill([ProcessSignal signal = ProcessSignal.sigterm]) async {
    try {
      _pty.kill(signal);
    } catch (_) {}
    await _disposeStreams(cancelOutputSub: true);
  }
}

Future<TerminalProcess?> _startPtyDynamic(
  String executable,
  List<String> args, {
  Map<String, String>? environment,
  String? workingDirectory,
}) async {
  final pty = Pty.start(
    executable,
    arguments: args,
    environment: environment,
    workingDirectory: workingDirectory,
  );
  return _PtyTerminal(pty);
}
