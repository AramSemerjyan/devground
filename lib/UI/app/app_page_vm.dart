import 'dart:io';

import 'package:dartpad_lite/core/pages_service/pages_service.dart';
import 'package:dartpad_lite/core/platform_channel/app_platform_channel.dart';
import 'package:dartpad_lite/core/services/event_service/app_error.dart';
import 'package:flutter/cupertino.dart';

import '../../core/services/event_service/event_service.dart';
import '../../core/services/import_file/import_file_service.dart';
import '../../core/services/import_file/imported_file.dart';
import '../../core/services/save_file/file_service.dart';
import '../../core/storage/language_repo.dart';
import '../../core/storage/supported_language.dart';

enum SDKState { inProgress, ready, notReady }

class AppPageVM {
  late final LanguageRepo languageRepo = LanguageRepo();
  late final FileServiceInterface fileService = FileService(languageRepo);
  late final ImportFileServiceInterface importFileService = ImportFileService(
    languageRepo,
  );
  late final PagesServiceInterface pagesService = PagesService();

  ValueNotifier<bool> inProgress = ValueNotifier(false);

  void setUp() async {
    inProgress.value = true;

    EventService.idle(msg: 'Initializing...');

    _setListeners();

    await languageRepo.setUp();

    final language = await languageRepo.getSelectedLanguage();

    if (language != null) {
      EventService.emit(type: EventType.languageChanged, data: language);
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

            importFileService.importAppFile(
              importedFile: AppFile.newFile(language: data),
            );
          }
        });

    EventService.instance.stream
        .where((event) => event.type == EventType.importedFile)
        .listen((event) async {
          final importedFile = event.data as AppFile;

          EventService.emit(
            type: EventType.languageChanged,
            data: importedFile.language,
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
            EventService.success(msg: 'Success');
          }
        });

    PlatformFileOpenChannel.channel.setMethodCallHandler((call) async {
      if (call.method == 'file_open') {
        final path = call.arguments as String;
        importFileService.importFile(file: File(path));
      }
    });
  }

  void _setLanguage(SupportedLanguage language) {
    switch (language.supported) {
      case LanguageSupport.upcoming:
        EventService.warning(msg: 'Upcoming support');
        break;
      case LanguageSupport.supported:
        try {
          EventService.success(msg: 'Ready');
        } catch (e, s) {
          EventService.error(
            msg: e.toString(),
            error: AppError(object: e, stackTrace: s),
          );
        }
        break;
      default:
        EventService.error(msg: 'Not supported');
    }
  }
}
