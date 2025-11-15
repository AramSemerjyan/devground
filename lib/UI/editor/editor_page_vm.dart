import 'dart:async';

import 'package:dartpad_lite/UI/app/open_page_manager.dart';
import 'package:flutter/cupertino.dart';

import '../../core/services/event_service/event_service.dart';
import '../../core/services/import_file/imported_file.dart';

abstract class EditorPageVMInterface {
  ValueNotifier<(List<AppFile>, int)> get onPagesUpdate;

  Future<void> onSelect(int pageIndex);
  Future<void> onClose(int pageIndex);
  Future<void> onCloseOthers(int pageIndex);
  Future<void> onCloseAll();
}

class EditorPageVM implements EditorPageVMInterface {
  final OpenPageManagerInterface openPageManager;

  @override
  ValueNotifier<(List<AppFile>, int)> get onPagesUpdate =>
      openPageManager.onPagesUpdate;

  EditorPageVM(this.openPageManager);

  @override
  Future<void> onSelect(int pageIndex) async {
    if (pageIndex == onPagesUpdate.value.$2) return;

    onPagesUpdate.value = (onPagesUpdate.value.$1, pageIndex);

    EventService.emit(
      type: EventType.languageChanged,
      data: onPagesUpdate.value.$1[onPagesUpdate.value.$2].language,
    );
  }

  @override
  Future<void> onClose(int pageIndex) async {
    final (pages, selectedIndex) = onPagesUpdate.value;

    final updatedPages = List<AppFile>.from(pages)..removeAt(pageIndex);

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

    EventService.emit(type: EventType.languageChanged, data: language);

    onPagesUpdate.value = (updatedPages, newSelectedIndex);
  }

  @override
  Future<void> onCloseOthers(int pageIndex) async {
    final (pages, _) = onPagesUpdate.value;
    if (pages.isEmpty || pageIndex < 0 || pageIndex >= pages.length) return;

    final selectedFile = pages[pageIndex];
    _updatePages([selectedFile], 0);
  }

  @override
  Future<void> onCloseAll() async {
    onPagesUpdate.value = ([], -1);

    // Optionally reset language context if needed
    EventService.emit(type: EventType.languageChanged, data: null);
  }

  void _updatePages(List<AppFile> updatedPages, int selectedIndex) {
    onPagesUpdate.value = (updatedPages, selectedIndex);

    if (selectedIndex >= 0 && updatedPages.isNotEmpty) {
      EventService.emit(
        type: EventType.languageChanged,
        data: updatedPages[selectedIndex].language,
      );
    }
  }
}
