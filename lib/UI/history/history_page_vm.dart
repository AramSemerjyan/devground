import 'dart:io';

import 'package:dartpad_lite/services/save_file/save_file_service.dart';
import 'package:flutter/cupertino.dart';

abstract class HistoryPageVMInterface {
  ValueNotifier<List<File>> get onFilesUpdate;

  Future<void> fetchHistory();
  Future<void> deleteFile({required File file});
}

class HistoryPageVM implements HistoryPageVMInterface {
  final FileServiceInterface _fileService;

  HistoryPageVM(this._fileService);

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
}
