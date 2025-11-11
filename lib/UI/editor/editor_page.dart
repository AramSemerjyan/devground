import 'dart:async';
import 'dart:convert';

import 'package:dartpad_lite/UI/command_palette/command_palette.dart';
import 'package:dartpad_lite/services/compiler/compiler_interface.dart';
import 'package:dartpad_lite/services/event_service.dart';
import 'package:dartpad_lite/services/save_file/save_file_service.dart';
import 'package:dartpad_lite/storage/supported_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/lsp_bridge.dart';
import '../../utils/app_colors.dart';
import '../console/result_console_page.dart';

class EditorPage extends StatefulWidget {
  final CompilerInterface compiler;
  final FileServiceInterface saveFileService;

  const EditorPage({
    super.key,
    required this.compiler,
    required this.saveFileService,
  });
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final WebViewController _controller;

  final uuid = const Uuid();

  final _output = StringBuffer();

  double _sidebarWidth = 300;
  bool _isDragging = false;
  final _outputController = StreamController<String>.broadcast();

  late LspBridge _lspBridge;
  final int lspPort = 8081;

  final ValueNotifier<bool> _inProgress = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'EditorChannel',
        onMessageReceived: (message) async {
          try {
            final msg = jsonDecode(message.message) as Map<String, dynamic>;
            await handleEditorMessage(msg);
          } catch (e) {
            sendStatus("Invalid message: $e");
          }
        },
      );
    _loadHtmlFromAssets();

    EventService.instance.onEvent.stream
        .where((e) => e.type == EventType.languageChanged)
        .listen((event) async {
          final lang = event.data as SupportedLanguage?;

          if (lang != null) {
            final jsLang = lang.key.value;
            await _controller.runJavaScript('setEditorLanguage("$jsLang");');

            final codeJson = jsonEncode(lang.snippet);
            await _controller.runJavaScript(
              'postMessageToEditor({type:"replaceCode", payload:$codeJson});',
            );
          }
        });

    // _lspBridge = LspBridge(lspPort);
    // _lspBridge.start();
  }

  Future<void> _loadHtmlFromAssets() async {
    final html = await rootBundle.loadString('assets/index.html');
    _controller.loadHtmlString(html);
  }

  Future<void> handleEditorMessage(Map<String, dynamic> msg) async {
    final type = msg['type'] as String?;
    if (type == 'run') {
      final code = msg['code'] as String? ?? '';
      await runCode(code);
    } else if (type == 'format') {
      final code = msg['code'] as String? ?? '';
      await formatCode(code);
    } else {
      sendStatus('Unknown message type: $type');
    }
  }

  Future<void> sendStatus(String s) async {
    final payload = jsonEncode({'type': 'status', 'payload': s});
    _controller.runJavaScript(
      'window.postMessageToEditor(${jsonEncode(payload)});',
    );
  }

  Future<void> sendOutput(String s) async {
    _output.write(s);
    _outputController.sink.add(_output.toString());
  }

  Future<void> runCode(String code) async {
    _inProgress.value = true;

    _output.clear();
    _outputController.sink.add('');

    try {
      final result = await widget.compiler.runCode(code);

      _handleCompileResult(result);
    } catch (e) {
      EventService.instance.onEvent.add(Event.error(title: e.toString()));
    }

    _inProgress.value = false;
  }

  Future<void> formatCode(String code) async {
    try {
      final result = await widget.compiler.formatCode(code);

      if (result.hasError) {
        EventService.instance.onEvent.add(Event.error(title: 'Error'));
      } else {
        final payload = jsonEncode({
          'type': 'replaceCode',
          'payload': result.data,
        });
        _controller.runJavaScript(
          'window.postMessageToEditor(${jsonEncode(payload)});',
        );
      }
    } catch (e) {
      EventService.instance.onEvent.add(Event.error(title: e.toString()));
    }
  }

  void _handleCompileResult(CompilerResult result) {
    if (result.hasError) {
      sendOutput(result.data);
      EventService.instance.onEvent.add(Event.error(title: 'Error'));
    } else {
      sendOutput(result.data);
      EventService.instance.onEvent.add(Event.success(title: 'Success'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Editor area (WebView)
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              // Floating buttons
              Positioned(
                bottom: 16,
                left: 16,
                child: Row(
                  children: [
                    FloatingActionButton(
                      heroTag: 'runBtn',
                      tooltip: 'Run',
                      mini: true,
                      child: ValueListenableBuilder(
                        valueListenable: _inProgress,
                        builder: (_, value, ___) {
                          if (value) {
                            return SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            );
                          }

                          return Icon(Icons.play_arrow);
                        },
                      ),
                      onPressed: () {
                        if (_inProgress.value) return;
                        _controller.runJavaScript('window.runEditorCode();');
                      },
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      heroTag: 'formatBtn',
                      tooltip: 'Format',
                      mini: true,
                      child: const Icon(Icons.format_align_left),
                      onPressed: () {
                        _controller.runJavaScript('window.formatEditorCode();');
                      },
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      heroTag: 'saveBtn',
                      tooltip: 'Save',
                      mini: true,
                      child: const Icon(Icons.save),
                      onPressed: () async {
                        print('Save button tapped');

                        final name = await CommandPalette.showRename(context);

                        if (name != null && name.isNotEmpty) {
                          final code =
                              await _controller.runJavaScriptReturningResult(
                                    'window.editor.getValue()',
                                  )
                                  as String;
                          widget.saveFileService.saveMonacoCodeToFile(
                            raw: code,
                            fileName: name,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Drag handle
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            setState(() {
              _sidebarWidth -= details.delta.dx;
              _sidebarWidth = _sidebarWidth.clamp(200, 800);
            });
          },
          onHorizontalDragStart: (_) => setState(() => _isDragging = true),
          onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: Container(
              width: 4,
              color: _isDragging
                  ? Colors.grey
                  : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
        ),

        // Output sidebar
        Container(
          width: _sidebarWidth,
          height: double.infinity,
          color: AppColor.black,
          child: ResultConsolePage(outputStream: _outputController.stream),
        ),
      ],
    );
  }
}
