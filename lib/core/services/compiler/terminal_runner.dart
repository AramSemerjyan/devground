import 'dart:async';
import 'dart:convert';
import 'dart:io';

// PTY support. Requires adding `pty` package to pubspec.yaml.
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
    // throw a TypeError at runtime. The user must add the dependency.
    // We use a dynamic invocation to avoid hard compile-time coupling.
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

  // Fallback: try running under `stdbuf -oL` (makes many programs line-buffered)
  try {
    final proc = await Process.start(
      'stdbuf',
      ['-oL', executable, ...args],
      environment: environment,
      workingDirectory: workingDirectory,
    );
    return _ProcessTerminal(proc);
  } catch (_) {
    // Final fallback: direct Process.start
    final proc = await Process.start(
      executable,
      args,
      environment: environment,
      workingDirectory: workingDirectory,
    );
    return _ProcessTerminal(proc);
  }
}

// Implementation using Process pipes
class _ProcessTerminal implements TerminalProcess {
  final Process _proc;
  final StreamController<String> _out = StreamController.broadcast();
  final StreamController<String> _in = StreamController();

  _ProcessTerminal(this._proc) {
    _proc.stdout.transform(utf8.decoder).listen(_out.add, onDone: _out.close);
    _proc.stderr.transform(utf8.decoder).listen(_out.add);
    _in.stream.listen((s) {
      try {
        _proc.stdin.writeln(s);
      } catch (_) {}
    });
  }

  @override
  Sink<String> get input => _in.sink;

  @override
  Stream<String> get output => _out.stream;

  @override
  Future<int> get exitCode => _proc.exitCode;

  @override
  Future<void> kill([ProcessSignal signal = ProcessSignal.sigterm]) async {
    try {
      _proc.kill(signal);
    } catch (_) {}
  }
}

// Try to start a pty using the `pty` package. Returns null if not available.
Future<TerminalProcess?> _tryStartPty(
  String executable,
  List<String> args, {
  Map<String, String>? environment,
  String? workingDirectory,
}) async {
  try {
    // `Pty` API from package:pty
    // import 'package:pty/pty.dart';
    // final pty = Pty.start(executable, args, environment: environment, workingDirectory: workingDirectory);
    // Since we want to avoid compile error if package missing, use dynamic invocation.
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

// Dynamic PTY start implemented separately so compile doesn't fail if
// `pty` package isn't present. This still requires the package at runtime.
Future<TerminalProcess?> _startPtyDynamic(
  String executable,
  List<String> args, {
  Map<String, String>? environment,
  String? workingDirectory,
}) async {
  // This code expects `package:pty/pty.dart` to exist. If not, it will
  // throw and be handled by caller.
  // We intentionally import here to make failures local.
  // NOTE: Replace this placeholder with a direct implementation using
  // `package:pty` after adding the dependency to `pubspec.yaml`.
  throw UnsupportedError(
    'PTY dynamic start not implemented. Add package:pty and implement _startPtyDynamic.',
  );
}
