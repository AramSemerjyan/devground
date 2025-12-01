import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';
import '../terminal_runner.dart';

class CCompiler extends Compiler {
  final uuid = const Uuid();

  String? _path;

  @override
  Future<CompilerResult> formatCode(String code) async {
    if (_path == null) {
      throw CompilerSDKPathMissing();
    }

    try {
      // Simple formatting: add line breaks and indentation for nested tags
      // (You can use `html` package or prettier for more advanced formatting)
      final formatted = code.replaceAll(RegExp(r'>\s*<'), '>\n<');
      return CompilerResult.message(data: formatted);
    } catch (e) {
      return CompilerResult.error(error: e);
    }
  }

  @override
  Future<void> runCode(String code) async {
    if (_path == null) {
      throw CompilerSDKPathMissing();
    }

    try {
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final file = File('${tmpDir.path}/snippet_c_$id.c');
      await file.writeAsString(code);

      final cCompiler = _path!.isNotEmpty ? '$_path/gcc' : 'gcc';

      final compileProc = await Process.start(cCompiler, [
        file.path,
        '-o',
        file.path,
      ]);

      final compileStdout = StringBuffer();
      final compileStderr = StringBuffer();

      // Collect compiler output
      await compileProc.stdout
          .transform(utf8.decoder)
          .listen(compileStdout.write)
          .asFuture();
      await compileProc.stderr
          .transform(utf8.decoder)
          .listen(compileStderr.write)
          .asFuture();

      final exitCode = await compileProc.exitCode;
      if (exitCode != 0) {
        resultStream.add(CompilerResult.error(data: compileStderr.toString()));
        return;
      }

      final tp = await runWithPty(file.path, []);

      bool looksLikeStdin = _looksLikeStdin(code);

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

      StringBuffer outputBuffer = StringBuffer();

      final subOut = tp.output.listen((chunk) {
        outputSeen = true;
        inputWaitTimer?.cancel();
        resultStream.add(CompilerResult.message(data: chunk));

        outputBuffer.write(chunk);

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
      clearSubscriptions();
      inputWaitTimer?.cancel();

      if (rc != 0) {
        resultStream.add(
          CompilerResult.error(
            data: outputBuffer.toString(),
            error: CompilerExecutionError('Process exited with code $rc'),
            message: 'Process exited with code $rc',
          ),
        );
      } else {
        resultStream.add(
          CompilerResult.done(
            data: outputBuffer.toString(),
            message: 'Process exited with code 0',
          ),
        );
      }
    } catch (e, s) {
      clearSubscriptions();
      resultStream.add(CompilerResult.error(error: e, stackTrace: s));
    }
  }

  @override
  Future<void> setPath(String? path) async {
    _path = path;
  }

  bool _looksLikeStdin(String code) {
    final patterns = [
      'scanf(',
      'gets(',
      'fgets(',
      'getchar(',
      'getline(',
      'cin>>', // in case of mixed C/C++ code
      'std::getline',
    ];

    final lower = code.toLowerCase();
    for (final p in patterns) {
      if (lower.contains(p.toLowerCase())) return true;
    }
    return false;
  }
}
