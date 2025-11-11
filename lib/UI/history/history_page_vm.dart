import 'dart:io';

import 'package:dartpad_lite/services/import_file/import_file_service.dart';
import 'package:dartpad_lite/services/save_file/file_service.dart';
import 'package:flutter/cupertino.dart';

abstract class HistoryPageVMInterface {
  ValueNotifier<List<File>> get onFilesUpdate;

  Future<void> fetchHistory();
  Future<void> deleteFile({required File file});
  Future<void> onSelect({required File file});
  Future<void> onReveal({required File file});
}

class HistoryPageVM implements HistoryPageVMInterface {
  final FileServiceInterface _fileService;
  final ImportFileServiceInterface _importFileService;

  HistoryPageVM(this._fileService, this._importFileService);

  @override
  ValueNotifier<List<File>> onFilesUpdate = ValueNotifier([]);

  @override
  Future<void> deleteFile({required File file}) async {
    await _fileService.deleteFile(file: file);
    await fetchHistory();
  }

  @override
  Future<void> fetchHistory() async {
    onFilesUpdate.value = await _fileService.getHistoryFiles();
  }

  @override
  Future<void> onSelect({required File file}) async {
    await _importFileService.importFile(file: file);
  }

  @override
  Future<void> onReveal({required File file}) async {
    await _fileService.revealInFinder(file: file);
  }
}
