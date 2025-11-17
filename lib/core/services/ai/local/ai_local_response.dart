import 'package:dartpad_lite/core/services/ai/ai_response.dart';

class AILocalResponse implements AIResponse {
  final String? result;
  final String? think;

  @override
  final bool isDone;
  @override
  final bool isThinking;

  AILocalResponse({
    this.result,
    this.think,
    this.isDone = false,
    this.isThinking = false,
  });

  @override
  String get responseText => result ?? '';

  @override
  String get thinkingText => think ?? '';

  @override
  bool get shouldShowThink => true;
}
