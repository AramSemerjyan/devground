import 'dart:convert';

import 'package:dartpad_lite/core/services/event_service.dart';
import 'package:dio/dio.dart';

import 'ai_response.dart';

class AIHelperChatMessage {
  final String text;
  final bool isUser;

  AIHelperChatMessage({required this.text, required this.isUser});
}

abstract class AIHelperNetworkServiceInterface {
  Future<AIResponse?> generateContent({required String text});
}

class AiHelperNetworkService implements AIHelperNetworkServiceInterface {
  late final Dio _dio;

  final request = '''
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

  AiHelperNetworkService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://generativelanguage.googleapis.com/v1beta/models/',
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': 'AIzaSyDbZsNwbliBc7ZbqEH4nLvlH5PoDhTG_GA',
        },
      ),
    );
  }

  /// Generate content using Gemini model
  /// [model] example: 'gemini-2.5-flash'
  /// [text] is the prompt to generate content for
  @override
  Future<AIResponse?> generateContent({required String text}) async {
    try {
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
      );

      if (response.statusCode == 200) {
        final aiResponse = AIResponse.fromJson(response.data);

        return aiResponse;
      } else {
        EventService.error(
          title: 'Failed to generate content: ${response.statusCode}',
        );

        return null;
      }
    } catch (e) {
      EventService.error(title: e.toString());
      return null;
    }
  }
}
