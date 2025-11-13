import 'package:dartpad_lite/UI/editor/ai_helper/ai_response.dart';
import 'package:dartpad_lite/core/services/monaco_bridge_service/monaco_bridge_service.dart';
import 'package:flutter/cupertino.dart';

import 'ai_helper_network_service.dart';

abstract class AIHelperVMInterface {
  ValueNotifier<List<AIHelperChatMessage>> get onMessagesUpdate;
  ValueNotifier<bool> get isLoading;
  ValueNotifier<bool> get readFromEditor;

  Future<void> generate({required String text});
  void moveToEditor({required String code});
}

class AIHelperVM implements AIHelperVMInterface {
  final MonacoWebBridgeServiceInterface monacoWebBridgeService;
  final AIHelperNetworkServiceInterface networkService =
      AiHelperNetworkService();

  final List<AIHelperChatMessage> _chatMessages = [];

  final List<AIResponse> _aiResponses = [];

  @override
  ValueNotifier<List<AIHelperChatMessage>> onMessagesUpdate = ValueNotifier([]);

  @override
  final ValueNotifier<bool> readFromEditor = ValueNotifier(false);

  @override
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  AIHelperVM(this.monacoWebBridgeService);

  @override
  Future<void> generate({required String text}) async {
    if (text.isEmpty) return Future.value();

    isLoading.value = true;

    try {
      String userText = text;

      if (readFromEditor.value) {
        final code = await monacoWebBridgeService.getValue();
        userText += '\n$code';
      }

      _chatMessages.add(AIHelperChatMessage(text: userText, isUser: true));
      onMessagesUpdate.value = _chatMessages.toList();

      // await Future.delayed(const Duration(seconds: 2));
      // final AIResponse? response = AIResponse.dummyAIResponse();

      final response = await networkService.generateContent(text: userText);

      if (response != null) {
        _aiResponses.add(response);

        _chatMessages.add(
          AIHelperChatMessage(
            text: response.candidates.first.content.parts.first.text,
            isUser: false,
          ),
        );
        onMessagesUpdate.value = _chatMessages.toList();
      }
    } catch (e) {
      _chatMessages.add(AIHelperChatMessage(text: 'Error: $e', isUser: false));
      onMessagesUpdate.value = _chatMessages.toList();
    }

    isLoading.value = false;
  }

  @override
  void moveToEditor({required String code}) {
    monacoWebBridgeService.setCode(code: code);
  }
}
