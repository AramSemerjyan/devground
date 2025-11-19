import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/services/event_service/app_error.dart';
import '../../../../core/services/event_service/event_service.dart';
import '../../../../core/storage/language_repo.dart';
import '../../../../core/storage/supported_language.dart';

abstract class LanguageSettingOptionVMInterface {
  ValueNotifier<SupportedLanguage?> get selectedLanguage;

  Future<Map<SupportedLanguageType, SupportedLanguage>> getSupportedLanguages();
  Future<void> setSDKPath({required String sdkPath});
}

class LanguageSettingOptionVM implements LanguageSettingOptionVMInterface {
  final LanguageRepoInterface _languageStorage;

  late final ValueNotifier<SupportedLanguage?> _selectedLanguage =
      ValueNotifier(_languageStorage.selectedLanguage.value);

  @override
  ValueNotifier<SupportedLanguage?> get selectedLanguage => _selectedLanguage;

  LanguageSettingOptionVM(this._languageStorage);

  @override
  Future<Map<SupportedLanguageType, SupportedLanguage>>
  getSupportedLanguages() {
    return _languageStorage.getSupportedLanguages();
  }

  @override
  Future<void> setSDKPath({required String sdkPath}) async {
    final language = _selectedLanguage.value;

    if (language == null) return;

    sdkPath = sdkPath.trim();
    if (sdkPath.isEmpty) {
      EventService.error(msg: 'Path cannot be empty.');
      return;
    }

    if (language.path.validation.isNotEmpty) {
      final flutterBin = File('$sdkPath${language.path.validation}');
      if (!await flutterBin.exists()) {
        EventService.error(msg: 'Invalid SDK path.');
        return;
      }
    }

    try {
      final updatedLang = await _languageStorage.setLanguagePath(
        key: language.key,
        path: sdkPath,
      );
      _selectedLanguage.value = updatedLang;
      EventService.emit(type: EventType.sdkPathUpdated, data: updatedLang);
    } catch (e, s) {
      EventService.error(
        msg: e.toString(),
        error: AppError(object: e, stackTrace: s),
      );
    }
  }
}
