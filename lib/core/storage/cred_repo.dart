import 'package:dartpad_lite/core/storage/sp_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CredRepoInterface {
  Future<String?> getAIApiKey();
  Future<void> setAIApiKey(String key);
}

class CredRepo implements CredRepoInterface {
  @override
  Future<String?> getAIApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPKeys.aiApiKey.value);
  }

  @override
  Future<void> setAIApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPKeys.aiApiKey.value, key);
  }
}
