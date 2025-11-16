import 'package:dartpad_lite/UI/editor/ai_helper/ai_state.dart';
import 'package:dartpad_lite/core/services/ai/ai_provider_error.dart';
import 'package:dartpad_lite/core/services/ai/ai_provider_service.dart';
import 'package:dartpad_lite/core/services/ai/ai_response.dart';
import 'package:dartpad_lite/core/services/event_service/event_service.dart';
import 'package:dartpad_lite/core/services/monaco_bridge_service/monaco_bridge_service.dart';
import 'package:dartpad_lite/core/storage/ai_repo.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/services/event_service/app_error.dart';
import '../../settings/options/ai_section/ai_setting_vm.dart';
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
  late final AiProviderServiceInterface _aiProviderService =
      AIProviderService.instance;

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
          await _aiProviderService.loadFromFile(modelPath: path ?? '');
          break;
        case AIType.remote:
          final key = await aiRepoInterface.getApiKey();
          await _aiProviderService.loadRemote(apiKey: key ?? '');
          break;
      }

      EventService.emit(type: EventType.aiModeChanged, data: true);
    } on AIProviderError catch (e, s) {
      EventService.error(
        msg: e.toString(),
        error: AppError(object: e, stackTrace: s),
      );
    } catch (e, s) {
      EventService.error(
        msg: e.toString(),
        error: AppError(object: e, stackTrace: s),
      );
    }
  }

  @override
  Future<void> generate({required String text}) async {
    if (text.isEmpty) return Future.value();

    isLoading.value = true;

    EventService.emit(type: EventType.aiStateChanged, data: AIState.thinking);

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

      final aiResponse = await _aiProviderService.provider.generateContent(
        text: userText,
        // mock: true,
      );
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
    } on AIProviderError catch (e, s) {
      EventService.error(
        msg: e.toString(),
        error: AppError(object: e, stackTrace: s),
      );
    } catch (e) {
      _chatMessages.add(AIHelperChatMessage(text: 'Error: $e', isUser: false));
      onMessagesUpdate.value = _chatMessages.toList();
    }

    EventService.emit(type: EventType.aiStateChanged, data: AIState.done);
    isLoading.value = false;
  }

  @override
  void moveToEditor({required String code}) {
    monacoWebBridgeService.setCode(code: code);
  }
}
