import 'dart:async';

import 'package:dartpad_lite/UI/editor/ai_helper/ai_state.dart';
import 'package:dartpad_lite/core/services/ai/ai_provider_error.dart';
import 'package:dartpad_lite/core/services/ai/ai_provider_service.dart';
import 'package:dartpad_lite/core/services/event_service/event_service.dart';
import 'package:dartpad_lite/core/services/monaco_bridge_service/monaco_bridge_service.dart';
import 'package:dartpad_lite/core/services/save_file/file_service.dart';
import 'package:dartpad_lite/core/storage/ai_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/ai/ai_response.dart';
import '../../../core/services/event_service/app_error.dart';
import '../../settings/options/ai_section/ai_setting_vm.dart';

class AIUserChatMessage {
  final String text;

  AIUserChatMessage({this.text = ''});
}

class AIBotChatMessage {
  final String fullResponse;
  final String? fullThink;
  final bool isUser;
  final bool isDone;
  final bool isThinking;
  final bool shouldShowThink;
  final StreamController<String>? chunkStream;
  final StreamController<String>? thinkStream;

  AIBotChatMessage({
    this.fullResponse = '',
    this.fullThink,
    this.isUser = false,
    this.isDone = false,
    this.isThinking = false,
    this.shouldShowThink = false,
    this.chunkStream,
    this.thinkStream,
  });
}

class AIMessage {
  final String id;
  final AIUserChatMessage userMessage;
  final AIBotChatMessage? response;

  AIMessage({required this.id, required this.userMessage, this.response});

  AIMessage copyWithResponse({required AIBotChatMessage botResponse}) {
    return AIMessage(id: id, userMessage: userMessage, response: botResponse);
  }

  @override
  bool operator ==(Object other) {
    return id == (other as AIMessage).id;
  }

  @override
  int get hashCode => id.hashCode;
}

abstract class AIHelperVMInterface {
  ValueNotifier<Set<AIMessage>> get onMessagesUpdate;
  ValueNotifier<AIState> get aiState;
  ValueNotifier<bool> get readFromEditor;

  Future<void> generate({required String text});
  void moveToEditor({required String code});
  void fullFileSave({required AIMessage message, String? name});
}

class AIHelperVM implements AIHelperVMInterface {
  final AIRepoInterface aiRepoInterface = AIRepo();
  final MonacoWebBridgeServiceInterface monacoWebBridgeService;
  final FileServiceInterface _fileService;
  late final AiProviderServiceInterface _aiProviderService =
      AIProviderService.instance;

  final Set<AIMessage> _chatMessages = {};

  final List<AIResponse> _aiResponses = [];

  @override
  ValueNotifier<Set<AIMessage>> onMessagesUpdate = ValueNotifier({});

  @override
  final ValueNotifier<bool> readFromEditor = ValueNotifier(false);

  @override
  ValueNotifier<AIState> aiState = ValueNotifier(AIState.idle);

  AIHelperVM(this.monacoWebBridgeService, this._fileService) {
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

    if (aiState.value != AIState.idle) return;

    aiState.value = AIState.loading;

    EventService.emit(type: EventType.aiStateChanged, data: AIState.thinking);

    try {
      String userText = text;

      if (readFromEditor.value) {
        final code = await monacoWebBridgeService.getValue();
        userText += '\n$code';
      }
      final requestId = Uuid().v4();

      AIMessage message = AIMessage(
        id: requestId,
        userMessage: AIUserChatMessage(text: userText),
      );

      _chatMessages.add(message);
      onMessagesUpdate.value = _chatMessages.toSet();

      String wholeResultText = '';
      String wholeThinkText = '';

      aiState.value = AIState.thinking;

      _aiProviderService.provider
          .generateContent(text: userText)
          .listen((aiResponse) {
            if (aiResponse != null) {
              _aiResponses.add(aiResponse);
              wholeResultText += aiResponse.responseText;
              wholeThinkText += aiResponse.thinkingText;

              if (message.response == null) {
                message = message.copyWithResponse(
                  botResponse: AIBotChatMessage(
                    fullResponse: wholeResultText,
                    isUser: false,
                    isThinking: aiResponse.isThinking,
                    isDone: aiResponse.isDone,
                    shouldShowThink: aiResponse.shouldShowThink,
                    chunkStream: StreamController(),
                    thinkStream: StreamController(),
                  ),
                );

                _chatMessages.remove(message);
                _chatMessages.add(message);

                onMessagesUpdate.value = _chatMessages.toSet();
              }

              if (message.response?.isThinking != aiResponse.isThinking) {
                message = message.copyWithResponse(
                  botResponse: AIBotChatMessage(
                    fullResponse: wholeResultText,
                    isUser: false,
                    isThinking: aiResponse.isThinking,
                    isDone: aiResponse.isDone,
                    shouldShowThink: aiResponse.shouldShowThink,
                    chunkStream: StreamController(),
                    thinkStream: StreamController(),
                  ),
                );

                _chatMessages.remove(message);
                _chatMessages.add(message);

                onMessagesUpdate.value = _chatMessages.toSet();
              }

              if (!aiResponse.isDone) {
                if (aiResponse.isThinking) {
                  message.response?.thinkStream?.sink.add(wholeThinkText);
                } else {
                  EventService.emit(
                    type: EventType.aiStateChanged,
                    data: AIState.generating,
                  );
                  aiState.value = AIState.generating;

                  message.response?.chunkStream?.sink.add(wholeResultText);
                }
              } else {
                message = message.copyWithResponse(
                  botResponse: AIBotChatMessage(
                    fullResponse: wholeResultText,
                    fullThink: wholeThinkText,
                    isUser: false,
                    isDone: true,
                    shouldShowThink: aiResponse.shouldShowThink,
                  ),
                );

                _chatMessages.remove(message);
                _chatMessages.add(message);

                onMessagesUpdate.value = _chatMessages.toSet();

                EventService.emit(
                  type: EventType.aiStateChanged,
                  data: AIState.done,
                );
                aiState.value = AIState.idle;
              }
            } else {
              EventService.error(msg: 'No response');

              EventService.emit(
                type: EventType.aiStateChanged,
                data: AIState.done,
              );
              aiState.value = AIState.idle;
            }
          })
          .onError((error, stack) {
            EventService.emit(
              type: EventType.aiStateChanged,
              data: AIState.idle,
            );
            aiState.value = AIState.idle;

            if (error is AIProviderError) {
              EventService.error(
                msg: error.toString(),
                error: AppError(object: error, stackTrace: stack),
              );
            } else {
              _chatMessages.add(
                message.copyWithResponse(
                  botResponse: AIBotChatMessage(fullResponse: 'Error: $error'),
                ),
              );
              onMessagesUpdate.value = _chatMessages.toSet();
            }
          });
    } on AIProviderError catch (e, s) {
      EventService.error(
        msg: e.toString(),
        error: AppError(object: e, stackTrace: s),
      );

      EventService.emit(type: EventType.aiStateChanged, data: AIState.idle);
      aiState.value = AIState.idle;
    } catch (e, stackTrace) {
      EventService.error(
        error: AppError(object: e, stackTrace: stackTrace),
        msg: 'Error: $e',
      );
      onMessagesUpdate.value = _chatMessages.toSet();

      EventService.emit(type: EventType.aiStateChanged, data: AIState.idle);
      aiState.value = AIState.idle;
    }
  }

  @override
  void moveToEditor({required String code}) {
    monacoWebBridgeService.setCode(code: code);
  }

  @override
  void fullFileSave({required AIMessage message, String? name}) async {
    await _fileService.saveToFile(
      raw: message.response?.fullResponse ?? '',
      fileName: message.id,
      extension: 'ai',
    );
  }
}
