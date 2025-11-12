import 'dart:convert';

import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/event_service.dart';

class ResultWebView extends StatefulWidget {
  final String filePath;

  const ResultWebView({super.key, required this.filePath});

  @override
  State<ResultWebView> createState() => _ResultWebViewState();
}

class _ResultWebViewState extends State<ResultWebView> {
  late final webViewController = WebViewController()
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

  final ValueNotifier<bool> _showNavBar = ValueNotifier(false);

  Future<void> handleWebMessage(Map<String, dynamic> msg) async {
    final action = msg['action'] as String?;
    if (action == 'clicked') {
      EventService.event(type: EventType.monacoDropFocus);
    }
  }

  Widget _buildNavigationBar() {
    return Container(
      height: 40,
      width: double.infinity,
      color: AppColor.mainGreyDarker.withValues(alpha: 0.8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Tooltip(
            message: 'Back',
            child: InkWell(
              onTap: () async {
                if (await webViewController.canGoBack()) {
                  webViewController.goBack();
                }
              },
              child: Icon(
                Icons.navigate_before_sharp,
                color: AppColor.mainGreyLighter,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Tooltip(
            message: 'Next',
            child: InkWell(
              onTap: () async {
                if (await webViewController.canGoForward()) {
                  webViewController.goForward();
                }
              },
              child: Icon(
                Icons.navigate_next_sharp,
                color: AppColor.mainGreyLighter,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Tooltip(
            message: 'Reload',
            child: InkWell(
              onTap: () async {
                webViewController.reload();
              },
              child: Icon(Icons.refresh, color: AppColor.mainGreyLighter),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    webViewController.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) {
          _showNavBar.value = request.url != 'file://${widget.filePath}';

          return NavigationDecision.navigate;
        },
        onPageFinished: (url) async {
          await webViewController.runJavaScript('''
              document.addEventListener('click', function() {
                ResultChannel.postMessage(JSON.stringify({'action': 'clicked'}));
              });
            ''');
        },
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ResultWebView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filePath.isNotEmpty) {
      webViewController.loadFile(widget.filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: webViewController)),
          ValueListenableBuilder<bool>(
            valueListenable: _showNavBar,
            builder: (_, value, __) {
              if (value) {
                return _buildNavigationBar();
              }
              return SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
