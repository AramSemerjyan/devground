import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:dartpad_lite/core/services/compiler/compiler_result.dart';
abstract class CompilerInterface {
  Future<CompilerResult> runCode(String code);
  Future<CompilerResult> formatCode(String code);
}

class Compiler implements CompilerInterface {
  Compiler();

  @override
  Future<CompilerResult> formatCode(String code) {
    throw CompilerNotSelected();
  }

  @override
  Future<CompilerResult> runCode(String code) {
    throw CompilerNotSelected();
  }
}
