import 'package:uuid/uuid.dart';

import '../../storage/supported_language.dart';
import 'compiler_interface.dart';

class DefaultCompiler implements CompilerInterface {
  final SupportedLanguage language;

  final uuid = const Uuid();

  DefaultCompiler({required this.language});

  @override
  Future<CompilerResult> formatCode(String code) async {
    return CompilerResult(data: code);
  }

  @override
  Future<CompilerResult> runCode(String code) async {
    return CompilerResult(hasError: true);
  }
}
