import 'dart:async';
import 'dart:convert';

import 'package:dartpad_lite/services/event_service.dart';
import 'package:dartpad_lite/storage/supported_language.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

abstract class MonacoWebBridgeServiceInterface {
  WebViewController get controller;

  Function(String)? onRunCode;
  Function(String)? onFormatCode;

  Future<void> setUp();
  Future<void> formatCode();
  Future<void> runCode();
  Future<String> getValue();
  Future<void> setLanguage({required SupportedLanguage language});
  Future<void> setCode({required String code});
  Future<void> reload();
  Future<void> dropFocus();
  Future<void> debug();
}

class MonacoWebBridgeService implements MonacoWebBridgeServiceInterface {
  @override
  late final WebViewController controller;

  @override
  Future<void> setUp() async {
    final completer = Completer<void>();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // Block all navigation except for the initial loaded HTML
            if (request.url.startsWith('data:text/html') ||
                request.url == 'about:blank') {
              return NavigationDecision.navigate;
            }
            // Otherwise, prevent navigation
            return NavigationDecision.prevent;
          },
          onPageFinished: (_) {
            if (!completer.isCompleted) completer.complete();
          },
          onWebResourceError: (error) {
            if (!completer.isCompleted) {
              completer.completeError(
                Exception('Failed to load HTML: ${error.description}'),
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
    await completer.future;

    EventService.instance.stream
        .where((e) => e.type == EventType.monacoDropFocus)
        .listen((event) {
          dropFocus();
        });
  }

  @override
  Function(String)? onRunCode;

  @override
  Function(String)? onFormatCode;

  Future<void> handleEditorMessage(Map<String, dynamic> msg) async {
    final type = msg['type'] as String?;
    if (type == 'run') {
      final code = msg['code'] as String? ?? '';
      onRunCode?.call(code);
    } else if (type == 'format') {
      final code = msg['code'] as String? ?? '';
      onFormatCode?.call(code);
    } else {
      sendStatus('Unknown message type: $type');
    }
  }

  Future<void> sendStatus(String s) async {
    final payload = jsonEncode({'type': 'status', 'payload': s});
    controller.runJavaScript(
      'window.postMessageToEditor(${jsonEncode(payload)});',
    );
  }

  @override
  Future<void> formatCode() async {
    await controller.runJavaScript('window.formatEditorCode();');
  }

  @override
  Future<String> getValue() async {
    return await controller.runJavaScriptReturningResult(
          'window.editor.getValue()',
        )
        as String;
  }

  @override
  Future<void> runCode() async {
    await controller.runJavaScript('window.runEditorCode();');
  }

  @override
  Future<void> setLanguage({required SupportedLanguage language}) async {
    final jsLang = language.key.value;
    await controller.runJavaScript('setEditorLanguage("$jsLang");');

    setCode(code: language.snippet);
  }

  @override
  Future<void> setCode({required String code}) async {
    final codeJson = jsonEncode(code);
    await controller.runJavaScript(
      'postMessageToEditor({type:"replaceCode", payload:$codeJson});',
    );
  }

  @override
  Future<void> reload() async {
    final html = await rootBundle.loadString('assets/index.html');

    return await controller.loadHtmlString(html);
  }

  @override
  Future<void> dropFocus() async {
    return await controller.runJavaScript('document.activeElement?.blur();');
  }

  @override
  Future<void> debug() async {
    await controller.runJavaScript(
      'postMessageToEditor({type:"setDiagnostics"});',
    );
  }
}
