import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../core/storage/supported_language.dart';
import '../language_editor_controller.dart';

class RealMonacoEditorController implements LanguageEditorControllerInterface {
  late final WebViewController controller;

  @override
  NavigationDecision Function(NavigationRequest)? onNavigationRequest;

  @override
  Future<void> setUp() async {
    final completer = Completer<void>();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // onNavigationRequest: (request) {
          //   if (onNavigationRequest != null) {
          //     return onNavigationRequest!.call(request);
          //   }
          //   // Allow only the initial HTML load
          //   if (request.url.startsWith('data:text/html') ||
          //       request.url == 'about:blank') {
          //     return NavigationDecision.navigate;
          //   }
          //   return NavigationDecision.prevent;
          // },
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
  }

  Future<void> handleEditorMessage(Map<String, dynamic> msg) async {}

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
    final result = await controller.runJavaScriptReturningResult(
      'window.editor.getValue()',
    );
    // The result may be wrapped in quotes, so clean it up if needed
    if (result is String) {
      return result;
    }
    return result.toString();
  }

  @override
  Future<void> runCode() async {
    await controller.runJavaScript('window.runEditorCode();');
  }

  @override
  Future<void> setLanguage({required SupportedLanguage language}) async {
    final jsLang = language.key.value;
    await controller.runJavaScript('window.setEditorLanguage("$jsLang");');
    await setCode(code: language.snippet);
  }

  @override
  Future<void> setCode({required String code}) async {
    final codeJson = jsonEncode(code);
    await controller.runJavaScript(
      'window.postMessageToEditor({type:"replaceCode", payload:$codeJson});',
    );
  }

  @override
  Future<void> reload() async {
    final monacoPath = await copyMonacoAssetsToLocalDir();

    final html = await rootBundle.loadString('assets/monaco_editor.html');

    await controller.loadHtmlString(html, baseUrl: 'file://$monacoPath/');
  }

  @override
  Future<void> dropFocus() async {
    await controller.runJavaScript('document.activeElement?.blur();');
  }

  @override
  Future<void> debug() async {
    await controller.runJavaScript(
      'window.postMessageToEditor({type:"setDiagnostics"});',
    );
  }

  Future<String> copyMonacoAssetsToLocalDir() async {
    final directory = await getApplicationSupportDirectory();
    final monacoDir = Directory('${directory.path}/monaco');

    if (!monacoDir.existsSync()) {
      monacoDir.createSync(recursive: true);

      // Copy assets/monaco/** files
      final assetManifest = await rootBundle.loadString('AssetManifest.json');
      final Map manifestMap = jsonDecode(assetManifest);

      for (final assetPath in manifestMap.keys) {
        if (assetPath.startsWith('assets/monaco/')) {
          try {
            final data = await rootBundle.load(assetPath);
            final file = File('${directory.path}/$assetPath');
            file.parent.createSync(recursive: true);
            file.createSync();
            file.writeAsBytesSync(data.buffer.asUint8List());
          } catch (e) {
            print(e);
          }
        }
      }

      // Copy monaco_editor.html
      final htmlData = await rootBundle.loadString('assets/monaco_editor.html');
      File('${monacoDir.path}/monaco_editor.html').writeAsStringSync(htmlData);
    }

    return monacoDir.path;
  }
}
