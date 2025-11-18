import 'package:dartpad_lite/UI/editor/ai_helper/ai_state.dart';
import 'package:dartpad_lite/UI/editor/ai_helper/ui/bubble/ai_chat_bubble.dart';
import 'package:dartpad_lite/UI/editor/ai_helper/ui/bubble/user_chat_bubble.dart';
import 'package:dartpad_lite/UI/editor/ai_helper/ui/think_animation_view.dart';
import 'package:dartpad_lite/core/services/monaco_bridge_service/monaco_bridge_service.dart';
import 'package:dartpad_lite/core/services/save_file/file_service.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../../command_palette/command_palette.dart';
import 'ai_helper_vm.dart';

class AiHelperPage extends StatefulWidget {
  final MonacoWebBridgeServiceInterface monacoWebBridgeService;
  final FileServiceInterface fileService;

  const AiHelperPage({
    super.key,
    required this.monacoWebBridgeService,
    required this.fileService,
  });

  @override
  State<AiHelperPage> createState() => _AiHelperPageState();
}

class _AiHelperPageState extends State<AiHelperPage> {
  late final AIHelperVMInterface _vm = AIHelperVM(
    widget.monacoWebBridgeService,
    widget.fileService,
  );

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() async {
    _vm.generate(text: _controller.text.trim());
    _controller.clear();
  }

  void _fullResponseSave(AIMessage message) async {
    final name = await CommandPalette.showRename(context);

    _vm.fullFileSave(message: message, name: name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pair programming',
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
                  itemBuilder: (c, index) {
                    final msg = messages.toList()[index];

                    return Column(
                      key: ValueKey(msg.id),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UseChatBubble(text: msg.userMessage.text),
                        if (msg.response != null)
                          AiChatBubble(
                            message: msg.response!,
                            onCodeReplace: (code) =>
                                _vm.moveToEditor(code: code),
                            onFullResponseSave: (message) {
                              _fullResponseSave(msg);
                            },
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _vm.aiState,
            builder: (_, state, __) {
              if (state == AIState.idle || state == AIState.done) {
                return SizedBox();
              }

              switch (state) {
                case AIState.thinking:
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Row(
                      spacing: 5,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.account_tree_outlined,
                          size: 14,
                          color: Colors.white54,
                        ),
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
                case AIState.generating:
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Row(
                      spacing: 5,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.generating_tokens_outlined,
                          size: 14,
                          color: Colors.white54,
                        ),
                        ThinkingText(
                          text: 'Generating',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.mainGreyLighter,
                          ),
                        ),
                      ],
                    ),
                  );
                default:
                  return const SizedBox();
              }
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
