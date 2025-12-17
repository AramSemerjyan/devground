import 'package:dartpad_lite/core/services/event_service/logger/console_logger.dart';
import 'package:dartpad_lite/core/storage/supported_language.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/event_service/app_error.dart';
import '../../../../core/services/event_service/event_service.dart';
import '../../editor/language_editor/language_editor_controller.dart';
import '../../editor/language_editor/language_editor_factory.dart';

abstract class SideBySideViewVMInterface {
  LanguageEditorControllerInterface get controller;

  ValueNotifier<bool> get settingUp;
}

class SideBySideViewVM implements SideBySideViewVMInterface {
  late final LanguageEditorControllerInterface _languageEditorController;

  late final SupportedLanguage _language;

  @override
  LanguageEditorControllerInterface get controller => _languageEditorController;

  @override
  final settingUp = ValueNotifier(false);

  SideBySideViewVM(this._language) {
    settingUp.value = true;
    _languageEditorController = LanguageEditorFactory.getController(
      language: _language,
    );

    _setListeners();
    setUp();
  }

  void setUp() async {
    try {
      await _languageEditorController.setUp();
    } catch (e, s) {
      EventService.error(
        msg: e.toString(),
        error: AppError(object: e, stackTrace: s),
      );
    } finally {
      settingUp.value = false;
    }
  }

  void _setListeners() {
    EventService.instance.stream
        .where(
          (e) =>
              e.type == EventType.dropEditorFocus ||
              e.type == EventType.onAppStateChanged,
        )
        .listen((_) {
          if (settingUp.value) return;

          _languageEditorController.dropFocus();
        });
  }
}
