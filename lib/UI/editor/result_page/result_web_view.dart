import 'dart:async';
import 'dart:convert';

import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/services/event_service.dart';

class ResultWebView extends StatefulWidget {
  final Stream<String> outputStream;

  const ResultWebView({super.key, required this.outputStream});

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

  final List<StreamSubscription> _subscriptions = [];

  final ValueNotifier<bool> _showNavBar = ValueNotifier(false);

  String homePath = '';

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
      color: AppColor.mainGreyDark.withValues(alpha: 0.8),
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

    final sub = widget.outputStream.where((path) => path.isNotEmpty).listen((
      path,
    ) {
      homePath = path;

      webViewController.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            _showNavBar.value = request.url != 'file://$path';

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

      webViewController.loadFile(path);
    });

    _subscriptions.add(sub);

    rootBundle.loadString('assets/blank_html.html').then((html) {
      webViewController.loadHtmlString(html);
    });
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ResultWebView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (homePath.isNotEmpty) {
      webViewController.loadFile(homePath);
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
