import 'dart:convert';

import 'package:dartpad_lite/storage/supported_language.dart';
import 'package:uuid/uuid.dart';

import 'compiler_interface.dart';

class DefaultCompiler implements CompilerInterface {
  final SupportedLanguage language;

  final uuid = const Uuid();

  DefaultCompiler({required this.language});

  @override
  Future<CompilerResult> formatCode(String code) async {
    try {
      final jsonObject = jsonDecode(code);
      const encoder = JsonEncoder.withIndent('  '); // 2 spaces
      return CompilerResult(data: encoder.convert(jsonObject));
    } catch (e) {
      return CompilerResult(hasError: true, error: e);
    }
  }

  @override
  Future<CompilerResult> runCode(String code) async {
    // try {
    // final tmpDir = await getTemporaryDirectory();
    // final id = uuid.v4();
    // final file = File('${tmpDir.path}/snippet_fmt_$id.${language.extension}');
    // await file.writeAsString(code);
    //
    // // Load the temporary file into WebView
    // final uri = Uri.file(file.path).path;

    //   return CompilerResult(data: code);
    // } catch (e) {
    return CompilerResult(hasError: true);
  }

  // }
}
