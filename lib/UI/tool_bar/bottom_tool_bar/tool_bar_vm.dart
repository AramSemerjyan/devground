import 'package:dartpad_lite/core/services/ai/ai_provider_info.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/services/ai/ai_provider_service.dart';
import '../../../core/services/event_service/event_service.dart';
import '../../../core/services/import_file/imported_file.dart';
import '../../../core/storage/language_repo.dart';
import '../../../core/storage/supported_language.dart';

abstract class BottomToolBarVMInterface {
  ValueNotifier<SupportedLanguage?> get selectedLanguage;
  AIProviderInfo get aiProviderInfo;

  Future<Map<SupportedLanguageType, SupportedLanguage>> getSupportedLanguages();
  Future<void> selectLanguage({required SupportedLanguage language});
}

class BottomToolBarVM implements BottomToolBarVMInterface {
  final LanguageRepoInterface _languageRepo;
  late final AiProviderServiceInterface _aiProviderService =
      AIProviderService.instance;

  @override
  AIProviderInfo get aiProviderInfo => _aiProviderService.provider.providerInfo;

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
    EventService.emit(
      type: EventType.languageChanged,
      data: AppFile.newFile(language: language),
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
