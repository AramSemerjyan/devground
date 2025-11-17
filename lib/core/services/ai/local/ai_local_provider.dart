import 'dart:async';

import 'package:dartpad_lite/core/platform_channel/app_platform_channel.dart';
import 'package:dartpad_lite/core/services/ai/ai_response.dart';
import 'package:dartpad_lite/core/services/ai/local/ai_local_response.dart';
import 'package:path/path.dart';

import '../ai_provider.dart';
import '../ai_provider_error.dart';
import '../ai_provider_info.dart';

class AILocalProvider implements AIProviderInterface {
  final String path;

  Stream<String>? _tokenStream;

  @override
  AIProviderInfo get providerInfo => AIProviderInfo(name: basename(path));

  AILocalProvider(this.path);

  @override
  Stream<AIResponse?> generateContent({
    required String text,
    bool mock = false,
  }) async* {
    if (path.isEmpty) {
      throw AIModelPathMissingError();
    }

    // 1. Start generation
    await PlatformLlamaChannel.method.invokeMethod("startGeneration", {
      'modelPath': path,
      'messages': [
        {"role": "user", "content": text},
      ],
    });

    // 2. Listen to tokens
    final tokenStream = PlatformLlamaChannel.stream
        .receiveBroadcastStream()
        .cast<String>();

    final thinkBuffer = StringBuffer();
    final resultBuffer = StringBuffer();
    bool inThinkBlock = false;

    await for (final token in tokenStream) {
      if (token == "__done__") {
        // Emit any leftover thinking content
        // if (thinkBuffer.isNotEmpty) {
        //   yield AILocalResponse(
        //     think: thinkBuffer.toString(),
        //     result: null,
        //     isDone: false,
        //   );
        // }

        // Emit final result
        yield AILocalResponse(isDone: true);
        break;
      }

      if (token.startsWith("<think>")) {
        inThinkBlock = true;
        thinkBuffer.write(token.replaceFirst("<think>", "").trim());
      } else if (token.endsWith("</think>")) {
        // End of thinking block
        thinkBuffer.write(token.replaceFirst("</think>", "").trim());
        yield AILocalResponse(think: thinkBuffer.toString(), result: null);
        thinkBuffer.clear();
        inThinkBlock = false;
      } else {
        if (inThinkBlock) {
          // accumulate thinking tokens
          thinkBuffer.write(token);
          yield AILocalResponse(think: token, isThinking: true);
        } else {
          // regular result tokens
          resultBuffer.write(token);
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
