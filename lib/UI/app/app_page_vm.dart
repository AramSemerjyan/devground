import 'package:dartpad_lite/services/compiler/compiler_interface.dart';
import 'package:dartpad_lite/services/event_service.dart';
import 'package:dartpad_lite/services/import_file/import_file_service.dart';
import 'package:dartpad_lite/services/import_file/imported_file.dart';
import 'package:dartpad_lite/services/monaco_bridge_service/monaco_bridge_service.dart';
import 'package:dartpad_lite/services/save_file/file_service.dart';
import 'package:dartpad_lite/storage/language_repo.dart';
import 'package:dartpad_lite/storage/supported_language.dart';
import 'package:flutter/cupertino.dart';

enum SDKState { inProgress, ready, notReady }

class AppPageVM {
  late final Compiler compiler = Compiler();
  late final LanguageRepo languageRepo = LanguageRepo();
  late final FileServiceInterface fileService = FileService(languageRepo);
  final MonacoWebBridgeServiceInterface monacoWebBridgeService =
      MonacoWebBridgeService();
  late final ImportFileServiceInterface importFileService = ImportFileService(
    languageRepo,
    monacoWebBridgeService,
  );

  late final lspBridge;

  ValueNotifier<bool> inProgress = ValueNotifier(false);

  void setUp() async {
    inProgress.value = true;

    EventService.instance.onEvent.add(
      Event(type: EventType.idle, title: 'Initializing...'),
    );

    await languageRepo.setUp();

    final language = await languageRepo.getSelectedLanguage();

    if (language != null) {
      _setLanguage(language);

      // lspBridge = LspBridge(8081, language);
      // await lspBridge.start();

      await monacoWebBridgeService.setUp();
      monacoWebBridgeService.setLanguage(language: language);
    }

    EventService.instance.onEvent.stream
        .where((event) => event.type == EventType.languageChanged)
        .listen((event) {
          final data = event.data as SupportedLanguage?;

          if (data != null) _setLanguage(data);
        });

    EventService.instance.onEvent.stream
        .where((event) => event.type == EventType.importedFile)
        .listen((event) async {
          final importedFile = event.data as ImportedFile;

          _setLanguage(importedFile.language);

          await monacoWebBridgeService.setLanguage(
            language: importedFile.language,
          );
          await monacoWebBridgeService.setCode(code: importedFile.code);

          await languageRepo.setSelectedLanguage(
            key: importedFile.language.key,
          );
        });

    EventService.instance.onEvent.stream
        .where((event) => event.type == EventType.sdkPathUpdated)
        .listen((event) {
          final updatedLanguage = event.data as SupportedLanguage;
          final selectedLanguage = languageRepo.selectedLanguage.value;

          if (selectedLanguage == updatedLanguage) {
            _setLanguage(updatedLanguage);
            EventService.instance.onEvent.add(Event.success(title: 'Success'));
          }
        });

    inProgress.value = false;
  }

  void _setLanguage(SupportedLanguage language) {
    switch (language.supported) {
      case LanguageSupport.upcoming:
        compiler.resetCompiler();
        EventService.instance.onEvent.add(
          Event(type: EventType.warning, title: 'Upcoming support'),
        );
        break;
      case LanguageSupport.supported:
        try {
          compiler.setCompilerForLanguage(language: language);
          EventService.instance.onEvent.add(Event.success(title: 'Ready'));
        } catch (e) {
          EventService.instance.onEvent.add(
            Event(type: EventType.error, title: e.toString()),
          );
        }
        break;
      default:
        compiler.resetCompiler();
        EventService.instance.onEvent.add(
          Event(type: EventType.error, title: 'Not supported'),
        );
    }
  }
}
