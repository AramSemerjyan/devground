import 'package:dartpad_lite/UI/command_palette/command_palette.dart';
import 'package:dartpad_lite/UI/common/floating_progress_button.dart';
import 'package:dartpad_lite/services/compiler/compiler_interface.dart';
import 'package:dartpad_lite/services/save_file/file_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/monaco_bridge_service/monaco_bridge_service.dart';
import '../../utils/app_colors.dart';
import 'editor_page_vm.dart';
import 'result_console_page.dart';

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

  final ValueNotifier<bool> _isDragging = ValueNotifier(false);
  final ValueNotifier<double> _sidebarWidth = ValueNotifier(300);
  final ValueNotifier<bool> _inProgress = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _vm.compileResultStream.listen((_) {
      _inProgress.value = false;
    });
  }

  Widget _buildButtons() {
    return Row(
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

            if (name != null) _vm.save(name: name);
          },
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant EditorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _vm.dropEditorFocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        _sidebarWidth.value -= details.delta.dx;
        _sidebarWidth.value = _sidebarWidth.value.clamp(200, 800);
      },
      onHorizontalDragStart: (_) => _isDragging.value = true,
      onHorizontalDragEnd: (_) => _isDragging.value = false,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: ValueListenableBuilder(
          valueListenable: _isDragging,
          builder: (_, isDragging, __) {
            return Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      WebViewWidget(controller: _vm.controller),
                      // Floating buttons
                      Positioned(bottom: 16, left: 16, child: _buildButtons()),
                      if (isDragging)
                        Positioned.fill(
                          child: Container(
                            color: AppColor.mainGreyLighter.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Drag handle
                Container(
                  width: 4,
                  color: isDragging ? Colors.grey : AppColor.mainGreyLighter,
                ),

                // Output sidebar
                ValueListenableBuilder(
                  valueListenable: _sidebarWidth,
                  builder: (_, value, __) {
                    return Stack(
                      children: [
                        Container(
                          width: value,
                          height: double.infinity,
                          color: AppColor.black,
                          child: ResultConsolePage(
                            outputStream: _vm.compileResultStream,
                          ),
                        ),
                        if (isDragging)
                          Positioned.fill(
                            child: Container(
                              color: AppColor.mainGreyLighter.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
