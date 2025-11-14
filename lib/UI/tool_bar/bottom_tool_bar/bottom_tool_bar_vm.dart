import 'package:flutter/cupertino.dart';

import '../../../core/services/event_service.dart';
import '../../../core/storage/language_repo.dart';
import '../../../core/storage/supported_language.dart';

abstract class BottomToolBarVMInterface {
  ValueNotifier<SupportedLanguage?> get selectedLanguage;

  Future<Map<SupportedLanguageType, SupportedLanguage>> getSupportedLanguages();
  Future<void> selectLanguage({required SupportedLanguage language});
}

class BottomToolBarVM implements BottomToolBarVMInterface {
  final LanguageRepoInterface _languageRepo;

  BottomToolBarVM(this._languageRepo) {
    _setListeners();
  }

  @override
  ValueNotifier<SupportedLanguage?> get selectedLanguage =>
      _languageRepo.selectedLanguage;

  @override
  Future<Map<SupportedLanguageType, SupportedLanguage>>
  getSupportedLanguages() {
    return _languageRepo.getSupportedLanguages();
  }

  @override
  Future<void> selectLanguage({required SupportedLanguage language}) async {
    await _languageRepo.setSelectedLanguage(key: language.key);
    EventService.instance.emit(
      Event(type: EventType.languageChangedForNewFile, data: language),
    );
  }

  void _setListeners() {
    EventService.instance.stream
        .where((e) => e.type == EventType.languageChanged)
        .map((event) => event.data as SupportedLanguage?)
        .where((l) => l != null)
        .listen((language) {
          selectedLanguage.value = language;
        });
  }
}
