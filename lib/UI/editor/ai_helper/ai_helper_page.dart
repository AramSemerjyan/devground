import 'package:dartpad_lite/UI/editor/ai_helper/ui/bubble/chat_bubble.dart';
import 'package:dartpad_lite/UI/editor/ai_helper/ui/think_animation_view.dart';
import 'package:dartpad_lite/core/services/monaco_bridge_service/monaco_bridge_service.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';

import 'ai_herlper_vm.dart';
import 'ui/bubble/message_segment.dart';
import 'ui/response_parser/gpt_markdown.dart';

class AiHelperPage extends StatefulWidget {
  final MonacoWebBridgeServiceInterface monacoWebBridgeService;

  const AiHelperPage({super.key, required this.monacoWebBridgeService});

  @override
  State<AiHelperPage> createState() => _AiHelperPageState();
}

class _AiHelperPageState extends State<AiHelperPage> {
  late final AIHelperVMInterface _vm = AIHelperVM(
    widget.monacoWebBridgeService,
  );

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() async {
    _vm.generate(text: _controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ask Gemini',
          style: TextStyle(color: AppColor.mainGreyLighter),
        ),
        backgroundColor: AppColor.mainGrey,
      ),
      backgroundColor: AppColor.mainGreyDark,
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _vm.onMessagesUpdate,
              builder: (_, messages, __) {
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];

                    if (msg.isUser) {
                      return UseChatBubble(text: msg.text);
                    } else {
                      final segments = MessageSegment.parseAiResponse(msg.text);

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor.mainGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GptMarkdown(
                          msg.text,
                          onCodeReplaceTap: (code) {
                            _vm.moveToEditor(code: code);
                          },
                          style: const TextStyle(
                            color: AppColor.mainGreyLighter,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _vm.isLoading,
            builder: (_, isLoading, __) {
              if (!isLoading) return SizedBox();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ThinkingText(
                      text: 'Thinking',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColor.mainGreyLighter,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Row(
            spacing: 5,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: AppColor.mainGreyLighter),
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _vm.readFromEditor,
                builder: (_, value, __) {
                  return Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: value
                          ? AppColor.mainGreyDarker.withValues(alpha: 0.3)
                          : AppColor.mainGrey,
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                    child: GestureDetector(
                      onTap: () => _vm.readFromEditor.value = !value,
                      child: Tooltip(
                        message: 'Use editor code',
                        child: Icon(
                          Icons.edit_note,
                          color: AppColor.mainGreyLighter,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColor.mainGrey,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
                child: GestureDetector(
                  onTap: _sendMessage,
                  child: Tooltip(
                    message: 'Send message',
                    child: Icon(Icons.send, color: AppColor.mainGreyLighter),
                  ),
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ],
      ),
    );
  }
}
