import 'package:dartpad_lite/UI/editor/ai_helper/ai_helper_page.dart';
import 'package:dartpad_lite/UI/editor/editor/editor_view_vm.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/services/import_file/imported_file.dart';
import '../../../core/services/save_file/file_service.dart';
import '../../../utils/app_colors.dart';
import '../../command_palette/command_palette.dart';
import '../../common/floating_progress_button.dart';
import '../result_page/result_console_view.dart';

class EditorView extends StatefulWidget {
  final ImportedFile file;
  final FileServiceInterface saveFileService;

  const EditorView({
    super.key,
    required this.saveFileService,
    required this.file,
  });

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late final _vm = EditorViewVM(widget.file, widget.saveFileService);

  final ValueNotifier<bool> _isDragging = ValueNotifier(false);
  final ValueNotifier<double> _sidebarWidth = ValueNotifier(300);
  final ValueNotifier<double> _bottomBarHeight = ValueNotifier(300);
  final ValueNotifier<bool> _inProgress = ValueNotifier(false);
  final ValueNotifier<bool> _showAI = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _vm.compileResultStream.listen((_) {
      _inProgress.value = false;
    });
  }

  @override
  void didUpdateWidget(covariant EditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _vm.dropEditorFocus();
  }

  Widget _buildMonacoWebView() {
    return WebViewWidget(controller: _vm.controller);
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
            final name = await CommandPalette.showRename(
              context,
              initialValue: _vm.file.name,
            );

            if (name != null) _vm.save(name: name);

            _vm.dropEditorFocus();
          },
        ),
        const SizedBox(width: 8),
        FloatingProgressButton(
          inProgress: _vm.saveProgress,
          heroTag: 'aiBtn',
          tooltip: 'AI boost',
          mini: true,
          icon: const Icon(Icons.accessible_forward),
          onPressed: () async {
            _showAI.value = !_showAI.value;
          },
        ),
      ],
    );
  }

  Widget _buildEditor() {
    return ValueListenableBuilder(
      valueListenable: _vm.settingUp,
      builder: (_, inProgress, __) {
        if (inProgress) return _buildLoader();

        return Stack(
          children: [
            _buildMonacoWebView(),
            // Floating buttons
            Positioned(bottom: 16, left: 16, child: _buildButtons()),
            ValueListenableBuilder(
              valueListenable: _isDragging,
              builder: (_, isDragging, __) {
                if (!isDragging) return SizedBox();

                return Positioned.fill(child: _buildDragOverlay());
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultView() {
    return ValueListenableBuilder(
      valueListenable: _sidebarWidth,
      builder: (_, value, __) {
        return Stack(
          children: [
            Container(
              width: value,
              height: double.infinity,
              color: AppColor.black,
              child: ResultView(
                language: _vm.language,
                outputStream: _vm.compileResultStream,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _isDragging,
              builder: (_, isDragging, __) {
                if (!isDragging) return SizedBox();

                return Positioned.fill(child: _buildDragOverlay());
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAIView() {
    return ValueListenableBuilder(
      valueListenable: _bottomBarHeight,
      builder: (_, value, __) {
        return Stack(
          children: [
            Container(
              height: value,
              width: double.infinity,
              color: AppColor.black,
              child: AiHelperPage(monacoWebBridgeService: _vm.bridge),
            ),
            ValueListenableBuilder(
              valueListenable: _isDragging,
              builder: (_, isDragging, __) {
                if (!isDragging) return SizedBox();

                return Positioned.fill(child: _buildDragOverlay());
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildResizeSeparator() {
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
            return Container(
              width: 6,
              color: isDragging ? Colors.grey : AppColor.mainGreyLighter,
            );
          },
        ),
      ),
    );
  }

  Widget _buildResizeSeparatorHorizontal() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragUpdate: (details) {
        _bottomBarHeight.value -= details.delta.dy;
        _bottomBarHeight.value = _bottomBarHeight.value.clamp(200, 800);
      },
      onVerticalDragStart: (_) => _isDragging.value = true,
      onVerticalDragEnd: (_) => _isDragging.value = false,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isDragging,
          builder: (_, isDragging, __) {
            return Container(
              height: 6,
              width: double.infinity,
              color: isDragging ? Colors.grey : AppColor.mainGreyLighter,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: SizedBox(
        height: 50,
        width: 50,
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// HTML views (Monaco or ResultWebView) mess up drag gesture
  /// so we put container over it to prevent it
  Widget _buildDragOverlay() {
    return Container(color: AppColor.mainGreyLighter.withValues(alpha: 0.01));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildEditor()),
              _buildResizeSeparator(),
              _buildResultView(),
            ],
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _showAI,
          builder: (_, show, __) {
            if (!show) return SizedBox();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildResizeSeparatorHorizontal(), _buildAIView()],
            );
          },
        ),
      ],
    );
  }
}
