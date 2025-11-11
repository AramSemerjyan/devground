import 'dart:io';

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

        await _monacoWebBridgeService.setLanguage(language: matchedLanguage);
        await _monacoWebBridgeService.setCode(code: content);

        await _languageRepo.setSelectedLanguage(key: matchedLanguage.key);
        // EventService.instance.onEvent.add(
        //   Event(type: EventType.languageChanged, data: language),
        // );

        // Do something with the matched language and content
        EventService.instance.onEvent.add(
          Event.success(title: 'File imported'),
        );
      } else {
        EventService.instance.onEvent.add(
          Event.warning(title: 'Unsupported file type'),
        );
      }
    } catch (e) {
      EventService.instance.onEvent.add(Event.error(title: e.toString()));
    }
  }
}
