import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'compiler_interface.dart';

class SwiftCompiler implements CompilerInterface {
  final String path;

  SwiftCompiler(this.path);

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
  Future<CompilerResult> runCode(String code) async {
    try {
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final file = File('${tmpDir.path}/snippet_swift_$id.swift');
      await file.writeAsString(code);

      final cCompiler = path.isNotEmpty ? '$path/swift' : 'swift';

      final proc = await Process.start(cCompiler, [file.path, file.path]);

      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();

      proc.stdout.transform(utf8.decoder).listen(stdoutBuffer.write);
      proc.stderr.transform(utf8.decoder).listen(stderrBuffer.write);

      final exitCode = await proc.exitCode;

      if (exitCode == 0) {
        return CompilerResult(data: stdoutBuffer.toString());
      } else {
        return CompilerResult(hasError: true, data: stderrBuffer.toString());
      }
    } catch (e) {
      return CompilerResult(hasError: true, error: e);
    }
  }
}
