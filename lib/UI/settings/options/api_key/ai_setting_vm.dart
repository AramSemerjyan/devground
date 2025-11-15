import 'package:dartpad_lite/core/services/event_service.dart';
import 'package:dartpad_lite/core/storage/ai_repo.dart';
import 'package:flutter/material.dart';

import '../../../../core/storage/cred_repo.dart';

enum AIType {
  local('local'),
  remote('remote');

  final String value;

  const AIType(this.value);

  static AIType fromString(String? value) {
    switch (value) {
      case 'remote':
        return AIType.remote;
      default:
        return AIType.local;
    }
  }
}

abstract class AISettingVMInterface {
  TextEditingController get apiKeyController;
  ValueNotifier<bool> get saveButtonEnabled;

  Future<void> getApiKey();
  Future<void> setApiKey(String key);
}

class AISettingVM implements AISettingVMInterface {
  final AIRepoInterface _aiRepo = AIRepo();
  final CredRepoInterface _credRepo = CredRepo();

  @override
  final TextEditingController apiKeyController = TextEditingController();
  @override
  final ValueNotifier<bool> saveButtonEnabled = ValueNotifier(false);

  Future<void> fetchSettings() async {
    final type = AIType.fromString(await _aiRepo.getAIType());
  }

  @override
  Future<void> getApiKey() async {
    final apiKey = await _credRepo.getAIApiKey();

    apiKeyController.text = apiKey ?? '';
  }

  @override
  Future<void> setApiKey(String key) async {
    await _credRepo.setAIApiKey(key);

    EventService.success(msg: 'API Set');
  }
}
