import 'ai_provider.dart';
import 'ai_provider_error.dart';
import 'ai_provider_info.dart';

class AILocalProvider implements AIProviderInterface {
  final String path;

  /// TODO: add modal name
  @override
  AIProviderInfo get providerInfo => AIProviderInfo(name: 'model_name');

  AILocalProvider(this.path);

  @override
  Future<AIProviderResponse?> generateContent({
    required String text,
    bool mock = false,
  }) async {
    if (path.isEmpty) {
      throw AIModelPathMissingError();
    }

    // TODO: implement generateContent
    throw UnimplementedError();
  }
}
