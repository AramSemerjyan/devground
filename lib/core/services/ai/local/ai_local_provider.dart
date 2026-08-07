import 'dart:async';

import 'package:dartpad_lite/core/platform_channel/app_platform_channel.dart';
import 'package:dartpad_lite/core/services/ai/ai_response.dart';
import 'package:dartpad_lite/core/services/ai/local/ai_local_response.dart';
import 'package:dartpad_lite/core/storage/supported_language.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

import '../ai_provider.dart';
import '../ai_provider_error.dart';
import '../ai_provider_info.dart';
import 'ai_local_conversation_state.dart';

class AILocalProvider implements AIProviderInterface {
  final String path;
  final int contextLimit;
  final SupportedLanguage? language;
  late final ConversationState conversation = ConversationState(contextLimit);

  @override
  AIProviderInfo get providerInfo => AIProviderInfo(name: basename(path));

  AILocalProvider(this.path, this.contextLimit, this.language);

  @override
  Stream<AIResponse?> generateContent({
    required String text,
    bool mock = false,
  }) async* {
    if (path.isEmpty) {
      throw AIModelPathMissingError();
    }

    if (conversation.messages.isEmpty && language != null) {
      text =
          '$text\nprefered file type: ${language!.extension}, prefered programming language: ${language!.name}';
    }

    // Add user message to the conversation history
    conversation.addUserMessage(text);

    final thinkBuffer = StringBuffer();
    bool inThinkBlock = false;
    String wholeText = "";
    bool isDone = false;

    void emitToken(String token) {
      if (token.startsWith("<think>")) {
        inThinkBlock = true;
        thinkBuffer.write(token.replaceFirst("<think>", "").trim());
      } else if (token.endsWith("</think>")) {
        // End of thinking block, add to bot response and clear buffer.
        thinkBuffer.write(token.replaceFirst("</think>", "").trim());
        conversation.addBotResponse(thinkBuffer.toString().trim());
        thinkBuffer.clear();
        inThinkBlock = false;
      } else {
        if (inThinkBlock) {
          // Accumulate thinking tokens.
          thinkBuffer.write(token);
        } else {
          // Regular result tokens.
          wholeText += token;
        }
      }
    }

    try {
      // Start generation with the entire context.
      await PlatformLlamaChannel.method.invokeMethod("startGeneration", {
        'modelPath': path,
        'messages': conversation.messages,
      });

      // Listen to raw events and validate token type ourselves.
      final tokenStream = PlatformLlamaChannel.stream.receiveBroadcastStream();

      await for (final event in tokenStream) {
        if (event is! String) continue;

        final token = event;
        final trimmed = token.trim();

        if (trimmed == "__done__") {
          conversation.addBotResponse(wholeText.trim());
          yield AILocalResponse(isDone: true);
          isDone = true;
          break;
        }

        if (token.contains("__done__")) {
          final content = token.replaceAll("__done__", "");
          if (content.isNotEmpty) {
            final wasInThinkBlock = inThinkBlock;
            emitToken(content);
            if (wasInThinkBlock ||
                content.startsWith("<think>") ||
                content.endsWith("</think>")) {
              yield AILocalResponse(think: content, isThinking: true);
            } else {
              yield AILocalResponse(think: null, result: content);
            }
          }

          conversation.addBotResponse(wholeText.trim());
          yield AILocalResponse(isDone: true);
          isDone = true;
          break;
        }

        final wasInThinkBlock = inThinkBlock;
        emitToken(token);
        if (wasInThinkBlock ||
            token.startsWith("<think>") ||
            token.endsWith("</think>")) {
          yield AILocalResponse(think: token, isThinking: true);
        } else {
          yield AILocalResponse(think: null, result: token);
        }
      }

      if (!isDone) {
        if (wholeText.trim().isNotEmpty) {
          conversation.addBotResponse(wholeText.trim());
          yield AILocalResponse(isDone: true);
        } else {
          throw AIRequestFailedError(
            "Generation ended unexpectedly without completion token.",
          );
        }
      }
    } on PlatformException catch (e) {
      throw AIRequestFailedError(
        e.message?.trim().isNotEmpty == true ? e.message! : e.code,
      );
    } on TimeoutException catch (e) {
      throw AIRequestFailedError(e.message ?? "Generation timed out.");
    }
  }
}

class LlamaService {
  static Stream<String> generate({
    required String modelPath,
    required List<Map<String, String>> messages,
  }) async* {
    await PlatformLlamaChannel.method.invokeMethod('startGeneration', {
      'modelPath': modelPath,
      'messages': messages,
    });

    yield* PlatformLlamaChannel.stream.receiveBroadcastStream().cast<String>();
  }
}
