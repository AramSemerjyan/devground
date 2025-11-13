import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/services/event_service.dart';

class AiHelperPage extends StatefulWidget {
  const AiHelperPage({super.key});

  @override
  State<AiHelperPage> createState() => _AiHelperPageState();
}

class _AiHelperPageState extends State<AiHelperPage> {
  late final _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..addJavaScriptChannel(
      'ResultChannel',
      onMessageReceived: (message) {
        try {
          final msg = jsonDecode(message.message) as Map<String, dynamic>;
          handleWebMessage(msg);
        } catch (e) {
          EventService.error(title: e.toString());
        }
      },
    );

  Future<void> handleWebMessage(Map<String, dynamic> msg) async {
    final action = msg['action'] as String?;
    if (action == 'clicked') {
      EventService.event(type: EventType.monacoDropFocus);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller.loadRequest(
      Uri.parse('https://chatgpt.com/?hints=search&ref=ext'),
    );

    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) async {
          await _controller.runJavaScript('''
              document.addEventListener('click', function() {
                ResultChannel.postMessage(JSON.stringify({'action': 'clicked'}));
              });
            ''');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
