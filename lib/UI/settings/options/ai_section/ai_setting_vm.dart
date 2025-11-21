import 'package:dartpad_lite/UI/command_palette/command_palette.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/event_service/event_service.dart';
import '../../../../core/storage/ai_repo.dart';

enum AIType implements CommandPaletteItem {
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

  @override
  String get itemName => value;
}

class AISettings {
  final AIType type;
  final String apiKey;
  final String modelPath;

  AISettings({
    this.type = AIType.remote,
    this.apiKey = '',
    this.modelPath = '',
  });

  AISettings copy({AIType? type, String? apiKey, String? modelPath}) {
    return AISettings(
      type: type ?? this.type,
      apiKey: apiKey ?? this.apiKey,
      modelPath: modelPath ?? this.modelPath,
    );
  }
}

abstract class AISettingVMInterface {
  TextEditingController get apiKeyController;
  ValueNotifier<bool> get saveButtonEnabled;
  ValueNotifier<AISettings> get onSettingsUpdate;

  Future<void> fetchAISettings();
  Future<void> setApiKey(String key);
  Future<void> setAIType(AIType type);
  Future<void> setModelPath(String path);
}

class AISettingVM implements AISettingVMInterface {
  final AIRepoInterface _aiRepo = AIRepo();

  @override
  final TextEditingController apiKeyController = TextEditingController();
  @override
  final ValueNotifier<bool> saveButtonEnabled = ValueNotifier(false);
  @override
  ValueNotifier<AISettings> onSettingsUpdate = ValueNotifier(AISettings());

  @override
  Future<void> fetchAISettings() async {
    final type = await _aiRepo.getType();
    final apiKey = await _aiRepo.getApiKey();
    final modelPath = await _aiRepo.getModelPath();

    apiKeyController.text = apiKey ?? '';

    onSettingsUpdate.value = AISettings(
      type: type,
      apiKey: apiKey ?? '',
      modelPath: modelPath ?? '',
    );
  }

  @override
  Future<void> setApiKey(String key) async {
    await _aiRepo.setApiKey(key);

    EventService.success(msg: 'API Set');

    onSettingsUpdate.value = onSettingsUpdate.value.copy(apiKey: key);
  }

  @override
  Future<void> setAIType(AIType type) async {
    _aiRepo.setType(type.value);

    onSettingsUpdate.value = onSettingsUpdate.value.copy(type: type);
  }

  @override
  Future<void> setModelPath(String path) async {
    await _aiRepo.setModelPath(path);

    EventService.success(msg: 'Model path Set');

    onSettingsUpdate.value = onSettingsUpdate.value.copy(modelPath: path);
  }
}
