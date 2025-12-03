import 'package:flutter/cupertino.dart';

import '../../core/storage/compiler_repo.dart';
import '../../core/storage/supported_language.dart';

abstract class SettingsPageVMInterface {
  ValueNotifier<SupportedLanguage?> get selectedLanguage;

  Future<Map<SupportedLanguageKey, SupportedLanguage>> getSupportedLanguages();
}

class SettingsPageVM implements SettingsPageVMInterface {
  final CompilerRepoInterface _languageStorage;

  late final ValueNotifier<SupportedLanguage?> _selectedLanguage =
      ValueNotifier(_languageStorage.selectedLanguage.value);

  @override
  ValueNotifier<SupportedLanguage?> get selectedLanguage => _selectedLanguage;

  SettingsPageVM(this._languageStorage);

  @override
  Future<Map<SupportedLanguageKey, SupportedLanguage>> getSupportedLanguages() {
    return _languageStorage.getSupportedLanguages();
  }
}
