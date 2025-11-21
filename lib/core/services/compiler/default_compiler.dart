import 'package:uuid/uuid.dart';

import '../../storage/supported_language.dart';
import 'compiler_interface.dart';
import 'compiler_result.dart';

class DefaultCompiler extends Compiler {
  final SupportedLanguage language;

  final uuid = const Uuid();

  DefaultCompiler({required this.language});

  @override
  Future<CompilerResult> formatCode(String code) async {
    return CompilerResult.message(data: code);
  }

  @override
  Future<void> runCode(String code) async {
    resultStream.add(
      CompilerResult.error(data: "Language doesn't contains compiler"),
    );
  }
}
