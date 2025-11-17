import 'dart:async';

import 'package:dartpad_lite/core/pages_service/pages_service.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/services/compiler/compiler_interface.dart';
import '../../../core/services/event_service/app_error.dart';
import '../../../core/services/event_service/event_service.dart';
import '../../../core/services/import_file/imported_file.dart';
import '../../../core/services/monaco_bridge_service/monaco_bridge_service.dart';
import '../../../core/services/save_file/file_service.dart';
import '../../../core/storage/supported_language.dart';

abstract class EditorViewVMInterface {
  MonacoWebBridgeServiceInterface get bridge;
  AppFile get file;

  WebViewController get controller;

  SupportedLanguage get language;

  Stream<String> get compileResultStream;

  ValueNotifier<bool> get runProgress;
  ValueNotifier<bool> get formatProgress;
  ValueNotifier<bool> get saveProgress;
  ValueNotifier<bool> get settingUp;

  Future<void> formatCode();
  Future<void> runCode();
  Future<void> save({String? name});
  Future<void> dropEditorFocus();
  Future<void> onAIBoosModeChange({required bool state});
}

class EditorViewVM implements EditorViewVMInterface {
  final AppFile _file;
  final FileServiceInterface _saveFileService;
  late final PagesServiceInterface _pagesService;

  late final MonacoWebBridgeServiceInterface _monacoWebBridgeService;
  late final CompilerInterface _compiler;

  @override
  AppFile get file => _file;

  @override
  MonacoWebBridgeServiceInterface get bridge => _monacoWebBridgeService;

  @override
  SupportedLanguage get language => _file.language;

  @override
  get controller => _monacoWebBridgeService.controller;

  @override
  Stream<String> get compileResultStream => _outputController.stream;

  @override
  ValueNotifier<bool> settingUp = ValueNotifier(false);

  @override
  ValueNotifier<bool> runProgress = ValueNotifier(false);
  @override
  ValueNotifier<bool> formatProgress = ValueNotifier(false);
  @override
  ValueNotifier<bool> saveProgress = ValueNotifier(false);

  final _outputController = StreamController<String>.broadcast();
  final _output = StringBuffer();

  EditorViewVM(this._file, this._saveFileService, this._pagesService) {
    _compiler = Compiler(language: file.language);
    _monacoWebBridgeService = MonacoWebBridgeService();

    _monacoWebBridgeService.onNavigationRequest = (request) {
      if (request.url.startsWith('data:text/html') ||
          request.url == 'about:blank') {
        return NavigationDecision.navigate;
      }

      if (language.key == SupportedLanguageType.json) {
        _outputController.sink.add(request.url);
      }

      return NavigationDecision.prevent;
    };

    _setUp();
  }

  @override
  Future<void> runCode() async {
    if (runProgress.value) return;
    runProgress.value = true;

    final code = await _monacoWebBridgeService.getValue();

    _output.clear();
    _outputController.sink.add('');

    try {
      final result = await _compiler.runCode(code);

      if (result.hasError) {
        _sendOutput(result.data);
        EventService.error(msg: 'Error');
      } else {
        _sendOutput(result.data);
        EventService.success(msg: 'Success');
      }
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
      final code = await _monacoWebBridgeService.getValue();

      final result = await _compiler.formatCode(code);

      if (result.hasError) {
        EventService.error(msg: 'Error');
      } else {
        _monacoWebBridgeService.setCode(code: result.data);
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

    final code = await _monacoWebBridgeService.getValue();
    await _saveFileService.saveMonacoCodeToFile(raw: code, fileName: name);

    saveProgress.value = false;
  }

  @override
  Future<void> dropEditorFocus() {
    if (settingUp.value) return Future.value();

    return _monacoWebBridgeService.dropFocus();
  }

  void _setUp() async {
    settingUp.value = true;
    try {
      await _monacoWebBridgeService.setUp();
      await _monacoWebBridgeService.setLanguage(language: _file.language);
      await _monacoWebBridgeService.setCode(code: _file.code);
    } catch (e, s) {
      EventService.error(
        error: AppError(object: e, stackTrace: s),
        msg: e.toString(),
      );
    }
    settingUp.value = false;
  }

  Future<void> _sendOutput(String s) async {
    _output.write(s);
    _outputController.sink.add(_output.toString());
  }

  @override
  Future<void> onAIBoosModeChange({required bool state}) async {
    final currentPage = await _pagesService.getSelectedPage();
    _pagesService.updatePage(page: currentPage.copy(isAIBoosted: state));
  }
}
