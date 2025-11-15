import 'ai_provider.dart';
import 'ai_provider_error.dart';

class AILocalProvider implements AIProviderInterface {
  final String path;

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
