import 'package:dartpad_lite/services/compiler/compiler_interface.dart';

class ShellCompiler implements CompilerInterface {
  final String path;

  ShellCompiler(this.path);

  @override
  Future<CompilerResult> formatCode(String code) {
    // TODO: implement formatCode
    throw UnimplementedError();
  }

  @override
  Future<CompilerResult> runCode(String code) {
    // TODO: implement runCode
    throw UnimplementedError();
  }
}
