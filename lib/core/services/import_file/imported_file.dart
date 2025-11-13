import 'package:dartpad_lite/storage/supported_language.dart';

class ImportedFile {
  final String name;
  final SupportedLanguage language;
  final String code;

  ImportedFile({
    required this.name,
    required this.language,
    required this.code,
  });

  factory ImportedFile.newFile({
    required SupportedLanguage language,
    String fileName = 'NewFile',
  }) {
    return ImportedFile(
      name: fileName,
      language: language,
      code: language.snippet,
    );
  }
}
