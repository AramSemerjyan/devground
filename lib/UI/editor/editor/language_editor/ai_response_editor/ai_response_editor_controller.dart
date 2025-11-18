import 'package:dartpad_lite/UI/editor/editor/language_editor/language_editor_controller.dart';
import 'package:dartpad_lite/core/storage/supported_language.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AIResponseEditorController implements LanguageEditorControllerInterface {
  ValueNotifier<String?> onCodeSet = ValueNotifier(null);

  @override
  NavigationDecision Function(NavigationRequest p1)? onNavigationRequest;

  @override
  Future<void> debug() {
    // TODO: implement debug
    throw UnimplementedError();
  }

  @override
  Future<void> dropFocus() async {}

  @override
  Future<void> formatCode() {
    // TODO: implement formatCode
    throw UnimplementedError();
  }

  @override
  Future<String> getValue() {
    // TODO: implement getValue
    throw UnimplementedError();
  }

  @override
  Future<void> reload() {
    // TODO: implement reload
    throw UnimplementedError();
  }

  @override
  Future<void> runCode() {
    // TODO: implement runCode
    throw UnimplementedError();
  }

  @override
  Future<void> setCode({required String code}) async {
    onCodeSet.value = code;
  }

  @override
  Future<void> setLanguage({required SupportedLanguage language}) async {}

  @override
  Future<void> setUp() async {}
}
