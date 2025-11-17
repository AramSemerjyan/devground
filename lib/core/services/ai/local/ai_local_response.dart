import 'package:dartpad_lite/core/services/ai/ai_response.dart';

class AILocalResponse implements AIResponse {
  final String? result;
  final String? think;

  AILocalResponse({this.result, this.think});

  @override
  String? get responseText => result;
}
