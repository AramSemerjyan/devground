import 'package:dartpad_lite/core/pages_service/app_page.dart';
import 'package:flutter/foundation.dart';

import '../services/event_service/event_service.dart';
import '../services/import_file/imported_file.dart';

abstract class PagesServiceInterface {
  ValueNotifier<(List<AppPage>, int)> get onPagesUpdate;

  Future<void> onClose(int index);
  Future<void> onCloseAll();
  Future<void> onCloseOthers(int pageIndex);
}

class PagesService implements PagesServiceInterface {
  @override
  ValueNotifier<(List<AppPage>, int)> onPagesUpdate = ValueNotifier(([], -1));

  PagesService() {
    EventService.instance.stream
        .where((event) => event.type == EventType.importedFile)
        .listen((event) {
          final updatedPages = [
            ...onPagesUpdate.value.$1,
            AppPage(file: event.data as AppFile),
          ];
          final selectedPage = updatedPages.length - 1;

          _updatePages(updatedPages, selectedPage);
        });
  }

  @override
  Future<void> onClose(int index) async {
    final (pages, selectedIndex) = onPagesUpdate.value;

    final updatedPages = List<AppPage>.from(pages)..removeAt(index);

    int newSelectedIndex = selectedIndex;

    if (updatedPages.isEmpty) {
      newSelectedIndex = -1;
    } else if (index == selectedIndex) {
      if (index >= updatedPages.length) {
        newSelectedIndex = updatedPages.length - 1;
      } else {
        newSelectedIndex = index;
      }
    } else if (index < selectedIndex) {
      newSelectedIndex = selectedIndex - 1;
    }

    _updatePages(updatedPages, newSelectedIndex);
  }

  @override
  Future<void> onCloseAll() async {
    onPagesUpdate.value = ([], -1);

    _updatePages([], 0);
  }

  @override
  Future<void> onCloseOthers(int pageIndex) async {
    final (pages, _) = onPagesUpdate.value;
    if (pages.isEmpty || pageIndex < 0 || pageIndex >= pages.length) return;

    final selectedFile = pages[pageIndex];
    _updatePages([selectedFile], 0);
  }

  void _updatePages(List<AppPage> updatedPages, int selectedIndex) {
    onPagesUpdate.value = (updatedPages, selectedIndex);

    EventService.emit(type: EventType.aiModeChanged, data: false);

    if (selectedIndex >= 0 && updatedPages.isNotEmpty) {
      EventService.emit(
        type: EventType.languageChanged,
        data: updatedPages[selectedIndex].file.language,
      );
    }
  }
}
