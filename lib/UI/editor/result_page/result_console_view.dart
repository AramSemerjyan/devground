import 'package:dartpad_lite/UI/common/floating_progress_button.dart';
import 'package:dartpad_lite/UI/editor/result_page/result_web_view.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/storage/supported_language.dart';

class ResultView extends StatefulWidget {
  final SupportedLanguage language;
  final Stream<String> outputStream;
  final bool enableInput;
  final Function(String)? onInput;

  const ResultView({
    super.key,
    required this.outputStream,
    required this.language,
    this.onInput,
    this.enableInput = false,
  });

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  final _controller = TextEditingController();

  ValueNotifier<String> onInputChange = ValueNotifier('');

  Widget _buildDefaultConsole() {
    return StreamBuilder(
      stream: widget.outputStream,
      builder: (_, value) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: SelectableText(
                value.data ?? '',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
            if (widget.enableInput)
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(height: 1, color: AppColor.mainGreyDark),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          hint: Text(
                            'Input...',
                            style: TextStyle(color: AppColor.mainGrey),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          suffix: ValueListenableBuilder(
                            valueListenable: onInputChange,
                            builder: (_, value, __) {
                              if (value.isEmpty) return SizedBox();

                              return IconButton(
                                icon: Icon(Icons.send, color: AppColor.blue),
                                onPressed: () {
                                  widget.onInput?.call(value);
                                  _controller.clear();
                                },
                              );
                            },
                          ),
                        ),
                        onChanged: (input) {
                          onInputChange.value = input;
                        },
                        style: TextStyle(color: AppColor.mainGreyLighter),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black,
      body: switch (widget.language.key) {
        SupportedLanguageKey.html => ResultWebView(
          outputStream: widget.outputStream,
        ),
        SupportedLanguageKey.json => ResultWebView(
          outputStream: widget.outputStream,
        ),
        SupportedLanguageKey.xml => ResultWebView(
          outputStream: widget.outputStream,
        ),
        _ => _buildDefaultConsole(),
      },
      floatingActionButton: StreamBuilder(
        stream: widget.outputStream,
        builder: (_, value) {
          final data = value.data;

          if (data != null && data.isNotEmpty) {
            return Padding(
              padding: widget.enableInput
                  ? EdgeInsets.only(bottom: 60)
                  : EdgeInsets.zero,
              child: FloatingProgressButton(
                heroTag: 'copyBtn',
                tooltip: 'Copy',
                mini: true,
                icon: Icons.copy,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: data));
                },
              ),
            );
          }

          return Container();
        },
      ),
    );
  }
}
