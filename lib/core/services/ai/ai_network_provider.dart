import 'dart:convert';

import 'package:dartpad_lite/core/services/ai/ai_mock.dart';
import 'package:dio/dio.dart';

import 'ai_provider.dart';
import 'ai_provider_error.dart';

class AINetworkProvider implements AIProviderInterface {
  final String _apiKey;
  late final Dio _dio;

  late final request = '''
  curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent" \
  -H 'Content-Type: application/json' \
  -H 'X-goog-api-key: AIzaSyDbZsNwbliBc7ZbqEH4nLvlH5PoDhTG_GA' \
  -X POST \
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
  Future<AIProviderResponse> generateContent({
    required String text,
    bool mock = false,
  }) async {
    if (mock) {
      // response.candidates.first.content.parts.first.text
      await Future.delayed(const Duration(seconds: 1));
      return AIProviderResponse(
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': withCodeResponse},
                ],
              },
            },
          ],
        },
      );
    }

    try {
      if (_apiKey.isEmpty) {
        throw AIMissingApiKeyError();
      }

      final header = {
        'Content-Type': 'application/json',
        'x-goog-api-key': _apiKey,
      };

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

      if (response.statusCode == 200) {
        return AIProviderResponse(data: response.data);
      } else {
        throw AIRequestFailedError(
          'Failed to generate content: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw AIRequestFailedError(e.toString());
    }
  }
}
