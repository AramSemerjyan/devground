import 'package:dartpad_lite/UI/settings/widget/path_selector_vm.dart';
import 'package:flutter/material.dart';

class PathSelector extends StatefulWidget {
  final String? path;
  final String? label;
  final Function(String?)? onPathSelect;

  const PathSelector({super.key, this.path, this.label, this.onPathSelect});

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
        Text(
          widget.path ?? '',
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            widget.onPathSelect?.call(await _vm.getPath());
          },
          icon: const Icon(Icons.folder_open),
          label: const Text("Select SDK Folder"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0E639C),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
