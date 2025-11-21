import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';
import '../terminal_runner.dart';

class SwiftCompiler extends Compiler {
  final String path;

  SwiftCompiler(this.path);

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

    // // Swift has no built-in code formatter CLI for snippets easily.
    // // You can integrate `swift-format` if installed:
    // final tmpDir = await getTemporaryDirectory();
    // final file = File('${tmpDir.path}/snippet_fmt.swift');
    // await file.writeAsString(code);
    //
    // final swiftFormatExecutable = '$swiftPath-format'; // optional, only if installed
    // final proc = await Process.start(
    //   swiftFormatExecutable,
    //   [file.path],
    // );
    //
    // final exitCode = await proc.exitCode;
    // if (exitCode == 0) {
    //   return CompilerResult(data: await file.readAsString());
    // } else {
    //   return CompilerResult(hasError: true, data: exitCode);
    // }
  }

  @override
  Future<void> runCode(String code) async {
    try {
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final file = File('${tmpDir.path}/snippet_swift_$id.swift');
      await file.writeAsString(code);

      final cCompiler = path.isNotEmpty ? '$path/swift' : 'swift';

      final tp = await runWithPty(cCompiler, [file.path, file.path]);

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

  bool _looksLikeStdin(String code) {
    final patterns = [
      'readline(',
      'readline',
      'scanf(',
      'getchar(',
      'fgets(',
      'getline(',
    ];

    final lower = code.toLowerCase();
    for (final p in patterns) {
      if (lower.contains(p)) return true;
    }
    return false;
  }
}
