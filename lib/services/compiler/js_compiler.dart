import 'package:flutter_js/flutter_js.dart';
import 'package:uuid/uuid.dart';

import 'compiler_interface.dart';

class JsCompiler implements CompilerInterface {
  final uuid = const Uuid();

  // JS runtime
  final JavascriptRuntime _jsRuntime = getJavascriptRuntime();

  JsCompiler();

  @override
  Future<CompilerResult> runCode(String code) async {
    try {
      // Evaluate code
      final result = _jsRuntime.evaluate(code);

      return CompilerResult(hasError: false, data: result.stringResult);
    } catch (e) {
      return CompilerResult(error: e.toString());
    }
  }

  @override
  Future<CompilerResult> formatCode(String code) async {
    try {
      // Simple formatting: just trim for now
      final formatted = code.trim();

      return CompilerResult(data: formatted, hasError: false);
    } catch (e) {
      return CompilerResult(error: e.toString());
    }
  }
}
