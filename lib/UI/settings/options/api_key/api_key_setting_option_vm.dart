import 'package:dartpad_lite/core/services/event_service.dart';
import 'package:flutter/material.dart';

import '../../../../core/storage/cred_repo.dart';

abstract class ApiKeySettingOptionVMInterface {
  TextEditingController get apiKeyController;
  ValueNotifier<bool> get saveButtonEnabled;

  Future<void> getApiKey();
  Future<void> setApiKey(String key);
}

class ApiKeySettingOptionVM implements ApiKeySettingOptionVMInterface {
  final CredRepoInterface _credRepo = CredRepo();

  @override
  final TextEditingController apiKeyController = TextEditingController();
  @override
  final ValueNotifier<bool> saveButtonEnabled = ValueNotifier(false);

  @override
  Future<void> getApiKey() async {
    final apiKey = await _credRepo.getAIApiKey();

    apiKeyController.text = apiKey ?? '';
  }

  @override
  Future<void> setApiKey(String key) async {
    await _credRepo.setAIApiKey(key);

    EventService.event(type: EventType.success, title: 'API Set');
  }
}
