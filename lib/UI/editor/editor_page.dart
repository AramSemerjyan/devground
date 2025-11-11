import 'dart:async';

import 'package:dartpad_lite/UI/command_palette/command_palette.dart';
import 'package:dartpad_lite/UI/common/floating_progress_button.dart';
import 'package:dartpad_lite/services/compiler/compiler_interface.dart';
import 'package:dartpad_lite/services/save_file/file_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/lsp_bridge.dart';
import '../../services/monaco_bridge_service/monaco_bridge_service.dart';
import '../../utils/app_colors.dart';
import '../console/result_console_page.dart';
import 'editor_page_vm.dart';

class EditorPage extends StatefulWidget {
  final CompilerInterface compiler;
  final FileServiceInterface saveFileService;
  final MonacoWebBridgeServiceInterface monacoWebBridgeService;

  const EditorPage({
    super.key,
    required this.compiler,
    required this.saveFileService,
    required this.monacoWebBridgeService,
  });
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final EditorPageVMInterface _vm = EditorPageVM(
    widget.monacoWebBridgeService,
    widget.compiler,
    widget.saveFileService,
  );

  double _sidebarWidth = 300;
  bool _isDragging = false;

  late LspBridge _lspBridge;
  final int lspPort = 8081;

  final ValueNotifier<bool> _inProgress = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadHtmlFromAssets();

    // _lspBridge = LspBridge(lspPort);
    // _lspBridge.start();

    _vm.compileResultStream.listen((_) {
      _inProgress.value = false;
    });
  }

  Future<void> _loadHtmlFromAssets() async {
    final html = await rootBundle.loadString('assets/index.html');
    _vm.controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Editor area (WebView)
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: _vm.controller),
              // Floating buttons
              Positioned(
                bottom: 16,
                left: 16,
                child: Row(
                  children: [
                    FloatingProgressButton(
                      inProgress: _vm.runProgress,
                      heroTag: 'runBtn',
                      tooltip: 'Run',
                      mini: true,
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        if (_inProgress.value) return;
                        _inProgress.value = true;
                        _vm.runCode();
                      },
                    ),
                    const SizedBox(width: 8),
                    FloatingProgressButton(
                      inProgress: _vm.formatProgress,
                      heroTag: 'formatBtn',
                      tooltip: 'Format',
                      mini: true,
                      icon: const Icon(Icons.format_align_left),
                      onPressed: () {
                        _vm.formatCode();
                      },
                    ),
                    const SizedBox(width: 8),
                    FloatingProgressButton(
                      inProgress: _vm.saveProgress,
                      heroTag: 'saveBtn',
                      tooltip: 'Save',
                      mini: true,
                      icon: const Icon(Icons.save),
                      onPressed: () async {
                        final name = await CommandPalette.showRename(context);
                        _vm.save(name: name);
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
          child: ResultConsolePage(outputStream: _vm.compileResultStream),
        ),
      ],
    );
  }
}
