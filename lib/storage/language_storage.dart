import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LanguageStorageInterface {
  Future<Map<String, String>> getSelectedLanguage();
  Future<Map<int, String>> getSupportedLanguages();
  Future<void> setSelectedLanguage({
    required String language,
    required String sdkPath,
  });
}

class LanguageStorage implements LanguageStorageInterface {
  static const _selectedSdkKey = 'selected_sdk';
  static const _sdkPathKey = 'sdk_path';
  Map<int, String>? _supportedLanguages;

  @override
  Future<Map<String, String>> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedSdkString = prefs.getString(_selectedSdkKey);

    if (selectedSdkString == null) return {'dart': ''};

    return jsonDecode(selectedSdkString);
  }

  Future<Map<String, String>> getSDKPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final sdkPathsString = prefs.getString(_sdkPathKey);

    if (sdkPathsString == null) return {};

    return jsonDecode(sdkPathsString);
  }

  @override
  Future<Map<int, String>> getSupportedLanguages() async {
    if (_supportedLanguages != null) return _supportedLanguages!;

    final jsonString = await rootBundle.loadString(
      'assets/supported_languages.json',
    );
    final Map<int, String> data = json.decode(jsonString);
    return data;
  }

  @override
  Future<void> setSelectedLanguage({
    required String language,
    required String sdkPath,
  }) async {
    final paths = await getSDKPaths();
    paths[language] = sdkPath;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sdkPathKey, jsonEncode(paths));
  }
}
