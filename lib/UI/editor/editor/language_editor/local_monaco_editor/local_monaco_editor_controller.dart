import 'dart:async';
import 'dart:convert';

import 'package:dartpad_lite/UI/editor/editor/language_editor/language_editor_controller.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../core/storage/supported_language.dart';

class LocalMonacoEditorController implements LanguageEditorControllerInterface {
  late final WebViewController controller;
  Completer<void>? _pageReadyCompleter;
  Completer<void>? _editorReadyCompleter;
  SupportedLanguage? _currentLanguage;

  @override
  NavigationDecision Function(NavigationRequest)? onNavigationRequest;

  @override
  void Function(String)? editorFocusedCallback;
  @override
  void Function(String)? editorBlurredCallback;

  @override
  String uuid = Uuid().v4();

  @override
  Future<void> setUp() async {
    _resetLoadState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (onNavigationRequest != null) {
              return onNavigationRequest!.call(request);
            }

            // Block all navigation except for the initial loaded HTML
            if (request.url.startsWith('data:text/html') ||
                request.url == 'about:blank') {
              return NavigationDecision.navigate;
            }
            // Otherwise, prevent navigation
            return NavigationDecision.prevent;
          },
          onPageFinished: (_) {
            if (_pageReadyCompleter?.isCompleted == false) {
              _pageReadyCompleter!.complete();
            }
          },
          onWebResourceError: (error) {
            if (_pageReadyCompleter?.isCompleted == false) {
              _pageReadyCompleter!.completeError(
                Exception('Failed to load HTML: ${error.description}'),
              );
            }
            if (_editorReadyCompleter?.isCompleted == false) {
              _editorReadyCompleter!.completeError(
                Exception('Failed to load editor: ${error.description}'),
              );
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'EditorChannel',
        onMessageReceived: (message) async {
          try {
            final msg = jsonDecode(message.message) as Map<String, dynamic>;
            await handleEditorMessage(msg);
          } catch (e) {
            sendStatus("Invalid message: $e");
          }
        },
      );

    await reload();
  }

  Future<void> handleEditorMessage(Map<String, dynamic> msg) async {
    if (msg['type'] == 'editorReady') {
      if (_editorReadyCompleter?.isCompleted == false) {
        _editorReadyCompleter!.complete();
      }
      return;
    }

    if (msg['type'] == 'editorFocused') {
      editorFocusedCallback?.call(uuid);
      return;
    }

    if (msg['type'] == 'editorBlurred') {
      editorBlurredCallback?.call(uuid);
      return;
    }
  }

  Future<void> sendStatus(String s) async {
    await _waitUntilReady();
    final payload = jsonEncode({'type': 'status', 'payload': s});
    await controller.runJavaScript(
      'window.postMessageToEditor(${jsonEncode(payload)});',
    );
  }

  @override
  Future<void> formatCode() async {
    await _waitUntilReady();
    await controller.runJavaScript('window.formatEditorCode();');
  }

  @override
  Future<String> getValue() async {
    await _waitUntilReady();
    final result = await controller.runJavaScriptReturningResult(
      'window.getEditorValue();',
    );
    if (result is String) return result;
    return result.toString();
  }

  @override
  Future<void> runCode() async {
    await _waitUntilReady();
    await controller.runJavaScript('window.runEditorCode();');
  }

  @override
  Future<void> setLanguage({required SupportedLanguage language}) async {
    await _waitUntilReady();
    final jsLang = language.key.monacoKey;
    await controller.runJavaScript('window.setEditorLanguage("$jsLang");');

    await setCode(code: language.snippet);
    _currentLanguage = language;
  }

  @override
  Future<SupportedLanguage?> getLanguage() async {
    return _currentLanguage;
  }

  @override
  Future<void> setCode({required String code}) async {
    await _waitUntilReady();
    final codeJson = jsonEncode(code);
    await controller.runJavaScript(
      'window.postMessageToEditor({type:"replaceCode", payload:$codeJson});',
    );
  }

  @override
  Future<void> reload() async {
    _resetLoadState();
    final html = await rootBundle.loadString('assets/index.html');

    await controller.loadHtmlString(html);
    await _waitUntilReady();
  }

  @override
  Future<void> dropFocus() async {
    await _waitUntilReady();
    return await controller.runJavaScript('document.activeElement?.blur();');
  }

  @override
  Future<void> debug() async {
    await _waitUntilReady();
    await controller.runJavaScript(
      'window.postMessageToEditor({type:"setDiagnostics"});',
    );
  }

  void _resetLoadState() {
    _pageReadyCompleter = Completer<void>();
    _editorReadyCompleter = Completer<void>();
  }

  Future<void> _waitUntilReady() async {
    await _pageReadyCompleter?.future;
    await _editorReadyCompleter?.future;
  }
}
