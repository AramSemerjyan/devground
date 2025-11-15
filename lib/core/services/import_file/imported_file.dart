import '../../storage/supported_language.dart';

class AppFile {
  final String name;
  final SupportedLanguage language;
  final String code;
  final bool isNew;

  AppFile({
    required this.name,
    required this.language,
    required this.code,
    this.isNew = false,
  });

  factory AppFile.newFile({
    required SupportedLanguage language,
    String fileName = 'NewFile',
  }) {
    return AppFile(
      name: fileName,
      language: language,
      code: language.snippet,
      isNew: true,
    );
  }
}
