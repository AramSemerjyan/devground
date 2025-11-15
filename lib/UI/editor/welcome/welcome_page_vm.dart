import 'dart:io';

import '../../../core/services/import_file/import_file_service.dart';
import '../../../core/services/import_file/imported_file.dart';
import '../../../core/services/save_file/file_service.dart';
import '../../../core/storage/language_repo.dart';

abstract class WelcomePageVMInterface {
  Future<List<File>> getHistory();
  Future<void> onSelect({required File file});
  Future<void> onNewFile();
}

class WelcomePageVM implements WelcomePageVMInterface {
  final LanguageRepoInterface languageRepo;
  final ImportFileServiceInterface importFileService;
  final FileServiceInterface fileService;

  WelcomePageVM(this.fileService, this.importFileService, this.languageRepo);

  @override
  Future<List<File>> getHistory() {
    return fileService.getHistoryFiles();
  }

  @override
  Future<void> onSelect({required File file}) async {
    await importFileService.importFile(file: file);
  }

  @override
  Future<void> onNewFile() async {
    final selectedLanguage = languageRepo.selectedLanguage.value;

    if (selectedLanguage != null) {
      await importFileService.importAppFile(
        importedFile: AppFile.newFile(language: selectedLanguage),
      );
    }
  }
}
