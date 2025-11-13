import 'package:dartpad_lite/storage/language_repo.dart';
import 'package:dartpad_lite/storage/supported_language.dart';
import 'package:flutter/cupertino.dart';

import '../../core/services/event_service.dart';
import '../../core/services/import_file/import_file_service.dart';
import '../../core/services/import_file/imported_file.dart';
import '../../core/services/monaco_bridge_service/monaco_bridge_service.dart';
import '../../core/services/save_file/file_service.dart';

enum SDKState { inProgress, ready, notReady }

class AppPageVM {
  // late final Compiler compiler = Compiler();
  late final LanguageRepo languageRepo = LanguageRepo();
  late final FileServiceInterface fileService = FileService(languageRepo);
  final MonacoWebBridgeServiceInterface monacoWebBridgeService =
      MonacoWebBridgeService();
  late final ImportFileServiceInterface importFileService = ImportFileService(
    languageRepo,
  );

  late final lspBridge;

  ValueNotifier<bool> inProgress = ValueNotifier(false);

  void setUp() async {
    inProgress.value = true;

    EventService.instance.emit(
      Event(type: EventType.idle, title: 'Initializing...'),
    );

    _setListeners();

    await languageRepo.setUp();

    final language = await languageRepo.getSelectedLanguage();

    if (language != null) {
      EventService.instance.emit(
        Event(type: EventType.languageChanged, data: language),
      );

      // lspBridge = LspBridge(8081, language);
      // await lspBridge.start();

      await monacoWebBridgeService.setUp();
      monacoWebBridgeService.setLanguage(language: language);
    }

    inProgress.value = false;
  }

  void _setListeners() {
    EventService.instance.stream
        .where((event) => event.type == EventType.languageChanged)
        .listen((event) {
          final data = event.data as SupportedLanguage?;

          if (data != null) _setLanguage(data);
        });

    EventService.instance.stream
        .where((event) => event.type == EventType.languageChangedForNewFile)
        .listen((event) {
          final data = event.data as SupportedLanguage?;

          if (data != null) {
            _setLanguage(data);

            importFileService.importImportedFile(
              importedFile: ImportedFile.newFile(language: data),
            );
          }
        });

    EventService.instance.stream
        .where((event) => event.type == EventType.importedFile)
        .listen((event) async {
          final importedFile = event.data as ImportedFile;

          EventService.instance.emit(
            Event(type: EventType.languageChanged, data: importedFile.language),
          );

          await languageRepo.setSelectedLanguage(
            key: importedFile.language.key,
          );
        });

    EventService.instance.stream
        .where((event) => event.type == EventType.sdkPathUpdated)
        .listen((event) {
          final updatedLanguage = event.data as SupportedLanguage;
          final selectedLanguage = languageRepo.selectedLanguage.value;

          if (selectedLanguage == updatedLanguage) {
            _setLanguage(updatedLanguage);
            EventService.instance.emit(Event.success(title: 'Success'));
          }
        });
  }

  void _setLanguage(SupportedLanguage language) {
    switch (language.supported) {
      case LanguageSupport.upcoming:
        EventService.instance.emit(
          Event(type: EventType.warning, title: 'Upcoming support'),
        );
        break;
      case LanguageSupport.supported:
        try {
          EventService.instance.emit(Event.success(title: 'Ready'));
        } catch (e) {
          EventService.instance.emit(
            Event(type: EventType.error, title: e.toString()),
          );
        }
        break;
      default:
        EventService.instance.emit(
          Event(type: EventType.error, title: 'Not supported'),
        );
    }
  }
}
