import 'package:dartpad_lite/UI/editor/editor/editor_view.dart';
import 'package:dartpad_lite/UI/editor/tab_view/editor_tab.dart';
import 'package:dartpad_lite/UI/editor/welcome/welcome_page.dart';
import 'package:dartpad_lite/storage/language_repo.dart';
import 'package:flutter/material.dart';

import '../../core/services/import_file/import_file_service.dart';
import '../../core/services/save_file/file_service.dart';
import 'editor_page_vm.dart';

class EditorPage extends StatefulWidget {
  final LanguageRepoInterface languageRepo;
  final ImportFileServiceInterface importFileService;
  final FileServiceInterface fileService;

  const EditorPage({
    super.key,
    required this.fileService,
    required this.importFileService,
    required this.languageRepo,
  });
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final EditorPageVMInterface _vm = EditorPageVM();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _vm.onPagesUpdate,
      builder: (_, pages, __) {
        final files = pages.$1;
        final selectedTab = pages.$2;

        if (files.isEmpty) {
          return WelcomePage(
            fileService: widget.fileService,
            importFileService: widget.importFileService,
            languageRepo: widget.languageRepo,
          );
        }

        final file = files[selectedTab];

        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: files.length > 1 ? 40 : 0),
              child: EditorView(
                key: ObjectKey(file),
                saveFileService: widget.fileService,
                file: file,
              ),
            ),

            if (files.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: EditorTabView(
                  files: files,
                  selectedTab: selectedTab,
                  onSelect: (i) {
                    _vm.onSelect(i);
                  },
                  onClose: (i) {
                    _vm.onClose(i);
                  },
                  onCloseAll: () {
                    _vm.onCloseAll();
                  },
                  onCloseOthers: (i) {
                    _vm.onCloseOthers(i);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
