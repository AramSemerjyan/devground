import 'package:dartpad_lite/core/services/import_file/imported_file.dart';

class AppPage {
  late final String id;
  final AppFile file;
  final int index;
  final String? edited;
  final bool? isEdited;
  final bool? isAIBoosted;

  AppPage({
    required this.id,
    required this.file,
    required this.index,
    this.edited,
    this.isEdited = false,
    this.isAIBoosted = false,
  });

  AppPage copy({
    int? index,
    String? edited,
    bool? isEdited,
    bool? isAIBoosted,
  }) {
    return AppPage(
      id: id,
      file: file,
      index: index ?? this.index,
      edited: edited ?? this.edited,
      isEdited: isEdited ?? this.isEdited,
      isAIBoosted: isAIBoosted ?? this.isAIBoosted,
    );
  }

  @override
  bool operator ==(Object other) {
    return id == (other as AppPage).id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'id: $id\nfile:${file.name}\nindex:$index\nisAIBoosted: $isAIBoosted';
  }
}
