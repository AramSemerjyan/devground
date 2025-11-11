import 'dart:async';

import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResultConsolePage extends StatefulWidget {
  final Stream<String> outputStream;

  const ResultConsolePage({super.key, required this.outputStream});

  @override
  State<ResultConsolePage> createState() => _ResultConsolePageState();
}

class _ResultConsolePageState extends State<ResultConsolePage> {
  final ValueNotifier<String?> _resultText = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black,
      body: StreamBuilder<String>(
        stream: widget.outputStream,
        builder: (context, snapshot) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _resultText.value = snapshot.data;
          });
          return SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: SelectableText(
              snapshot.data ?? '',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          );
        },
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _resultText,
        builder: (_, value, __) {
          if (value != null && value.isNotEmpty) {
            return FloatingActionButton(
              heroTag: 'copyBtn',
              tooltip: 'Copy',
              mini: true,
              child: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
              },
            );
          }

          return Container();
        },
      ),
    );
  }
}
