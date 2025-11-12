import 'package:dartpad_lite/UI/editor/result_web_view.dart';
import 'package:dartpad_lite/services/event_service.dart';
import 'package:dartpad_lite/storage/supported_language.dart';
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

  Widget _buildDefaultConsole(String data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: SelectableText(
        data,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black,
      body: StreamBuilder(
        stream: EventService.instance.stream.where(
          (e) => e.type == EventType.languageChanged,
        ),
        builder: (c, eventStream) {
          return StreamBuilder(
            stream: widget.outputStream,
            builder: (context, snapshot) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _resultText.value = snapshot.data;
              });
              final data = eventStream.data?.data as SupportedLanguage?;

              if (data == null) return Container();

              if (data.key == SupportedLanguageType.html) {
                return ResultWebView(filePath: snapshot.data ?? '');
              }

              return _buildDefaultConsole(snapshot.data ?? '');
            },
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
