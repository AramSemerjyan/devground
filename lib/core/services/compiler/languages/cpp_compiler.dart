import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';

class CPPCompiler extends Compiler {
  final String path;

  CPPCompiler(this.path) {
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

      compileProc.stdout.transform(utf8.decoder).listen(compileStdout.write);
      compileProc.stderr.transform(utf8.decoder).listen(compileStderr.write);

      final exitCode = await compileProc.exitCode;
      if (exitCode != 0) {
        resultStream.sink.add(CompilerResult.error(data: compileStderr.toString()));
      }

      final runProc = await Process.start(file.path, []);
      currentProcess = runProc;
      final runStdout = StringBuffer();
      final runStderr = StringBuffer();

      final shouldWaitForAnswer = code.contains('std::cin');

      runProc.stdout.transform(utf8.decoder).listen(runStdout.write);
      runProc.stderr.transform(utf8.decoder).listen(runStderr.write);

      if (shouldWaitForAnswer) {
        resultStream.sink.add(
          CompilerResult(
            status: CompilerResultStatus.waitingForInput,
            data: 'something',
          ),
        );
      }

      final rc = await runProc.exitCode;
      if (rc != 0) {
        resultStream.sink.add(CompilerResult.error(data: runStderr.toString()));
      } else {
        resultStream.sink.add(CompilerResult.done(data: runStdout.toString()));
      }
    } catch (e) {
      resultStream.sink.add(CompilerResult.error(error: e));
    }
  }
}
