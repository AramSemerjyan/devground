import 'package:dartpad_lite/core/services/ai/ai_local_provider.dart';
import 'package:dartpad_lite/core/services/ai/ai_network_provider.dart';
import 'package:dartpad_lite/core/services/ai/ai_provider.dart';

class AIProviderFactory {
  static AIProviderInterface localProvider({required String modelPath}) {
    return AILocalProvider(modelPath);
  }

  static AIProviderInterface remoteProvider({required String apiKey}) {
    return AINetworkProvider(apiKey);
  }
}
