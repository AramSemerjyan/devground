import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';
import '../terminal_runner.dart';

class DartCompiler extends Compiler {
  String? _path;
  String? _resolvedDartExecutable;
  final uuid = const Uuid();

  @override
  Future<CompilerResult> formatCode(String code) async {
    final tmpDir = await getTemporaryDirectory();
    final id = uuid.v4();
    final file = File('${tmpDir.path}/snippet_fmt_$id.dart');
    final dartExecutable = await _resolveDartExecutable();
    await file.writeAsString(code);
    // run dart format -n does not write; run 'dart format' overwrites, but we want formatted output
    // Simplest: run `dart format <file>` then read file back.
    final proc = await Process.start(dartExecutable, ['format', file.path]);
    final exitCode = await proc.exitCode;
    if (exitCode == 0) {
      final formatted = await file.readAsString();
      return CompilerResult.message(data: formatted);
    } else {
      return CompilerResult.error(data: exitCode);
    }
  }

  @override
  Future<void> runCode(String code) async {
    final tmpDir = await getTemporaryDirectory();
    final id = uuid.v4();
    final file = File('${tmpDir.path}/snippet_$id.dart');
    await file.writeAsString(code);
    // Try to compile to an exe to capture compile errors.
    final compiledPath = '${tmpDir.path}/snippet_$id.bin';

    // Run: dart compile exe <file> -o <compiledPath>
    final dartExecutable = await _resolveDartExecutable();

    final compileProc = await Process.start(dartExecutable, [
      'compile',
      'exe',
      file.path,
      '-o',
      compiledPath,
    ]);
    // collect output
    final compileStdout = StringBuffer();
    final compileStderr = StringBuffer();
    compileProc.stdout
        .transform(utf8.decoder)
        .listen((d) => compileStdout.write(d));
    compileProc.stderr
        .transform(utf8.decoder)
        .listen((d) => compileStderr.write(d));
    final exitCode = await compileProc.exitCode;

    if (exitCode != 0) {
      if (compileStderr.isNotEmpty) {
        resultStream.add(
          CompilerResult.error(
            data: _extractDartError(compileStderr.toString()),
            message: 'Compilation failed',
            error: CompilerExecutionError('Compilation failed'),
          ),
        );
        return;
      }
    }

    // run the compiled binary
    try {
      final tp = await runWithPty(compiledPath, []);
      final looksLikeStdin = _looksLikeStdin(code);
      bool outputSeen = false;
      Timer? inputWaitTimer;

      void armTimer() {
        inputWaitTimer?.cancel();
        if (!looksLikeStdin) return;
        inputWaitTimer = Timer(const Duration(milliseconds: 250), () {
          if (!outputSeen) {
            resultStream.add(
              CompilerResult(
                status: CompilerResultStatus.waitingForInput,
                data: null,
              ),
            );
          }
        });
      }

      armTimer();

      final inputSub = inpSink.stream.listen((input) {
        try {
          tp.input.add(input);
        } catch (_) {}
        outputSeen = false;
        armTimer();
      });
      subscriptions.add(inputSub);

      final outputBuffer = StringBuffer();
      final subOut = tp.output.listen((chunk) {
        outputSeen = true;
        inputWaitTimer?.cancel();
        outputBuffer.write(chunk);
        resultStream.add(CompilerResult.message(data: chunk));

        if (looksLikeStdin) {
          resultStream.add(
            CompilerResult(
              status: CompilerResultStatus.waitingForInput,
              message: 'Process is waiting for input...',
              data: null,
            ),
          );
        }
      });
      subscriptions.add(subOut);

      final rc = await tp.exitCode;
      inputWaitTimer?.cancel();
      clearSubscriptions();

      if (rc != 0) {
        resultStream.sink.add(
          CompilerResult.error(
            data: outputBuffer.toString(),
            error: CompilerExecutionError('Process exited with code $rc'),
            message: 'Process exited with code $rc',
          ),
        );
      } else {
        resultStream.sink.add(
          CompilerResult.done(
            data: outputBuffer.toString(),
            message: 'Process exited with code 0',
          ),
        );
      }
    } catch (e, s) {
      clearSubscriptions();
      resultStream.sink.add(CompilerResult.error(error: e, stackTrace: s));
    }
  }

  @override
  Future<void> setPath(String? path) async {
    _path = path;
    _resolvedDartExecutable = null;
  }

  String _extractDartError(String stderr) {
    // Find the start: first colon after the temp file path
    final startIndex = stderr.indexOf(
      '.dart:',
    ); // e.g. ../../../snippet_*.dart:2:27:
    if (startIndex == -1) return stderr.trim();

    // Find the end: before "Error: AOT compilation failed"
    final endIndex = stderr.indexOf('Error: AOT compilation failed');
    if (endIndex == -1) return stderr.substring(startIndex).trim();

    // Extract substring
    final slice = stderr.substring(startIndex, endIndex).trim();

    // Remove the file path at the start (optional)
    final firstColon = slice.indexOf('Error:');
    if (firstColon != -1) {
      return slice.substring(firstColon).trim();
    }

    return slice;
  }

  Future<String> _resolveDartExecutable() async {
    final cached = _resolvedDartExecutable;
    if (cached != null && cached.isNotEmpty) return cached;

    final resolved = await resolveCompilerExecutable(
      configuredPath: _path,
      configuredCandidates: (path) => [path, '$path/bin/dart', '$path/dart'],
      whichCandidates: const ['dart'],
    );

    if (resolved == null) {
      throw CompilerSDKPathMissing();
    }

    _resolvedDartExecutable = resolved;
    return resolved;
  }

  bool _looksLikeStdin(String code) {
    final patterns = [
      'stdin.readlinesync',
      'stdin.readbytesync',
      'stdin.readbyte',
      'stdin.first',
      'stdin.listen',
      'stdin.transform',
    ];

    final lower = code.toLowerCase();
    for (final p in patterns) {
      if (lower.contains(p)) return true;
    }
    return false;
  }
}
