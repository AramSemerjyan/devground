import 'package:dartpad_lite/core/storage/sp_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../UI/settings/options/ai_section/ai_setting_vm.dart';

abstract class AIRepoInterface {
  Future<AIType> getType();
  Future<void> setType(String key);
  Future<String?> getApiKey();
  Future<void> setApiKey(String key);
  Future<String?> getModelPath();
  Future<void> setModelPath(String path);
}

class AIRepo implements AIRepoInterface {
  @override
  Future<AIType> getType() async {
    final prefs = await SharedPreferences.getInstance();
    final type = prefs.getString(SPAIKeys.type.value);
    return AIType.fromString(type);
  }

  @override
  Future<void> setType(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPAIKeys.type.value, key);
  }

  @override
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPAIKeys.apiKey.value);
  }

  @override
  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPAIKeys.apiKey.value, key);
  }

  @override
  Future<String?> getModelPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPAIKeys.modelPath.value);
  }

  @override
  Future<void> setModelPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPAIKeys.modelPath.value, path);
  }
}
