import 'dart:async';

import 'package:dartpad_lite/UI/editor/editor/compiler_state_audio_manager.dart';
import 'package:dartpad_lite/UI/editor/editor/language_editor/language_editor_controller.dart';
import 'package:dartpad_lite/UI/editor/editor/language_editor/language_editor_factory.dart';
import 'package:dartpad_lite/core/pages_service/pages_service.dart';
import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/services/compiler/compiler_factory.dart';
import '../../../core/services/compiler/compiler_interface.dart';
import '../../../core/services/compiler/compiler_result.dart';
import '../../../core/services/event_service/app_error.dart';
import '../../../core/services/event_service/event_service.dart';
import '../../../core/services/import_file/imported_file.dart';
import '../../../core/services/save_file/file_service.dart';
import '../../../core/storage/supported_language.dart';

abstract class EditorViewVMInterface {
  AppFile get file;

  LanguageEditorControllerInterface get controller;

  SupportedLanguage get language;

  Stream<CompilerResult> get compileResultStream;

  ValueNotifier<bool> get runProgress;
  ValueNotifier<bool> get formatProgress;
  ValueNotifier<bool> get saveProgress;
  ValueNotifier<bool> get settingUp;
  ValueNotifier<bool> get enableConsoleInput;

  Future<void> formatCode();
  Future<void> runCode();
  Future<void> save({String? name});
  Future<void> dropEditorFocus();
  Future<void> onAIBoosModeChange({required bool state});
  Future<void> onConsoleInput(String input);
  void dispose();
}

class EditorViewVM implements EditorViewVMInterface {
  final AppFile _file;
  final FileServiceInterface _saveFileService;
  final PagesServiceInterface _pagesService;
  final CompilerStateAudioManagerInterface _compilerAudioService;

  late final LanguageEditorControllerInterface _languageEditorController;
  late final CompilerInterface _compiler;

  @override
  AppFile get file => _file;

  @override
  SupportedLanguage get language => _file.language;

  @override
  Stream<CompilerResult> get compileResultStream => _outputController.stream;

  @override
  ValueNotifier<bool> settingUp = ValueNotifier(false);

  @override
  ValueNotifier<bool> runProgress = ValueNotifier(false);
  @override
  ValueNotifier<bool> formatProgress = ValueNotifier(false);
  @override
  ValueNotifier<bool> saveProgress = ValueNotifier(false);

  @override
  ValueNotifier<bool> enableConsoleInput = ValueNotifier(false);

  @override
  LanguageEditorControllerInterface get controller => _languageEditorController;

  final _outputController = StreamController<CompilerResult>.broadcast();
  final _output = StringBuffer();

  EditorViewVM(this._file, this._saveFileService, this._pagesService, this._compilerAudioService) {
    _setUp();
  }

  @override
  Future<void> runCode() async {
    if (runProgress.value) return;
    runProgress.value = true;

    final code = await _languageEditorController.getValue();

    _output.clear();
    _outputController.sink.add(CompilerResult.empty());

    try {
      await _compiler.runCode(code);
    } catch (e, s) {
      EventService.error(
        msg: e.toString(),
        error: AppError(object: e, stackTrace: s),
      );
    }

    runProgress.value = false;
  }

  @override
  Future<void> formatCode() async {
    try {
      if (formatProgress.value) return;
      formatProgress.value = true;
      final code = await _languageEditorController.getValue();

      final result = await _compiler.formatCode(code);

      if (result.status == CompilerResultStatus.error) {
        EventService.error(msg: 'Error');
      } else {
        _languageEditorController.setCode(code: result.data);
      }
    } catch (e, s) {
      EventService.error(
        msg: e.toString(),
        error: AppError(object: e, stackTrace: s),
      );
    }

    formatProgress.value = false;
  }

  @override
  Future<void> save({String? name}) async {
    if (saveProgress.value) return;
    saveProgress.value = true;

    final code = await _languageEditorController.getValue();
    await _saveFileService.saveMonacoCodeToFile(raw: code, fileName: name);

    saveProgress.value = false;
  }

  @override
  Future<void> dropEditorFocus() {
    if (settingUp.value) return Future.value();

    return _languageEditorController.dropFocus();
  }

  void _setUp() async {
    settingUp.value = true;

    _setUpListeners();

    try {
      await _setUpMonacoController();
      await _setUpCompiler();
    } on CompilerUpcomingSupport catch (e) {
      EventService.warning(msg: e.toString());
    } catch (e, s) {
      EventService.error(
        error: AppError(object: e, stackTrace: s),
        msg: e.toString(),
        duration: const Duration(seconds: 5),
      );
    }
    settingUp.value = false;
  }

  Future<void> _setUpMonacoController() async {
    try {
      _languageEditorController = LanguageEditorFactory.getController(
        language: language,
      );

      _languageEditorController.onNavigationRequest = (request) {
        if (request.url.startsWith('data:text/html') ||
            request.url == 'about:blank') {
          return NavigationDecision.navigate;
        }

        if (language.key == SupportedLanguageKey.json) {
          _outputController.sink.add(CompilerResult.message(data: request.url));
        }

        return NavigationDecision.prevent;
      };

      await _languageEditorController.setUp();
      await _languageEditorController.setLanguage(language: _file.language);
      await _languageEditorController.setCode(code: _file.code);
    } catch (e, s) {
      EventService.error(
        error: AppError(object: e, stackTrace: s),
        msg: e.toString(),
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> _setUpCompiler() async {
    _compiler = await CompilerFactory.getCompiler(file.language);
    _compiler.outputStream.listen((result) {
      _compilerAudioService.play(result.status);

      switch (result.status) {
        case CompilerResultStatus.message:
          _sendOutput(result);
          break;
        case CompilerResultStatus.error:
          _sendOutput(result);
          EventService.error(
            error: AppError(object: result.error),
            msg: 'Error: ${result.message}',
          );
          enableConsoleInput.value = false;
          break;
        case CompilerResultStatus.done:
          _sendOutput(result);
          EventService.success(msg: 'Done: ${result.message}');
          enableConsoleInput.value = false;
          break;
        case CompilerResultStatus.waitingForInput:
          enableConsoleInput.value = true;
          EventService.warning(msg: 'Compiler: ${result.message}');
          break;
      }
    });

    if (file.language.needSDKPath) {
      if (file.language.sdkPath == null) {
        EventService.error(
          msg: 'SDK path is not set for ${file.language.name} language.',
        );
      } else {
        await _compiler.setPath(file.language.sdkPath);
      }
    }
  }

  void _setUpListeners() {
    EventService.instance.stream
        .where((e) => e.type == EventType.sdkPathUpdated)
        .listen((event) {
          final language = event.data as SupportedLanguage;

          if (language.key == _file.language.key) {
            _compiler.setPath(language.sdkPath);
          }
        });
  }

  Future<void> _sendOutput(CompilerResult result) async {
    _output.write(result.data);
    _outputController.sink.add(result);
  }

  @override
  Future<void> onAIBoosModeChange({required bool state}) async {
    final currentPage = await _pagesService.getSelectedPage();
    _pagesService.updatePage(page: currentPage.copy(isAIBoosted: state));
  }

  @override
  Future<void> onConsoleInput(String input) async {
    _compiler.inputSink.add(input);
  }

  @override
  void dispose() {
    _compiler.dispose();
    _compilerAudioService.dispose();
    _outputController.close();
  }
}
