import 'dart:io';

import 'package:dartpad_lite/services/event_service.dart';
import 'package:dartpad_lite/storage/language_repo.dart';
import 'package:flutter/cupertino.dart';

import '../../storage/supported_language.dart';

abstract class SettingsPageVMInterface {
  ValueNotifier<SupportedLanguage?> get selectedLanguage;

  Future<Map<SupportedLanguageType, SupportedLanguage>> getSupportedLanguages();
  Future<void> setSDKPath({
    required SupportedLanguage language,
    required String sdkPath,
  });
}

class SettingsPageVM implements SettingsPageVMInterface {
  final LanguageRepoInterface _languageStorage;

  late final ValueNotifier<SupportedLanguage?> _selectedLanguage =
      ValueNotifier(_languageStorage.selectedLanguage.value);

  @override
  ValueNotifier<SupportedLanguage?> get selectedLanguage => _selectedLanguage;

  SettingsPageVM(this._languageStorage);

  @override
  Future<Map<SupportedLanguageType, SupportedLanguage>>
  getSupportedLanguages() {
    return _languageStorage.getSupportedLanguages();
  }

  @override
  Future<void> setSDKPath({
    required SupportedLanguage language,
    required String sdkPath,
  }) async {
    sdkPath = sdkPath.trim();
    if (sdkPath.isEmpty) {
      EventService.instance.emit(Event.error(title: 'Path cannot be empty.'));
      return;
    }

    if (language.path.validation.isNotEmpty) {
      final flutterBin = File('$sdkPath${language.path.validation}');
      if (!await flutterBin.exists()) {
        EventService.instance.emit(Event.error(title: 'Invalid SDK path.'));
        return;
      }
    }

    try {
      final updatedLang = await _languageStorage.setLanguagePath(
        key: language.key,
        path: sdkPath,
      );
      _selectedLanguage.value = updatedLang;
      EventService.instance.emit(
        Event(type: EventType.sdkPathUpdated, data: updatedLang),
      );
    } catch (e) {
      EventService.instance.emit(Event.error(title: e.toString()));
    }
  }
}
