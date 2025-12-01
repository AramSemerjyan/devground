import 'package:dartpad_lite/UI/common/floating_progress_button.dart';
import 'package:dartpad_lite/UI/editor/result_page/result_web_view.dart';
import 'package:dartpad_lite/core/services/compiler/compiler_result.dart';
import 'package:dartpad_lite/core/services/event_service/event_service.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/storage/supported_language.dart';

class ResultView extends StatefulWidget {
  final SupportedLanguage language;
  final Stream<CompilerResult> outputStream;
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

  @override
  void initState() {
    super.initState();

    _fieldFocus.addListener(_onChange);
  }

  @override
  void dispose() {
    _fieldFocus.removeListener(_onChange);
    _fieldFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChange() {
    if (_fieldFocus.hasFocus) {
      EventService.emit(type: EventType.dropEditorFocus);
    }
  }

  void _onSend() {
    widget.onInput?.call(_controller.text);
    _controller.clear();
  }

  ValueNotifier<String> onInputChange = ValueNotifier('');
  late final _fieldFocus = FocusNode(
    onKeyEvent: (FocusNode node, KeyEvent evt) {
      if (evt.logicalKey == LogicalKeyboardKey.enter) {
        if (evt is KeyDownEvent) {
          _onSend();
        }
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  Widget _buildDefaultConsole() {
    return StreamBuilder(
      stream: widget.outputStream,
      builder: (_, stream) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: SelectableText(
                stream.data?.data ?? '',
                style: TextStyle(
                  color: stream.data?.error != null ? Colors.redAccent : Colors.greenAccent,
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
                        focusNode: _fieldFocus,
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
                                onPressed: _onSend,
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
        builder: (_, stream) {
          final compilerResult = stream.data;

          if (compilerResult != null && compilerResult.data.isNotEmpty) {
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
                  Clipboard.setData(ClipboardData(text: compilerResult.data));
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
