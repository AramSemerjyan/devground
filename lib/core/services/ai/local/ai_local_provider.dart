import 'dart:async';

import 'package:dartpad_lite/core/platform_channel/app_platform_channel.dart';
import 'package:dartpad_lite/core/services/ai/ai_response.dart';
import 'package:dartpad_lite/core/services/ai/local/ai_local_response.dart';
import 'package:path/path.dart';

import '../ai_provider.dart';
import '../ai_provider_error.dart';
import '../ai_provider_info.dart';
import 'ai_local_conversation_state.dart';

class AILocalProvider implements AIProviderInterface {
  final String path;
  final int contextLimit;
  late final ConversationState conversation = ConversationState(contextLimit);

  @override
  AIProviderInfo get providerInfo => AIProviderInfo(name: basename(path));

  AILocalProvider(this.path, this.contextLimit);

  @override
  Stream<AIResponse?> generateContent({
    required String text,
    bool mock = false,
  }) async* {
    if (path.isEmpty) {
      throw AIModelPathMissingError();
    }

    // Add user message to the conversation history
    conversation.addUserMessage(text);

    // Start generation with the entire context
    await PlatformLlamaChannel.method.invokeMethod("startGeneration", {
      'modelPath': path,
      'messages': conversation.messages,
    });

    // Listen to tokens
    final tokenStream = PlatformLlamaChannel.stream
        .receiveBroadcastStream()
        .cast<String>();

    final thinkBuffer = StringBuffer();
    bool inThinkBlock = false;
    String wholeText = "";

    await for (final token in tokenStream) {
      if (token == "__done__") {
        conversation.addBotResponse(wholeText.trim());
        yield AILocalResponse(isDone: true);
        break;
      }

      if (token.startsWith("<think>")) {
        inThinkBlock = true;
        thinkBuffer.write(token.replaceFirst("<think>", "").trim());
      } else if (token.endsWith("</think>")) {
        // End of thinking block, add to bot response and clear buffer
        thinkBuffer.write(token.replaceFirst("</think>", "").trim());
        conversation.addBotResponse(thinkBuffer.toString().trim());
        yield AILocalResponse(isThinking: true);
        thinkBuffer.clear();
        inThinkBlock = false;
      } else {
        if (inThinkBlock) {
          // Accumulate thinking tokens
          thinkBuffer.write(token);
          yield AILocalResponse(think: token, isThinking: true);
        } else {
          // Regular result tokens
          wholeText += token;
          yield AILocalResponse(think: null, result: token);
        }
      }
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
