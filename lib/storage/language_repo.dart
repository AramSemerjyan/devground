import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'supported_language.dart';

abstract class LanguageRepoInterface {
  ValueNotifier<SupportedLanguage?> get selectedLanguage;

  Future<void> setSelectedLanguage({required SupportedLanguageType key});
  Future<Map<SupportedLanguageType, SupportedLanguage>> getSupportedLanguages();
  Future<String> getPathForLanguage({required SupportedLanguageType key});
  Future<SupportedLanguage?> setLanguagePath({
    required SupportedLanguageType key,
    required String path,
  });
  Future<Map<SupportedLanguageType, String?>> getSDKPaths();
}

class LanguageRepo implements LanguageRepoInterface {
  static const _selectedSdkKey = 'selected_sdk';
  static const _sdkPathKey = 'sdk_path';

  Map<SupportedLanguageType, SupportedLanguage>? _supportedLanguages;
  Map<SupportedLanguageType, String?> _sdkPaths = {};
  final ValueNotifier<SupportedLanguage?> _selectedLanguage = ValueNotifier(
    null,
  );

  @override
  ValueNotifier<SupportedLanguage?> get selectedLanguage => _selectedLanguage;

  Future<void> setUp() async {
    await getSDKPaths();
    await getSupportedLanguages();
    await getSelectedLanguage();
  }

  @override
  Future<void> setSelectedLanguage({required SupportedLanguageType key}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedSdkKey, key.value);

    getSelectedLanguage(key: key.value);
  }

  Future<SupportedLanguage?> getSelectedLanguage({String? key}) async {
    if (_selectedLanguage.value != null && key == null) {
      return _selectedLanguage.value!;
    }

    final prefs = await SharedPreferences.getInstance();
    final languageKey = prefs.getString(_selectedSdkKey);
    _selectedLanguage.value =
        _supportedLanguages?[SupportedLanguageType.fromString(
          languageKey ?? key ?? 'dart',
        )];

    return _selectedLanguage.value!;
  }

  @override
  Future<Map<SupportedLanguageType, String?>> getSDKPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final sdkPathsString = prefs.getString(_sdkPathKey);

    if (sdkPathsString == null) return {};

    final decoded = jsonDecode(sdkPathsString);

    // Explicit cast to Map<String, String?>
    final Map<SupportedLanguageType, String?> paths = (decoded as Map).map(
      (key, value) => MapEntry(
        SupportedLanguageType.fromString(key as String),
        value as String?,
      ),
    );

    _sdkPaths = paths;
    return _sdkPaths;
  }

  @override
  Future<Map<SupportedLanguageType, SupportedLanguage>>
  getSupportedLanguages() async {
    if (_supportedLanguages != null) return _supportedLanguages!;

    final jsonString = await rootBundle.loadString(
      'assets/supported_languages.json',
    );
    final List<Map<String, dynamic>> mapList = (jsonDecode(jsonString) as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    _supportedLanguages = {};
    for (var e in mapList) {
      _supportedLanguages?[SupportedLanguageType.fromString(e['key'])] =
          SupportedLanguage.fromJson(e);
    }

    for (final langEntry in (_supportedLanguages ?? {}).entries) {
      final sdkPath = _sdkPaths[langEntry.key];

      if (sdkPath != null && sdkPath.isNotEmpty) {
        final lang = _supportedLanguages?[langEntry.key];
        if (lang != null) {
          _supportedLanguages?[langEntry.key] = lang.addSDKPath(sdkPath);
        }
      }
    }

    return _supportedLanguages!;
  }

  @override
  Future<String> getPathForLanguage({required SupportedLanguageType key}) {
    return Future.value(_sdkPaths[key]);
  }

  @override
  Future<SupportedLanguage?> setLanguagePath({
    required SupportedLanguageType key,
    required String path,
  }) async {
    // Load previous paths
    final paths = await getSDKPaths();

    // Update map
    paths[key] = path;

    // Convert enum-keyed map to string-keyed map
    final encoded = jsonEncode(paths.map((k, v) => MapEntry(k.toJson(), v)));

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sdkPathKey, encoded);

    // Update in-memory language
    final language = _supportedLanguages?[key];
    if (language != null) {
      _supportedLanguages?[key] = language.addSDKPath(path);
    }

    return language;
  }
}
