import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'local_monaco_editor_controller.dart';

class LocalMonacoEditor extends StatelessWidget {
  final LocalMonacoEditorController monacoController;
  const LocalMonacoEditor({super.key, required this.monacoController});

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: monacoController.controller);
  }
}
