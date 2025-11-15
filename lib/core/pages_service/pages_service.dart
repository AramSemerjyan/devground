import 'package:dartpad_lite/core/pages_service/app_page.dart';
import 'package:flutter/foundation.dart';

import '../services/event_service/event_service.dart';
import '../services/import_file/imported_file.dart';

abstract class PagesServiceInterface {
  ValueNotifier<(List<AppPage>, int)> get onPagesUpdate;

  Future<AppPage> getSelectedPage();
  Future<void> updatePage({required AppPage page});

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
          final (pages, selected) = onPagesUpdate.value;

          final newPage = AppPage(
            file: event.data as AppFile,
            index: pages.length,
          );

          final updatedPages = [...pages, newPage];
          final reindexedPages = _reindex(updatedPages);

          _updatePages(reindexedPages, reindexedPages.length - 1);
        });
  }

  // ----------------------
  // MARK: Interface
  // ----------------------

  @override
  Future<AppPage> getSelectedPage() async {
    final (pages, selected) = onPagesUpdate.value;
    return pages[selected];
  }

  @override
  Future<void> updatePage({required AppPage page}) async {
    final (pages, selected) = onPagesUpdate.value;
    final updatedPages = List<AppPage>.from(pages);

    updatedPages[page.index] = page;

    _updatePages(updatedPages, selected);
  }

  @override
  Future<void> onClose(int index) async {
    final (pages, selectedIndex) = onPagesUpdate.value;

    final updatedPages = List<AppPage>.from(pages)..removeAt(index);
    final reindexedPages = _reindex(updatedPages);

    int newSelected = selectedIndex;

    if (reindexedPages.isEmpty) {
      newSelected = -1;
    } else if (index == selectedIndex) {
      newSelected = index >= reindexedPages.length
          ? reindexedPages.length - 1
          : index;
    } else if (index < selectedIndex) {
      newSelected = selectedIndex - 1;
    }

    _updatePages(reindexedPages, newSelected);
  }

  @override
  Future<void> onCloseAll() async {
    _updatePages([], -1);
  }

  @override
  Future<void> onCloseOthers(int pageIndex) async {
    final (pages, selected) = onPagesUpdate.value;

    if (pages.isEmpty || pageIndex < 0 || pageIndex >= pages.length) {
      return;
    }

    final selectedPage = pages[pageIndex].copy(index: 0);

    _updatePages([selectedPage], 0);
  }

  // ----------------------
  // MARK: Helpers
  // ----------------------

  List<AppPage> _reindex(List<AppPage> pages) {
    return [for (int i = 0; i < pages.length; i++) pages[i].copy(index: i)];
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
