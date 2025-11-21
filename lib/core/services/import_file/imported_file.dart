import '../../storage/supported_language.dart';

class AppFile {
  final SupportedLanguage language;
  final String? fileName;
  final String code;
  final bool isNew;
  final Uri? path;

  String get name {
    final filename = path?.pathSegments.last ?? fileName ?? '';
    if (filename.isEmpty) return '';
    final dot = filename.lastIndexOf('.');
    if (dot > 0) return filename.substring(0, dot);
    return filename;
  }

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
