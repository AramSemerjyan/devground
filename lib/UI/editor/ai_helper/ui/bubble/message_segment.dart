class MessageSegment {
  final String text;
  final bool isCode;

  MessageSegment({required this.text, this.isCode = false});

  static List<MessageSegment> parseAiResponse(String response) {
    final segments = <MessageSegment>[];
    final regex = RegExp(r'```(.*?)```', dotAll: true); // matches ```code```
    int lastIndex = 0;

    for (final match in regex.allMatches(response)) {
      if (match.start > lastIndex) {
        // Add normal text before code
        segments.add(
          MessageSegment(
            text: response.substring(lastIndex, match.start).trim(),
            isCode: false,
          ),
        );
      }

      // Add code segment
      segments.add(MessageSegment(text: match.group(1)!.trim(), isCode: true));

      lastIndex = match.end;
    }

    // Add remaining text after last code block
    if (lastIndex < response.length) {
      segments.add(
        MessageSegment(
          text: response.substring(lastIndex).trim(),
          isCode: false,
        ),
      );
    }

    return segments;
  }
}
