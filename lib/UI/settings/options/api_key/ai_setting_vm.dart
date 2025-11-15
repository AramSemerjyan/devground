import 'package:dartpad_lite/core/services/event_service.dart';
import 'package:dartpad_lite/core/storage/ai_repo.dart';
import 'package:flutter/material.dart';

enum AIType {
  local('local'),
  remote('remote');

  final String value;

  const AIType(this.value);

  static AIType fromString(String? value) {
    switch (value) {
      case 'local':
        return AIType.local;
      default:
        return AIType.remote;
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

  @override
  final TextEditingController apiKeyController = TextEditingController();
  @override
  final ValueNotifier<bool> saveButtonEnabled = ValueNotifier(false);

  Future<void> fetchSettings() async {
    final type = await _aiRepo.getType();
  }

  @override
  Future<void> getApiKey() async {
    final apiKey = await _aiRepo.getApiKey();

    apiKeyController.text = apiKey ?? '';
  }

  @override
  Future<void> setApiKey(String key) async {
    await _aiRepo.setApiKey(key);

    EventService.success(msg: 'API Set');
  }
}
