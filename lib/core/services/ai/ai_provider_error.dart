abstract class AIProviderError implements Exception {
  final String message;
  AIProviderError(this.message);

  @override
  String toString() => "AIProviderError: $message";
}

class AIInvalidApiKeyError extends AIProviderError {
  AIInvalidApiKeyError() : super("The provided API key is invalid.");
}

class AIMissingApiKeyError extends AIProviderError {
  AIMissingApiKeyError() : super("No API key was provided.");
}

class AIModelPathMissingError extends AIProviderError {
  AIModelPathMissingError() : super("Model path missing");
}

class AIModelNotFoundError extends AIProviderError {
  AIModelNotFoundError(String model)
    : super("The model '$model' was not found.");
}

class AIRequestFailedError extends AIProviderError {
  AIRequestFailedError(super.message);
}

class AIRateLimitError extends AIProviderError {
  final int? retryAfterSeconds;
  final String? quotaMetric;

  AIRateLimitError({
    required String message,
    this.retryAfterSeconds,
    this.quotaMetric,
  }) : super(message);

  @override
  String toString() {
    final buffer = StringBuffer('AIRateLimitError: $message');
    if (retryAfterSeconds != null) {
      buffer.write(' (Retry after ${retryAfterSeconds}s)');
    }
    if (quotaMetric != null) {
      buffer.write(' [Quota: $quotaMetric]');
    }
    return buffer.toString();
  }
}
