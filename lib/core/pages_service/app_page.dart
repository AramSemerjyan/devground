import 'package:dartpad_lite/core/services/import_file/imported_file.dart';

class AppPage {
  AppFile file;
  String? edited;
  bool? isEdited;
  bool? isAIBoosted;

  AppPage({
    required this.file,
    this.edited,
    this.isEdited = false,
    this.isAIBoosted = false,
  });

  AppPage copy({String? edited, bool? isEdited, bool? isAIBoosted}) {
    return AppPage(
      file: file,
      edited: edited ?? this.edited,
      isEdited: isEdited ?? this.isEdited,
      isAIBoosted: isAIBoosted ?? this.isAIBoosted,
    );
  }
}
