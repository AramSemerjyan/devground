import 'package:dartpad_lite/UI/editor/ai_helper/ui/response_parser/gpt_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../utils/app_colors.dart';
import 'message_segment.dart';

class AiChatBubble extends StatelessWidget {
  final Function(String code)? moveToEditor;
  final MessageSegment segment;

  const AiChatBubble({super.key, required this.segment, this.moveToEditor});

  @override
  Widget build(BuildContext context) {
    if (segment.isCode) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 100),
              child: SelectableText(
                segment.formattedCode,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.greenAccent,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                spacing: 10,
                children: [
                  Tooltip(
                    message: 'Copy',
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: segment.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copied to clipboard'),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Replace editor code',
                    child: InkWell(
                      onTap: () {
                        moveToEditor?.call(segment.codeOnly);
                      },
                      child: const Icon(
                        Icons.move_up_sharp,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return GptMarkdown(
        segment.text,
        style: const TextStyle(color: AppColor.mainGreyLighter),
      );
      return SelectableText(
        segment.text,
        style: const TextStyle(color: Colors.white),
      );
    }
  }
}
