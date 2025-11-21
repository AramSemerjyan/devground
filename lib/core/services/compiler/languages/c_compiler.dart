import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';

class CCompiler extends Compiler {
  final String path;

  CCompiler(this.path) {
    inpSink.stream.listen((input) {
      currentProcess?.stdin.writeln(input);
    });
  }

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

  @override
  Future<void> runCode(String code) async {
    try {
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final file = File('${tmpDir.path}/snippet_c_$id.c');
      await file.writeAsString(code);

      final cCompiler = path.isNotEmpty ? '$path/gcc' : 'gcc';

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

      final runProc = await Process.start(file.path, []);
      currentProcess = runProc;

      // Heuristic: if source code contains stdin-style calls, we may need
      // to notify the UI that the process is waiting for input even if
      // the program doesn't flush a prompt to stdout.
      bool looksLikeStdin = _looksLikeStdin(code);

      bool outputSeen = false;
      Timer? inputWaitTimer;
      if (looksLikeStdin) {
        // If no output appears shortly, emit waiting-for-input so UI can
        // present an input field.
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

      runProc.stdout.transform(utf8.decoder).listen((chunk) {
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

      runProc.stderr.transform(utf8.decoder).listen((chunk) {
        outputSeen = true;
        inputWaitTimer?.cancel();
        resultStream.add(CompilerResult.message(data: chunk));
      });

      final rc = await runProc.exitCode;
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
      resultStream.add(CompilerResult.error(error: e));
    }
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
