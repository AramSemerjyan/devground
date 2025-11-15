import '../../storage/supported_language.dart';

class AppFile {
  final String name;
  final SupportedLanguage language;
  final String code;

  AppFile({required this.name, required this.language, required this.code});

  factory AppFile.newFile({
    required SupportedLanguage language,
    String fileName = 'NewFile',
  }) {
    return AppFile(name: fileName, language: language, code: language.snippet);
  }
}
