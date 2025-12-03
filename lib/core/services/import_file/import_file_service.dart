import 'dart:io';

import 'package:path/path.dart';

import '../../storage/compiler_repo.dart';
import '../event_service/app_error.dart';
import '../event_service/event_service.dart';
import 'imported_file.dart';

abstract class ImportFileServiceInterface {
  Future<void> importFile({required File file});
  Future<void> importAppFile({required AppFile importedFile});
}

class ImportFileService implements ImportFileServiceInterface {
  final CompilerRepoInterface _languageRepo;

  ImportFileService(this._languageRepo);

  @override
  Future<void> importFile({required File file}) async {
    try {
      // Get all supported languages
      final supportedLanguages = await _languageRepo.getAllLanguages();

      // Get file extension
      final ext = extension(file.path).toLowerCase(); // e.g., ".dart"

      final matchedLanguage = supportedLanguages.values
          .where((lang) => lang.extension.toLowerCase() == ext)
          .firstOrNull;

      if (matchedLanguage != null) {
        // Read file content
        final content = await file.readAsString();

        final importedFile = AppFile(
          language: matchedLanguage,
          code: content,
          path: file.uri,
        );

        EventService.success(
          type: EventType.importedFile,
          data: importedFile,
          msg: 'Successfully imported',
        );
      } else {
        EventService.warning(msg: 'Unsupported file type');
      }
    } catch (e, s) {
      EventService.error(
        msg: e.toString(),
        error: AppError(object: e, stackTrace: s),
      );
    }
  }

  @override
  Future<void> importAppFile({required AppFile importedFile}) async {
    EventService.success(
      type: EventType.importedFile,
      data: importedFile,
      msg: 'Successfully imported',
    );
  }
}
