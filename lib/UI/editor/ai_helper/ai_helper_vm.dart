import 'package:dartpad_lite/UI/settings/options/api_key/ai_setting_vm.dart';
import 'package:dartpad_lite/core/services/ai/ai_provider.dart';
import 'package:dartpad_lite/core/services/ai/ai_provider_error.dart';
import 'package:dartpad_lite/core/services/ai/ai_provider_service.dart';
import 'package:dartpad_lite/core/services/ai/ai_response.dart';
import 'package:dartpad_lite/core/services/event_service.dart';
import 'package:dartpad_lite/core/services/monaco_bridge_service/monaco_bridge_service.dart';
import 'package:dartpad_lite/core/storage/ai_repo.dart';
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
  final AIRepoInterface aiRepoInterface = AIRepo();
  final MonacoWebBridgeServiceInterface monacoWebBridgeService;
  late final AIProviderInterface _aiProvider;

  final List<AIHelperChatMessage> _chatMessages = [];

  final List<AIResponse> _aiResponses = [];

  @override
  ValueNotifier<List<AIHelperChatMessage>> onMessagesUpdate = ValueNotifier([]);

  @override
  final ValueNotifier<bool> readFromEditor = ValueNotifier(false);

  @override
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  AIHelperVM(this.monacoWebBridgeService) {
    _setUpAIProvider();
  }

  void _setUpAIProvider() async {
    try {
      final aiType = await aiRepoInterface.getType();

      switch (aiType) {
        case AIType.local:
          final path = await aiRepoInterface.getModelPath();
          _aiProvider = AIProviderFactory.localProvider(modelPath: path ?? '');
          break;
        case AIType.remote:
          final key = await aiRepoInterface.getApiKey();
          _aiProvider = AIProviderFactory.remoteProvider(apiKey: key ?? '');
          break;
      }
    } on AIProviderError catch (e) {
      EventService.error(msg: e.message);
    } catch (e) {
      EventService.error(msg: e.toString());
    }
  }

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

      // _chatMessages.add(
      //   AIHelperChatMessage(text: withCodeResponse, isUser: false),
      // );
      // onMessagesUpdate.value = _chatMessages.toList();
      //
      // return;

      final aiResponse = await _aiProvider.generateContent(text: userText);
      if (aiResponse != null) {
        final response = AIResponse.fromJson(aiResponse.data);

        _aiResponses.add(response);

        _chatMessages.add(
          AIHelperChatMessage(
            text: response.candidates.first.content.parts.first.text,
            isUser: false,
          ),
        );
        onMessagesUpdate.value = _chatMessages.toList();
      } else {
        EventService.error(msg: 'No response');
      }
    } on AIProviderError catch (e) {
      EventService.error(msg: e.message);
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
