import 'dart:async';
import 'dart:io';

import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';
import '../terminal_runner.dart';

class PythonCompiler extends Compiler {
  String? _path;
  String? _resolvedPythonExecutable;
  final uuid = const Uuid();

  @override
  Future<CompilerResult> formatCode(String code) async {
    return CompilerResult.warning(
      message: 'No formatting available for Python.',
    );
  }

  @override
  Future<void> runCode(String code) async {
    try {
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final file = File('${tmpDir.path}/snippet_$id.py');
      await file.writeAsString(code);

      final pythonExecutable = await _resolvePythonExecutable();
      final tp = await runWithPty(pythonExecutable, [file.path]);
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

      final exitCode = await tp.exitCode;
      inputWaitTimer?.cancel();
      clearSubscriptions();

      if (exitCode != 0) {
        final output = outputBuffer.toString();
        resultStream.add(
          CompilerResult.error(
            data: output,
            error: CompilerExecutionError(_extractPythonError(output)),
            message: 'Process exited with code $exitCode',
          ),
        );
        return;
      }

      resultStream.add(
        CompilerResult.done(
          data: outputBuffer.toString(),
          message: 'Process exited with code 0',
        ),
      );
    } catch (e, s) {
      clearSubscriptions();
      resultStream.sink.add(CompilerResult.error(error: e, data: s.toString()));
    }
  }

  @override
  Future<void> setPath(String? path) async {
    _path = path;
    _resolvedPythonExecutable = null;
  }

  String _extractPythonError(String stderr) {
    // Simplify Python traceback by showing the last line (the actual error)
    final lines = stderr.trim().split('\n');
    if (lines.isEmpty) return stderr;
    final lastLine = lines.last;
    return '${lines.take(3).join('\n')}\n→ $lastLine';
  }

  bool _looksLikeStdin(String code) {
    final patterns = ['input(', 'sys.stdin', 'stdin.readline', 'readline('];

    final lower = code.toLowerCase();
    for (final p in patterns) {
      if (lower.contains(p)) return true;
    }
    return false;
  }

  Future<String> _resolvePythonExecutable() async {
    final cached = _resolvedPythonExecutable;
    if (cached != null && cached.isNotEmpty) return cached;

    final resolved = await resolveCompilerExecutable(
      configuredPath: _path,
      configuredCandidates: (path) => [path, '$path/python3'],
      whichCandidates: const ['python3'],
    );

    if (resolved == null) {
      throw CompilerSDKPathMissing();
    }

    _resolvedPythonExecutable = resolved;
    return resolved;
  }
}
