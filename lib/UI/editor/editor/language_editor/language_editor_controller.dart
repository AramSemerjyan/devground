import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/storage/supported_language.dart';

abstract class LanguageEditorControllerInterface {
  Future<void> setUp();
  Future<void> formatCode();
  Future<void> runCode();
  Future<String> getValue();
  Future<void> setLanguage({required SupportedLanguage language});
  Future<void> setCode({required String code});
  Future<void> reload();
  Future<void> dropFocus();
  Future<void> debug();

  NavigationDecision Function(NavigationRequest)? onNavigationRequest;
}
