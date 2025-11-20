import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';

class HTMLCompiler extends Compiler {
  final uuid = const Uuid();

  @override
  Future<CompilerResult> formatCode(String code) async {
    // try {
    //   // Simple formatting: add line breaks and indentation for nested tags
    //   // (You can use `html` package or prettier for more advanced formatting)
    //   final formatted = code.replaceAll(RegExp(r'>\s*<'), '>\n<');
    return CompilerResult(data: code);
    // } catch (e) {
    //   return CompilerResult(hasError: true, error: e);
    // }
  }

  @override
  Future<CompilerResult> runCode(String code) async {
    try {
      // Create a temporary HTML file
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final file = File('${tmpDir.path}/snippet_fmt_$id.html');
      await file.writeAsString(code);

      // Load the temporary file into WebView
      final uri = Uri.file(file.path).path;

      return CompilerResult(data: uri);
    } catch (e) {
      return CompilerResult(hasError: true, error: e);
    }
  }
}
