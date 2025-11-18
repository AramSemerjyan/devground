import 'package:dartpad_lite/UI/editor/ai_helper/ai_helper_vm.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/app_colors.dart';
import '../response_parser/gpt_markdown.dart';

class AiChatBubble extends StatefulWidget {
  final AIBotChatMessage message;
  final Function(String)? onCodeReplace;
  final Function(AIBotChatMessage)? onFullResponseSave;

  const AiChatBubble({
    super.key,
    required this.message,
    this.onCodeReplace,
    this.onFullResponseSave,
  });

  @override
  State<AiChatBubble> createState() => _AiChatBubbleState();
}

class _AiChatBubbleState extends State<AiChatBubble> {
  bool _isThinkExpanded = false;

  Widget _buildThinkCollapsed() {
    return InkWell(
      onTap: () => setState(() => _isThinkExpanded = true),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColor.mainGrey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: AppColor.mainGreyLighter, width: 4),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.chevron_right, size: 16, color: Colors.white54),
            const SizedBox(width: 4),
            Text("Think", style: TextStyle(color: AppColor.mainGreyLighter)),
          ],
        ),
      ),
    );
  }

  Widget _buildThinkExpanded(String content) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      onTap: () => setState(() => _isThinkExpanded = false),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.mainGrey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: AppColor.mainGreyLighter, width: 4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.expand_more, size: 16, color: Colors.white54),
            const SizedBox(width: 4),
            Expanded(
              child: GptMarkdown(
                content,
                style: const TextStyle(color: AppColor.mainGreyLighter),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThinkLive() {
    return StreamBuilder(
      stream: widget.message.thinkStream!.stream,
      builder: (_, s) {
        final data = s.data;
        if (data == null) return const SizedBox();

        // While thinking → show ONLY expanded version
        return _buildThinkExpanded(data);
      },
    );
  }

  Widget _buildThinkFinal() {
    final full = widget.message.fullThink;
    if (full == null) return SizedBox();

    if (!_isThinkExpanded) {
      return _buildThinkCollapsed();
    }

    return _buildThinkExpanded(full);
  }

  Widget _buildResult() {
    return StreamBuilder(
      stream: widget.message.chunkStream!.stream,
      builder: (_, s) {
        final data = s.data;
        if (data == null) return SizedBox();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.mainGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: GptMarkdown(
            data,
            style: const TextStyle(color: AppColor.mainGreyLighter),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.isThinking) {
      return _buildThinkLive();
    }

    if (widget.message.isDone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message.shouldShowThink) _buildThinkFinal(),
          _buildDone(),
        ],
      );
    }

    return _buildResult();
  }

  Widget _buildDone() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColor.mainGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: GptMarkdown(
              widget.message.fullResponse,
              style: const TextStyle(color: AppColor.mainGreyLighter),
              onCodeReplaceTap: (code) {
                widget.onCodeReplace?.call(code);
              },
            ),
          ),
          Row(
            children: [
              Spacer(),
              Tooltip(
                message: 'Save response as file',
                child: InkWell(
                  onTap: () {
                    widget.onFullResponseSave?.call(widget.message);
                  },
                  child: Icon(
                    Icons.save_rounded,
                    color: AppColor.mainGreyLighter,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
