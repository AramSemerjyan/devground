import 'package:dartpad_lite/core/services/ai/ai_provider_info.dart';

import 'ai_response.dart';

abstract class AIProviderInterface {
  AIProviderInfo get providerInfo;

  Stream<AIResponse?> generateContent({
    required String text,
    bool mock = false,
  });
}
