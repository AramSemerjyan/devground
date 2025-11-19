import 'dart:convert';

import 'package:dartpad_lite/core/services/ai/ai_mock.dart';
import 'package:dartpad_lite/core/services/ai/ai_provider_info.dart';
import 'package:dartpad_lite/core/services/ai/remote/ai_network_response.dart';
import 'package:dio/dio.dart';

import '../ai_provider.dart';
import '../ai_provider_error.dart';
import '../ai_response.dart';

class AINetworkProvider implements AIProviderInterface {
  final String _apiKey;
  late final Dio _dio;

  late final request = '''
  curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent" 
  -H 'Content-Type: application/json' 
  -H 'X-goog-api-key: AIzaSyDbZsNwbliBc7ZbqEH4nLvlH5PoDhTG_GA' 
  -X POST 
  -d '{
    "contents": [
      {
        "parts": [
          {
            "text": "Explain how AI works in a few words"
          }
        ]
      }
    ]
  }'
  ''';

  @override
  AIProviderInfo get providerInfo => AIProviderInfo(name: 'gemini-2.0-flash');

  AINetworkProvider(this._apiKey) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://generativelanguage.googleapis.com/v1beta/models/',
      ),
    );
  }

  /// Generate content using Gemini model
  /// [model] example: 'gemini-2.5-flash'
  /// [text] is the prompt to generate content for
  @override
  Stream<AIResponse> generateContent({
    required String text,
    bool mock = false,
  }) async* {
    if (mock) {
      await Future.delayed(const Duration(seconds: 1));
      yield AIMockResponse();
      return;
    }

    try {
      if (_apiKey.isEmpty) {
        throw AIMissingApiKeyError();
      }

      final header = {
        'Content-Type': 'application/json',
        'x-goog-api-key': _apiKey,
      };

      // Here you could split text or receive partial results if your API supports it
      // For now, we simulate streaming by sending the full response in one chunk
      final response = await _dio.post(
        'gemini-2.0-flash:generateContent',
        data: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": text},
              ],
            },
          ],
        }),
        options: Options(headers: header),
      );

      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          logPrint: print, // You can customize this
        ),
      );

      if (response.statusCode == 200) {
        // If the API returns a stream of tokens, you would yield them one by one
        // Example: yield each token as AIProviderResponse
        final remoteResponse = AIRemoteResponse.fromJson(response.data);

        yield remoteResponse;
      } else {
        throw AIRequestFailedError(
          'Failed to generate content: ${response.statusCode}',
        );
      }
    } catch (e) {
      // You can emit an error into the stream
      // `yield* Stream.error(e)` would also work
      throw AIRequestFailedError(e.toString());
    }
  }
}
