import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../core/services/event_service.dart';
import '../../core/services/import_file/imported_file.dart';

abstract class EditorPageVMInterface {
  ValueNotifier<(List<ImportedFile>, int)> get onPagesUpdate;

  Future<void> onSelect(int pageIndex);
  Future<void> onClose(int pageIndex);
}

class EditorPageVM implements EditorPageVMInterface {
  @override
  ValueNotifier<(List<ImportedFile>, int)> onPagesUpdate = ValueNotifier((
    [],
    -1,
  ));

  EditorPageVM() {
    _setListeners();
  }

  void _setListeners() {
    EventService.instance.stream
        .where((event) => event.type == EventType.importedFile)
        .listen((event) {
          final updatedPages = [
            ...onPagesUpdate.value.$1,
            event.data as ImportedFile,
          ];
          final selectedPage = updatedPages.length - 1;

          onPagesUpdate.value = (updatedPages, selectedPage);
        });
  }

  @override
  Future<void> onSelect(int pageIndex) async {
    if (pageIndex == onPagesUpdate.value.$2) return;

    onPagesUpdate.value = (onPagesUpdate.value.$1, pageIndex);

    EventService.event(
      type: EventType.languageChanged,
      data: onPagesUpdate.value.$1[onPagesUpdate.value.$2].language,
    );
  }

  @override
  Future<void> onClose(int pageIndex) async {
    final (pages, selectedIndex) = onPagesUpdate.value;

    final updatedPages = List<ImportedFile>.from(pages)..removeAt(pageIndex);

    int newSelectedIndex = selectedIndex;

    if (updatedPages.isEmpty) {
      newSelectedIndex = -1; // no pages left
    } else if (pageIndex == selectedIndex) {
      // removed the selected tab → pick nearby one
      if (pageIndex >= updatedPages.length) {
        newSelectedIndex = updatedPages.length - 1; // pick previous
      } else {
        newSelectedIndex = pageIndex; // pick the one that replaced it
      }
    } else if (pageIndex < selectedIndex) {
      // removed a tab before the selected one → shift left
      newSelectedIndex = selectedIndex - 1;
    }

    final language = updatedPages[newSelectedIndex].language;

    EventService.event(type: EventType.languageChanged, data: language);

    onPagesUpdate.value = (updatedPages, newSelectedIndex);
  }
}
