abstract class AIProviderInterface {
  Future<AIProviderResponse?> generateContent({
    required String text,
    bool mock = false,
  });
}

class AIProviderResponse {
  final dynamic data;

  AIProviderResponse({this.data});
}
