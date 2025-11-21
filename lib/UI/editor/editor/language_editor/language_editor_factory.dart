import 'package:dartpad_lite/UI/editor/editor/language_editor/ai_response_editor/ai_response_editor_controller.dart';
import 'package:dartpad_lite/UI/editor/editor/language_editor/language_editor_controller.dart';
import 'package:dartpad_lite/core/storage/supported_language.dart';
import 'package:flutter/material.dart';

import 'ai_response_editor/ai_response_editor.dart';
import 'local_monaco_editor/local_monaco_editor.dart';
import 'local_monaco_editor/local_monaco_editor_controller.dart';

abstract class LanguageEditorFactory {
  static Widget buildLanguageEditor({
    required SupportedLanguage language,
    required LanguageEditorControllerInterface controller,
  }) {
    switch (language.key) {
      case SupportedLanguageKey.ai:
        if (controller is AIResponseEditorController) {
          return AiResponseEditor(controller: controller);
        } else {
          throw UnimplementedError();
        }
      default:
        if (controller is LocalMonacoEditorController) {
          return LocalMonacoEditor(monacoController: controller);
        }

        // if (controller is RealMonacoEditorController) {
        //   return RealmMonacoEditor(monacoController: controller);
        // }

        throw UnimplementedError();
    }
  }

  static LanguageEditorControllerInterface getController({
    required SupportedLanguage language,
  }) {
    switch (language.key) {
      case SupportedLanguageKey.ai:
        return AIResponseEditorController();
      default:
        // return RealMonacoEditorController();
        return LocalMonacoEditorController();
    }
  }
}
