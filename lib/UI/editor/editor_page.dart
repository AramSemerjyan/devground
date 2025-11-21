import 'package:dartpad_lite/UI/editor/editor/editor_view.dart';
import 'package:dartpad_lite/UI/editor/tab_view/editor_tab.dart';
import 'package:dartpad_lite/UI/editor/welcome/welcome_page.dart';
import 'package:dartpad_lite/core/pages_service/pages_service.dart';
import 'package:flutter/material.dart';

import '../../core/services/import_file/import_file_service.dart';
import '../../core/services/save_file/file_service.dart';
import '../../core/storage/language_repo.dart';
import 'editor_page_vm.dart';

class EditorPage extends StatefulWidget {
  final LanguageRepoInterface languageRepo;
  final ImportFileServiceInterface importFileService;
  final FileServiceInterface fileService;
  final PagesServiceInterface pagesService;

  const EditorPage({
    super.key,
    required this.fileService,
    required this.importFileService,
    required this.languageRepo,
    required this.pagesService,
  });
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final EditorPageVMInterface _vm = EditorPageVM(widget.pagesService);
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _vm.onPagesUpdate,
      builder: (_, update, __) {
        final pages = update.pages;

        if (pages.isEmpty) {
          return WelcomePage(
            fileService: widget.fileService,
            importFileService: widget.importFileService,
            languageRepo: widget.languageRepo,
          );
        }

        if (_pageController.hasClients) {
          _pageController.jumpToPage(update.selectedIndex);
        }

        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: pages.isNotEmpty ? 40 : 0),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                children: pages
                    .map(
                      (page) => EditorView(
                        key: ValueKey(page.id),
                        saveFileService: widget.fileService,
                        pagesService: widget.pagesService,
                        file: page.file,
                      ),
                    )
                    .toList(),
              ),
            ),
            if (pages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: EditorTabView(
                  pages: pages,
                  selectedTab: _vm.onPagesUpdate.value.selectedIndex,
                  onSelect: (i) {
                    _vm.onSelect(i);
                    _pageController.jumpToPage(i);
                  },
                  onClose: (i) => _vm.onClose(i),
                  onCloseAll: () => _vm.onCloseAll(),
                  onCloseOthers: (i) => _vm.onCloseOthers(i),
                ),
              ),
          ],
        );
      },
    );
  }
}
