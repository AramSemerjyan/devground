import 'package:dartpad_lite/core/storage/sp_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AIRepoInterface {
  Future<String?> getAIType();
  Future<void> setAIType(String key);
}

class AIRepo implements AIRepoInterface {
  @override
  Future<String?> getAIType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPKeys.aiType.value);
  }

  @override
  Future<void> setAIType(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPKeys.aiType.value, key);
  }
}
