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
  final _scrollController = ScrollController();
  final ValueNotifier<String> onInputChange = ValueNotifier('');
  var _lastOutput = '';

  late final _inputFieldFocus = FocusNode(
    onKeyEvent: (FocusNode node, KeyEvent evt) {
      if (evt.logicalKey == LogicalKeyboardKey.enter) {
        if (evt is KeyDownEvent) {
          _onSend();
        }
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
  );
  late final _resultFieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _inputFieldFocus.addListener(_onInputChange);
    _resultFieldFocus.addListener(_onResultChange);
  }

  @override
  void dispose() {
    _inputFieldFocus.removeListener(_onInputChange);
    _resultFieldFocus.removeListener(_onResultChange);
    _inputFieldFocus.dispose();
    _resultFieldFocus.dispose();
    _scrollController.dispose();
    _controller.dispose();
    onInputChange.dispose();
    super.dispose();
  }

  void _onInputChange() {
    if (_inputFieldFocus.hasFocus) {
      EventService.emit(type: EventType.dropEditorFocus);
    }
  }

  void _onResultChange() {
    if (_resultFieldFocus.hasFocus) {
      EventService.emit(type: EventType.dropEditorFocus);
    }
  }

  void _onSend() {
    final raw = _controller.text;
    widget.onInput?.call(raw.isEmpty ? '\n' : '$raw\n');
    _controller.clear();
    onInputChange.value = '';
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Widget _buildDefaultConsole() {
    return StreamBuilder<CompilerResult>(
      stream: widget.outputStream,
      builder: (_, stream) {
        final compilerResult = stream.data;
        final output = compilerResult?.data?.toString() ?? '';
        final isError =
            compilerResult?.status == CompilerResultStatus.error ||
            compilerResult?.error != null;

        if (output != _lastOutput) {
          _lastOutput = output;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }

        return Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                8,
                8,
                8,
                widget.enableInput ? 58 : 8,
              ),
              child: SelectableText(
                output,
                focusNode: _resultFieldFocus,
                style: TextStyle(
                  color: isError ? Colors.redAccent : Colors.greenAccent,
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
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          Text(
                            '>',
                            style: TextStyle(
                              color: AppColor.mainGreyLighter,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _inputFieldFocus,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                hintText: 'Input...',
                                hintStyle: TextStyle(color: AppColor.mainGrey),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                suffix: ValueListenableBuilder<String>(
                                  valueListenable: onInputChange,
                                  builder: (_, value, __) {
                                    if (value.isEmpty) {
                                      return const SizedBox();
                                    }

                                    return IconButton(
                                      icon: Icon(
                                        Icons.send,
                                        color: AppColor.blue,
                                      ),
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
                          ),
                        ],
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
      floatingActionButton: StreamBuilder<CompilerResult>(
        stream: widget.outputStream,
        builder: (_, stream) {
          final output = stream.data?.data?.toString() ?? '';
          if (output.isEmpty) return Container();

          return Padding(
            padding: widget.enableInput
                ? const EdgeInsets.only(bottom: 60)
                : EdgeInsets.zero,
            child: FloatingProgressButton(
              heroTag: 'copyBtn',
              tooltip: 'Copy',
              mini: true,
              icon: Icons.copy,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: output));
              },
            ),
          );
        },
      ),
    );
  }
}
