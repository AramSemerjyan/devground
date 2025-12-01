import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';

class JSONCompiler extends Compiler {
  final uuid = const Uuid();

  @override
  Future<CompilerResult> formatCode(String code) async {
    try {
      final jsonObject = jsonDecode(code);
      const encoder = JsonEncoder.withIndent('  '); // 2 spaces
      return CompilerResult.message(data: encoder.convert(jsonObject), message: 'JSON formatted successfully');
    } catch (e, s) {
      return CompilerResult.error(error: e, stackTrace: s);
    }
  }

  @override
  Future<void> runCode(String code) async {
    // This compiler does not execute code; just report as not supported for run
    resultStream.sink.add(CompilerResult.error(data: 'Run not supported for JSON'));
  }
}
