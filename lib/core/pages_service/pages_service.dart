import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import 'app_page.dart';
import '../services/import_file/imported_file.dart';

class PageState {
  final List<AppPage> pages;
  final int selectedIndex;
  final int? previousIndex;

  PageState({
    required this.pages,
    required this.selectedIndex,
    this.previousIndex,
  });
}

abstract class PagesServiceInterface {
  ValueNotifier<PageState> get onPagesUpdate;

  Future<AppPage> getSelectedPage();
  Future<void> updatePage({required AppPage page});

  Future<void> insertPageWithAppFile(AppFile file);
  Future<void> onClose(int index);
  Future<void> onCloseAll();
  Future<void> onCloseOthers(int pageIndex);
}

class PagesService implements PagesServiceInterface {
  @override
  ValueNotifier<PageState> onPagesUpdate = ValueNotifier(
    PageState(pages: [], selectedIndex: -1),
  );

  PagesService._internal();

  static final PagesService _instance = PagesService._internal();

  factory PagesService() => _instance;

  // ----------------------
  // MARK: Interface
  // ----------------------

  @override
  Future<AppPage> getSelectedPage() async {
    final state = onPagesUpdate.value;
    return state.pages[state.selectedIndex];
  }

  @override
  Future<void> insertPageWithAppFile(AppFile file) async {
    final state = onPagesUpdate.value;

    final newPage = AppPage(
      id: const Uuid().v4(),
      file: file,
      index: state.pages.length,
    );

    final updatedPages = [...state.pages, newPage];
    final reindexedPages = _reindex(updatedPages);

    _updatePages(reindexedPages, reindexedPages.length - 1);
  }

  @override
  Future<void> updatePage({required AppPage page}) async {
    final state = onPagesUpdate.value;
    final updatedPages = List<AppPage>.from(state.pages);

    updatedPages[page.index] = page;

    _updatePages(updatedPages, state.selectedIndex);
  }

  @override
  Future<void> onClose(int index) async {
    final state = onPagesUpdate.value;

    final updatedPages = List<AppPage>.from(state.pages)..removeAt(index);
    final reindexedPages = _reindex(updatedPages);

    int newSelected = state.selectedIndex;

    if (reindexedPages.isEmpty) {
      newSelected = -1;
    } else if (index == state.selectedIndex) {
      newSelected = index >= reindexedPages.length
          ? reindexedPages.length - 1
          : index;
    } else if (index < state.selectedIndex) {
      newSelected = state.selectedIndex - 1;
    }

    _updatePages(reindexedPages, newSelected);
  }

  @override
  Future<void> onCloseAll() async {
    _updatePages([], -1);
  }

  @override
  Future<void> onCloseOthers(int pageIndex) async {
    final state = onPagesUpdate.value;

    if (state.pages.isEmpty ||
        pageIndex < 0 ||
        pageIndex >= state.pages.length) {
      return;
    }

    final selectedPage = state.pages[pageIndex].copy(index: 0);

    _updatePages([selectedPage], 0);
  }

  // ----------------------
  // MARK: Helpers
  // ----------------------

  List<AppPage> _reindex(List<AppPage> pages) {
    return [for (int i = 0; i < pages.length; i++) pages[i].copy(index: i)];
  }

  void _updatePages(List<AppPage> updatedPages, int selectedIndex) {
    onPagesUpdate.value = PageState(
      pages: updatedPages,
      selectedIndex: selectedIndex,
    );
  }
}
