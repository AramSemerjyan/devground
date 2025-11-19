import 'package:dartpad_lite/UI/editor/editor/language_editor/real_monaco_editor/real_monaco_editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RealmMonacoEditor extends StatelessWidget {
  final RealMonacoEditorController monacoController;
  const RealmMonacoEditor({super.key, required this.monacoController});

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: monacoController.controller);
  }
}
