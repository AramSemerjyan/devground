import 'dart:io';

import 'package:dartpad_lite/core/extension/file_extension.dart';
import 'package:flutter/cupertino.dart';

import '../../core/services/import_file/import_file_service.dart';
import '../../core/services/save_file/file_service.dart';

abstract class HistoryPageVMInterface {
  ValueNotifier<List<File>> get onFilesUpdate;

  Future<void> fetchHistory();
  Future<void> deleteFile({required File file});
  Future<void> onSelect({required File file});
  Future<void> onReveal({required File file});
  Future<void> onSearch({String? query});
}

class HistoryPageVM implements HistoryPageVMInterface {
  final FileServiceInterface _fileService;
  final ImportFileServiceInterface _importFileService;

  HistoryPageVM(this._fileService, this._importFileService);

  @override
  ValueNotifier<List<File>> onFilesUpdate = ValueNotifier([]);

  List<File> _fetchedHistory = [];

  @override
  Future<void> fetchHistory() async {
    final historyFiles = await _fileService.getHistoryFiles();
    _fetchedHistory = historyFiles;
    onFilesUpdate.value = historyFiles;
  }

  @override
  Future<void> deleteFile({required File file}) async {
    await _fileService.deleteFile(file: file);
    await fetchHistory();
  }

  @override
  Future<void> onSelect({required File file}) async {
    await _importFileService.importFile(file: file);
  }

  @override
  Future<void> onReveal({required File file}) async {
    await _fileService.revealInFinder(file: file);
  }

  @override
  Future<void> onSearch({String? query}) async {
    if (query != null && query.isNotEmpty) {
      onFilesUpdate.value = _fetchedHistory
          .where(
            (file) => file.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } else {
      onFilesUpdate.value = _fetchedHistory;
    }
  }
}
