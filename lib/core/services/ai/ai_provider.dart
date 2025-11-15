import 'package:dartpad_lite/core/services/ai/ai_provider_info.dart';

abstract class AIProviderInterface {
  AIProviderInfo get providerInfo;

  Future<AIProviderResponse?> generateContent({
    required String text,
    bool mock = false,
  });
}

class AIProviderResponse {
  final dynamic data;

  AIProviderResponse({this.data});
}
