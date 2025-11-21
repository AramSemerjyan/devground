import 'package:flutter_js/flutter_js.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';

class JsCompiler extends Compiler {
  final uuid = const Uuid();

  // JS runtime
  final JavascriptRuntime _jsRuntime = getJavascriptRuntime();

  JsCompiler();

  @override
  Future<void> runCode(String code) async {
    try {
      // Evaluate code
      final result = _jsRuntime.evaluate(code);
      resultStream.add(CompilerResult.done(data: result.stringResult));
    } catch (e) {
      resultStream.add(CompilerResult.error(error: e.toString()));
    }
  }

  @override
  Future<CompilerResult> formatCode(String code) async {
    try {
      final formatted = code.trim();
      return CompilerResult.message(data: formatted);
    } catch (e) {
      return CompilerResult.error(error: e.toString());
    }
  }
}
