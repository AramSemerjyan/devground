import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';
import '../terminal_runner.dart';

class CPPCompiler extends Compiler {
  final String path;

  CPPCompiler(this.path);

  final uuid = const Uuid();

  @override
  Future<CompilerResult> formatCode(String code) async {
    try {
      // Simple formatting: add line breaks and indentation for nested tags
      // (You can use `html` package or prettier for more advanced formatting)
      final formatted = code.replaceAll(RegExp(r'>\s*<'), '>\n<');
      return CompilerResult.message(data: formatted);
    } catch (e) {
      return CompilerResult.error(error: e);
    }
  }

  bool _looksLikeStdin(String code) {
    final patterns = [
      'cin>>',
      'std::getline',
      'getline(',
      'scanf(',
      'readline',
    ];

    final lower = code.toLowerCase();
    for (final p in patterns) {
      if (lower.contains(p.toLowerCase())) return true;
    }
    return false;
  }

  @override
  Future<void> runCode(String code) async {
    try {
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final file = File('${tmpDir.path}/snippet_c_$id.cpp');
      await file.writeAsString(code);

      final cCompiler = path.isNotEmpty ? '$path/g++' : 'g++';

      final compileProc = await Process.start(cCompiler, [
        file.path,
        '-o',
        file.path,
      ]);

      final compileStdout = StringBuffer();
      final compileStderr = StringBuffer();

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
        resultStream.sink.add(
          CompilerResult.error(data: compileStderr.toString()),
        );
        return;
      }

      final tp = await runWithPty(file.path, []);

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

      final subOut = tp.output.listen((chunk) {
        outputSeen = true;
        inputWaitTimer?.cancel();
        resultStream.add(CompilerResult.message(data: chunk));
        if (looksLikeStdin) {
          resultStream.add(
            CompilerResult(
              status: CompilerResultStatus.waitingForInput,
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
        resultStream.add(
          CompilerResult.error(data: 'Process exited with code $rc'),
        );
      } else {
        resultStream.add(
          CompilerResult.done(data: 'Process exited with code 0'),
        );
      }
    } catch (e) {
      clearSubscriptions();
      resultStream.add(CompilerResult.error(error: e));
    }
  }
}
