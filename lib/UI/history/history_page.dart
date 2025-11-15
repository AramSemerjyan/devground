import 'dart:io';

import 'package:dartpad_lite/UI/history/history_page_vm.dart';
import 'package:dartpad_lite/UI/history/history_tile.dart';
import 'package:flutter/material.dart';

import '../../core/services/import_file/import_file_service.dart';
import '../../core/services/save_file/file_service.dart';
import '../../utils/app_colors.dart';

class HistoryPage extends StatefulWidget {
  final FileServiceInterface fileService;
  final ImportFileServiceInterface importFileService;

  const HistoryPage({
    super.key,
    required this.fileService,
    required this.importFileService,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final HistoryPageVMInterface _vm = HistoryPageVM(
    widget.fileService,
    widget.importFileService,
  );

  late final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _vm.fetchHistory();
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search by file name or extension',
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (text) {
        _vm.onSearch(query: text);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColor.mainGrey),
      backgroundColor: AppColor.mainGreyDark,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder<List<File>>(
                valueListenable: _vm.onFilesUpdate,
                builder: (_, files, __) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Column(
                        children: files.map((file) {
                          return HistoryTile(
                            file: file,
                            onSelect: (file) {
                              _vm.onSelect(file: file);
                              // AppPageScope.of(context).navigatorKey.currentState
                              //     ?.pushReplacementNamed(AppPages.editor.value);
                            },
                            onDelete: (file) => _vm.deleteFile(file: file),
                            onReveal: (file) => _vm.onReveal(file: file),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
