import 'package:flutter/material.dart';

import '../../../../../utils/app_colors.dart';

class UseChatBubble extends StatefulWidget {
  final String text;
  final int maxLength;

  const UseChatBubble({super.key, required this.text, this.maxLength = 200});

  @override
  State<UseChatBubble> createState() => _UseChatBubbleState();
}

class _UseChatBubbleState extends State<UseChatBubble> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.text.length > widget.maxLength;
    final displayText = !_isExpanded && isLong
        ? '${widget.text.substring(0, widget.maxLength)}...'
        : widget.text;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColor.mainGreyBlack,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              displayText,
              style: TextStyle(color: AppColor.mainGreyLighter),
            ),
            if (isLong)
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _isExpanded ? 'Show less' : 'Show more',
                    style: TextStyle(
                      color: AppColor.lightBlue.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
