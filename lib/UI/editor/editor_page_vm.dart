import 'dart:async';

import 'package:dartpad_lite/services/monaco_bridge_service/monaco_bridge_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/compiler/compiler_interface.dart';
import '../../services/event_service.dart';
import '../../services/save_file/file_service.dart';
import '../../storage/supported_language.dart';

abstract class EditorPageVMInterface {
  WebViewController get controller;
  MonacoWebBridgeServiceInterface get bridge;

  Stream<String> get compileResultStream;

  ValueNotifier<bool> get runProgress;
  ValueNotifier<bool> get formatProgress;
  ValueNotifier<bool> get saveProgress;

  Future<void> formatCode();
  Future<void> runCode();
  Future<void> save({String? name});
  Future<void> dropEditorFocus();
}

class EditorPageVM implements EditorPageVMInterface {
  final MonacoWebBridgeServiceInterface _monacoWebBridgeService;
  final CompilerInterface _compiler;
  final FileServiceInterface _saveFileService;

  @override
  MonacoWebBridgeServiceInterface get bridge => _monacoWebBridgeService;

  @override
  get controller => _monacoWebBridgeService.controller;

  @override
  Stream<String> get compileResultStream => _outputController.stream;

  @override
  ValueNotifier<bool> runProgress = ValueNotifier(false);
  @override
  ValueNotifier<bool> formatProgress = ValueNotifier(false);
  @override
  ValueNotifier<bool> saveProgress = ValueNotifier(false);

  final _outputController = StreamController<String>.broadcast();
  final _output = StringBuffer();

  EditorPageVM(
    this._monacoWebBridgeService,
    this._compiler,
    this._saveFileService,
  ) {
    _setListeners();

    _monacoWebBridgeService.onRunCode = (code) {
      _runCode(code);
    };
    _monacoWebBridgeService.onFormatCode = (code) {
      _formatCode(code);
    };
  }

  Future<void> _runCode(String code) async {
    _output.clear();
    _outputController.sink.add('');

    try {
      final result = await _compiler.runCode(code);

      if (result.hasError) {
        _sendOutput(result.data);
        EventService.instance.emit(Event.error(title: 'Error'));
      } else {
        _sendOutput(result.data);
        EventService.instance.emit(Event.success(title: 'Success'));
      }
    } catch (e) {
      EventService.instance.emit(Event.error(title: e.toString()));
    }

    runProgress.value = false;
  }

  Future<void> _formatCode(String code) async {
    try {
      final result = await _compiler.formatCode(code);

      if (result.hasError) {
        EventService.instance.emit(Event.error(title: 'Error'));
      } else {
        _monacoWebBridgeService.setCode(code: result.data);
      }
    } catch (e) {
      EventService.instance.emit(Event.error(title: e.toString()));
    }

    formatProgress.value = false;
  }

  Future<void> _sendOutput(String s) async {
    _output.write(s);
    _outputController.sink.add(_output.toString());
  }

  void _setListeners() {
    EventService.instance.stream
        .where((e) => e.type == EventType.languageChanged)
        .listen((event) async {
          final lang = event.data as SupportedLanguage?;

          if (lang != null) _monacoWebBridgeService.setLanguage(language: lang);
        });
  }

  @override
  Future<void> formatCode() async {
    if (formatProgress.value) return;
    formatProgress.value = true;
    await _monacoWebBridgeService.formatCode();
  }

  @override
  Future<void> runCode() async {
    if (runProgress.value) return;
    runProgress.value = true;
    await _monacoWebBridgeService.runCode();
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
    return _monacoWebBridgeService.dropFocus();
  }
}
