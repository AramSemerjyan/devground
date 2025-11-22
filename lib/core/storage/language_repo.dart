import 'dart:convert';

import 'package:dartpad_lite/core/storage/sp_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'supported_language.dart';

abstract class LanguageRepoInterface {
  ValueNotifier<SupportedLanguage?> get selectedLanguage;

  Future<void> setSelectedLanguage({required SupportedLanguageKey key});
  Future<Map<SupportedLanguageKey, SupportedLanguage>> getSupportedLanguages();
  Future<Map<SupportedLanguageKey, SupportedLanguage>> getAllLanguages();
  Future<String> getPathForLanguage({required SupportedLanguageKey key});
  Future<SupportedLanguage?> setLanguagePath({
    required SupportedLanguageKey key,
    required String path,
  });
  Future<Map<SupportedLanguageKey, String?>> getSDKPaths();
}

class LanguageRepo implements LanguageRepoInterface {
  Map<SupportedLanguageKey, SupportedLanguage>? _supportedLanguages;
  Map<SupportedLanguageKey, String?> _sdkPaths = {};
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
  Future<void> setSelectedLanguage({required SupportedLanguageKey key}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPKeys.selectedSdkKey.value, key.value);

    getSelectedLanguage(key: key.value);
  }

  Future<SupportedLanguage?> getSelectedLanguage({String? key}) async {
    if (_selectedLanguage.value != null && key == null) {
      return _selectedLanguage.value!;
    }

    final prefs = await SharedPreferences.getInstance();
    final languageKey = prefs.getString(SPKeys.selectedSdkKey.value);
    _selectedLanguage.value =
        _supportedLanguages?[SupportedLanguageKey.fromString(
          languageKey ?? key ?? 'dart',
        )];

    return _selectedLanguage.value!;
  }

  @override
  Future<Map<SupportedLanguageKey, String?>> getSDKPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final sdkPathsString = prefs.getString(SPKeys.sdkPathKey.value);

    if (sdkPathsString == null) return {};

    final decoded = jsonDecode(sdkPathsString);

    // Explicit cast to Map<String, String?>
    final Map<SupportedLanguageKey, String?> paths = (decoded as Map).map(
      (key, value) => MapEntry(
        SupportedLanguageKey.fromString(key as String),
        value as String?,
      ),
    );

    _sdkPaths = paths;
    return _sdkPaths;
  }

  @override
  Future<Map<SupportedLanguageKey, SupportedLanguage>>
  getSupportedLanguages() async {
    final languages = await getAllLanguages();
    return languages.entries
        .where((e) => e.value.type != SupportedLanguageType.custom)
        .fold<Map<SupportedLanguageKey, SupportedLanguage>>({}, (
          previousValue,
          element,
        ) {
          previousValue[element.key] = element.value;
          return previousValue;
        });
  }

  @override
  Future<Map<SupportedLanguageKey, SupportedLanguage>> getAllLanguages() async {
    if (_supportedLanguages != null) return _supportedLanguages!;

    final jsonString = await rootBundle.loadString(
      'assets/supported_languages.json',
    );
    final List<Map<String, dynamic>> mapList = (jsonDecode(jsonString) as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    _supportedLanguages = {};
    for (var e in mapList) {
      _supportedLanguages?[SupportedLanguageKey.fromString(e['key'])] =
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
  Future<String> getPathForLanguage({required SupportedLanguageKey key}) {
    return Future.value(_sdkPaths[key]);
  }

  @override
  Future<SupportedLanguage?> setLanguagePath({
    required SupportedLanguageKey key,
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
    await prefs.setString(SPKeys.sdkPathKey.value, encoded);

    // Update in-memory language
    SupportedLanguage? language = _supportedLanguages?[key];
    if (language != null) {
      language = language.addSDKPath(path);
      _supportedLanguages?[key] = language;
    }

    if (language?.key == _selectedLanguage.value?.key) {
      _selectedLanguage.value = language;
    }

    return language;
  }
}
