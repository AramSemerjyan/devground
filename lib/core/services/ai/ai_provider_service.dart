import 'package:dartpad_lite/core/services/ai/ai_local_provider.dart';
import 'package:dartpad_lite/core/services/ai/ai_network_provider.dart';
import 'package:dartpad_lite/core/services/ai/ai_provider.dart';

abstract class AiProviderServiceInterface {
  AIProviderInterface get provider;

  Future<void> loadFromFile({required String modelPath});
  Future<void> loadRemote({required String apiKey});
}

class AIProviderService implements AiProviderServiceInterface {
  @override
  late AIProviderInterface _provider;

  @override
  AIProviderInterface get provider => _provider;

  AIProviderService._internal();
  static final AIProviderService instance = AIProviderService._internal();

  @override
  Future<void> loadFromFile({required String modelPath}) async {
    _provider = AILocalProvider(modelPath);
  }

  @override
  Future<void> loadRemote({required String apiKey}) async {
    _provider = AINetworkProvider(apiKey);
  }
}
