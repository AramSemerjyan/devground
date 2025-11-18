import '../../storage/supported_language.dart';

class AppFile {
  final SupportedLanguage language;
  final String? fileName;
  final String code;
  final bool isNew;
  final Uri? path;

  String get name => path?.pathSegments.last ?? fileName ?? '';

  AppFile({
    required this.language,
    required this.code,
    this.isNew = false,
    this.path,
    this.fileName,
  });

  factory AppFile.newFile({
    required SupportedLanguage language,
    String fileName = 'NewFile',
  }) {
    return AppFile(
      language: language,
      code: language.snippet,
      isNew: true,
      fileName: fileName,
    );
  }
}
