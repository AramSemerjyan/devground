import 'package:dartpad_lite/UI/settings/widget/path_selector_vm.dart';
import 'package:flutter/material.dart';

enum PathSelectorType { file, path }

class PathSelector extends StatefulWidget {
  final String? path;
  final String? label;
  final PathSelectorType type;
  final Function(String?)? onPathSelect;

  const PathSelector({
    super.key,
    this.type = PathSelectorType.path,
    this.path,
    this.label,
    this.onPathSelect,
  });

  @override
  State<PathSelector> createState() => _PathSelectorState();
}

class _PathSelectorState extends State<PathSelector> {
  final PathSelectorVMInterface _vm = PathSelectorVM();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SelectableText(
          widget.path ?? '',
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final path = await (widget.type == PathSelectorType.path
                ? _vm.getPath()
                : _vm.getFile());

            widget.onPathSelect?.call(path);
          },
          icon: const Icon(Icons.folder_open),
          label: Text(widget.label ?? ''),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0E639C),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
