import 'dart:io';

import 'package:dartpad_lite/services/import_file/imported_file.dart';
import 'package:dartpad_lite/services/monaco_bridge_service/monaco_bridge_service.dart';
import 'package:dartpad_lite/storage/language_repo.dart';
import 'package:path/path.dart';

import '../event_service.dart';

abstract class ImportFileServiceInterface {
  Future<void> importFile({required File file});
}

class ImportFileService implements ImportFileServiceInterface {
  final LanguageRepoInterface _languageRepo;
  final MonacoWebBridgeServiceInterface _monacoWebBridgeService;

  ImportFileService(this._languageRepo, this._monacoWebBridgeService);

  @override
  Future<void> importFile({required File file}) async {
    try {
      // Get all supported languages
      final supportedLanguages = await _languageRepo.getSupportedLanguages();

      // Get file extension
      final ext = extension(file.path).toLowerCase(); // e.g., ".dart"

      final matchedLanguage = supportedLanguages.values
          .where((lang) => lang.extension.toLowerCase() == ext)
          .firstOrNull;

      if (matchedLanguage != null) {
        // Read file content
        final content = await file.readAsString();

        final importedFile = ImportedFile(
          language: matchedLanguage,
          code: content,
        );

        EventService.instance.emit(
          Event(type: EventType.importedFile, data: importedFile),
        );
      } else {
        EventService.instance.emit(
          Event.warning(title: 'Unsupported file type'),
        );
      }
    } catch (e) {
      EventService.instance.emit(Event.error(title: e.toString()));
    }
  }
}
