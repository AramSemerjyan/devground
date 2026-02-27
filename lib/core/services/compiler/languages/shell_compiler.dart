import 'dart:async';
import 'dart:io';

import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';
import '../terminal_runner.dart';

class ShellCompiler extends Compiler {
  String? _path;
  String? _resolvedShellExecutable;
  final uuid = const Uuid();

  @override
  Future<void> runCode(String code) async {
    try {
      // Write code to a temporary file
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final tempFile = File('${tmpDir.path}/snippet_shell_$id.sh');
      await tempFile.writeAsString(code);

      final exe = await _resolveShellExecutable();

      // Ensure executable permissions
      if (Platform.isLinux || Platform.isMacOS) {
        await Process.run('chmod', ['+x', tempFile.path]);
      }

      final tp = await runWithPty(exe, [tempFile.path]);
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

      final output = outputBuffer.toString();

      if (rc != 0) {
        resultStream.sink.add(
          CompilerResult.error(
            data: output,
            error: CompilerExecutionError('Process exited with code $rc'),
            message: 'Process exited with code $rc',
          ),
        );
        return;
      }

      resultStream.sink.add(
        CompilerResult.done(
          data: output,
          message: 'Process exited with code 0',
        ),
      );
    } catch (e, s) {
      clearSubscriptions();
      resultStream.sink.add(CompilerResult.error(error: e, stackTrace: s));
    }
  }

  @override
  Future<CompilerResult> formatCode(String code) async {
    if (_path == null) {
      throw CompilerSDKPathMissing();
    }

    try {
      // Basic shell formatting:
      // - Trim trailing spaces
      // - Ensure Unix line endings
      final formatted = code
          .split('\n')
          .map((line) => line.trimRight())
          .join('\n')
          .replaceAll('\r\n', '\n');

      return CompilerResult.message(data: formatted);
    } catch (e) {
      return CompilerResult.error(error: e.toString());
    }
  }

  @override
  Future<void> setPath(String? path) async {
    _path = path;
    _resolvedShellExecutable = null;
  }

  Future<String> _resolveShellExecutable() async {
    final cached = _resolvedShellExecutable;
    if (cached != null && cached.isNotEmpty) return cached;

    final resolved = await resolveCompilerExecutable(
      configuredPath: _path,
      configuredCandidates: (path) => [path, '$path/bash'],
      whichCandidates: const ['bash'],
    );

    if (resolved == null) {
      throw CompilerSDKPathMissing();
    }

    _resolvedShellExecutable = resolved;
    return resolved;
  }

  bool _looksLikeStdin(String code) {
    final patterns = ['read ', 'select ', 'readarray', 'mapfile'];

    final lower = code.toLowerCase();
    for (final p in patterns) {
      if (lower.contains(p)) return true;
    }
    return false;
  }
}
