import 'package:dartpad_lite/services/event_service.dart';
import 'package:dartpad_lite/storage/language_repo.dart';
import 'package:dartpad_lite/storage/supported_language.dart';
import 'package:flutter/cupertino.dart';

abstract class BottomToolBarVMInterface {
  ValueNotifier<SupportedLanguage?> get selectedLanguage;

  Future<Map<SupportedLanguageType, SupportedLanguage>> getSupportedLanguages();
  Future<void> selectLanguage({required SupportedLanguage language});
}

class BottomToolBarVM implements BottomToolBarVMInterface {
  final LanguageRepoInterface _languageRepo;

  BottomToolBarVM(this._languageRepo);

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
    EventService.instance.onEvent.add(
      Event(type: EventType.languageChanged, data: language),
    );
  }
}
