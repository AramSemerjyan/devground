import 'package:dartpad_lite/UI/editor/result_page/result_web_view.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/storage/supported_language.dart';

class ResultView extends StatefulWidget {
  final SupportedLanguage language;
  final Stream<String> outputStream;

  const ResultView({
    super.key,
    required this.outputStream,
    required this.language,
  });

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  Widget _buildDefaultConsole() {
    return StreamBuilder(
      stream: widget.outputStream,
      builder: (_, value) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: SelectableText(
            value.data ?? '',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black,
      body: switch (widget.language.key) {
        SupportedLanguageType.html => ResultWebView(
          outputStream: widget.outputStream,
        ),
        SupportedLanguageType.json => ResultWebView(
          outputStream: widget.outputStream,
        ),
        SupportedLanguageType.xml => ResultWebView(
          outputStream: widget.outputStream,
        ),
        _ => _buildDefaultConsole(),
      },
      floatingActionButton: StreamBuilder(
        stream: widget.outputStream,
        builder: (_, value) {
          final data = value.data;

          if (data != null && data.isNotEmpty) {
            return FloatingActionButton(
              heroTag: 'copyBtn',
              tooltip: 'Copy',
              mini: true,
              child: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: data));
              },
            );
          }

          return Container();
        },
      ),
    );
  }
}
