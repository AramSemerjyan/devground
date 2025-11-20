import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';

class CCompiler extends Compiler {
  final String path;

  CCompiler(this.path);

  final uuid = const Uuid();

  @override
  Future<CompilerResult> formatCode(String code) async {
    try {
      // Simple formatting: add line breaks and indentation for nested tags
      // (You can use `html` package or prettier for more advanced formatting)
      final formatted = code.replaceAll(RegExp(r'>\s*<'), '>\n<');
      return CompilerResult(data: formatted);
    } catch (e) {
      return CompilerResult(hasError: true, error: e);
    }
  }

  @override
  Future<CompilerResult> runCode(String code) async {
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

      compileProc.stdout.transform(utf8.decoder).listen(compileStdout.write);
      compileProc.stderr.transform(utf8.decoder).listen(compileStderr.write);

      final exitCode = await compileProc.exitCode;
      if (exitCode != 0) {
        return CompilerResult(hasError: true, data: compileStderr.toString());
      }

      final runProc = await Process.start(file.path, []);
      final runStdout = StringBuffer();
      final runStderr = StringBuffer();

      runProc.stdout.transform(utf8.decoder).listen(runStdout.write);
      runProc.stderr.transform(utf8.decoder).listen(runStderr.write);

      final rc = await runProc.exitCode;
      if (rc != 0) {
        return CompilerResult(hasError: true, data: runStderr.toString());
      } else {
        return CompilerResult(data: runStdout.toString(), hasError: false);
      }
    } catch (e) {
      return CompilerResult(hasError: true, error: e);
    }
  }
}
