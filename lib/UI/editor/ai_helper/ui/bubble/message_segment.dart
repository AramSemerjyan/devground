class MessageSegment {
  final String text;
  final bool isCode;
  final String? language;

  MessageSegment({required this.text, this.isCode = false, this.language});

  /// Parse AI response into text and code segments
  static List<MessageSegment> parseAiResponse(String response) {
    final segments = <MessageSegment>[];
    // Match ```language\ncode...```
    final regex = RegExp(r'```(\w+)?\n([\s\S]*?)```'); // multi-line safe
    int lastIndex = 0;

    for (final match in regex.allMatches(response)) {
      if (match.start > lastIndex) {
        // Add normal text before code
        final plainText = response.substring(lastIndex, match.start).trim();
        if (plainText.isNotEmpty) {
          segments.add(MessageSegment(text: plainText, isCode: false));
        }
      }

      // Extract language and code body
      final language = match.group(1)?.trim();
      final code = match.group(2)?.trim() ?? '';

      segments.add(
        MessageSegment(text: code, isCode: true, language: language),
      );

      lastIndex = match.end;
    }

    // Add remaining text after last code block
    if (lastIndex < response.length) {
      final remaining = response.substring(lastIndex).trim();
      if (remaining.isNotEmpty) {
        segments.add(MessageSegment(text: remaining, isCode: false));
      }
    }

    return segments;
  }

  /// ✅ Returns code only (without language)
  String get codeOnly => isCode ? text : '';

  /// ✅ Returns formatted code with language for display if needed
  String get formattedCode => isCode ? '(${language ?? 'plain'})\n$text' : text;
}
