import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartpad_lite/services/compiler/compiler_interface.dart';
import 'package:dartpad_lite/services/compiler/dart_compiler.dart';
import 'package:dartpad_lite/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_window/multi_window.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/lsp_bridge.dart';
import '../../settings_manager.dart';
import '../../utils/app_colors.dart';
import '../console/result_console_page.dart';

class RunCodeIntent extends Intent {
  const RunCodeIntent();
}

class FormatCodeIntent extends Intent {
  const FormatCodeIntent();
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final WebViewController _controller;
  final CompilerInterface compiler = DartCompiler();

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

  String extractDartError(String stderr) {
    // Find the start: first colon after the temp file path
    final startIndex = stderr.indexOf(
      '.dart:',
    ); // e.g. ../../../snippet_*.dart:2:27:
    if (startIndex == -1) return stderr.trim();

    // Find the end: before "Error: AOT compilation failed"
    final endIndex = stderr.indexOf('Error: AOT compilation failed');
    if (endIndex == -1) return stderr.substring(startIndex).trim();

    // Extract substring
    final slice = stderr.substring(startIndex, endIndex).trim();

    // Remove the file path at the start (optional)
    final firstColon = slice.indexOf('Error:');
    if (firstColon != -1) {
      return slice.substring(firstColon).trim();
    }

    return slice;
  }

  Future<void> runCode(String code) async {
    _inProgress.value = true;

    _output.clear();
    _outputController.sink.add('');

    final result = await compiler.runCode(code);

    if (result.hasError) {
      sendOutput(result.data);
      StatusEvent.instance.onEvent.add(Event.error(title: 'Error'));
    } else {
      sendOutput(result.data);
      StatusEvent.instance.onEvent.add(Event.success(title: 'Success'));
    }

    // sendStatus('Writing temp file...');
    // final tmpDir = await getTemporaryDirectory();
    // final id = uuid.v4();
    // final file = File('${tmpDir.path}/snippet_$id.dart');
    // await file.writeAsString(code);
    // sendStatus('Compiling...');
    // // Try to compile to an exe to capture compile errors.
    // final compiledPath = '${tmpDir.path}/snippet_$id.bin';
    //
    // // Run: dart compile exe <file> -o <compiledPath>
    // final flutterPath = await SettingsManager.getFlutterPath();
    // final dartExecutable = flutterPath != null && flutterPath.isNotEmpty
    //     ? '$flutterPath/bin/dart'
    //     : 'dart'; // fallback to default if not set
    //
    // final compileProc = await Process.start(dartExecutable, [
    //   'compile',
    //   'exe',
    //   file.path,
    //   '-o',
    //   compiledPath,
    // ]);
    // // collect output
    // final compileStdout = StringBuffer();
    // final compileStderr = StringBuffer();
    // compileProc.stdout
    //     .transform(utf8.decoder)
    //     .listen((d) => compileStdout.write(d));
    // compileProc.stderr
    //     .transform(utf8.decoder)
    //     .listen((d) => compileStderr.write(d));
    // final exitCode = await compileProc.exitCode;
    //
    // if (exitCode != 0) {
    //   sendStatus('Compilation failed (code $exitCode)');
    //   _inProgress.value = false;
    //   if (compileStderr.isNotEmpty) {
    //     sendOutput(extractDartError(compileStderr.toString()));
    //   }
    //   StatusEvent.instance.onEvent.add(Event.error(title: 'Compile failed'));
    //   return;
    // }
    // sendStatus('Compilation succeeded. Running...');
    // // run the compiled binary
    // try {
    //   final runProc = await Process.start(compiledPath, []);
    //   runProc.stdout
    //       .transform(utf8.decoder)
    //       .map((value) {
    //         StatusEvent.instance.onEvent.add(Event.success(title: 'Success'));
    //         return value;
    //       })
    //       .listen(sendOutput);
    //   runProc.stderr
    //       .transform(utf8.decoder)
    //       .map((value) {
    //         StatusEvent.instance.onEvent.add(Event.error(title: 'Failed'));
    //         return value;
    //       })
    //       .listen(sendOutput);
    //   final rc = await runProc.exitCode;
    //   sendStatus('Program finished (exit $rc)');
    // } catch (e) {
    //   StatusEvent.instance.onEvent.add(Event.error(title: 'Failed'));
    //   sendOutput('Failed to run compiled binary: $e');
    //   sendStatus('Run failed');
    // }

    _inProgress.value = false;
  }

  Future<void> formatCode(String code) async {
    sendStatus('Formatting...');
    final tmpDir = await getTemporaryDirectory();
    final id = uuid.v4();
    final file = File('${tmpDir.path}/snippet_fmt_$id.dart');
    final flutterPath = await SettingsManager.getFlutterPath();
    final dartExecutable = flutterPath != null && flutterPath.isNotEmpty
        ? '$flutterPath/bin/dart'
        : 'dart';
    await file.writeAsString(code);
    // run dart format -n does not write; run 'dart format' overwrites, but we want formatted output
    // Simplest: run `dart format <file>` then read file back.
    final proc = await Process.start(dartExecutable, ['format', file.path]);
    final exitCode = await proc.exitCode;
    if (exitCode == 0) {
      final formatted = await file.readAsString();
      final payload = jsonEncode({'type': 'replaceCode', 'payload': formatted});
      _controller.runJavaScript(
        'window.postMessageToEditor(${jsonEncode(payload)});',
      );
      sendStatus('Formatted');
    } else {
      sendStatus('Format failed (exit $exitCode)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Editor area (WebView)
        Expanded(
          child: Shortcuts(
            shortcuts: <LogicalKeySet, Intent>{
              // Cmd+R → Run
              LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyR):
                  const RunCodeIntent(),
              // Cmd+S → Format
              LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS):
                  const FormatCodeIntent(),
            },
            child: Actions(
              actions: <Type, Action<Intent>>{
                RunCodeIntent: CallbackAction<RunCodeIntent>(
                  onInvoke: (intent) {
                    _controller.runJavaScript('window.runEditorCode();');
                    return null;
                  },
                ),
                FormatCodeIntent: CallbackAction<FormatCodeIntent>(
                  onInvoke: (intent) {
                    _controller.runJavaScript('window.formatEditorCode();');
                    return null;
                  },
                ),
              },
              child: Focus(
                autofocus: true, // Important: captures keyboard input
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
                              _controller.runJavaScript(
                                'window.runEditorCode();',
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton(
                            heroTag: 'formatBtn',
                            tooltip: 'Format',
                            mini: true,
                            child: const Icon(Icons.format_align_left),
                            onPressed: () {
                              _controller.runJavaScript(
                                'window.formatEditorCode();',
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton(
                            heroTag: 'newWindowBtn',
                            tooltip: 'New window',
                            mini: true,
                            child: const Icon(Icons.add),
                            onPressed: () async {
                              await MultiWindow.create(
                                DateTime.now().microsecondsSinceEpoch
                                    .toString(),
                                alignment: Alignment.center,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
