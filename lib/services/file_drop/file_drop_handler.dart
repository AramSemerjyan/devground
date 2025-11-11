import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

class FileDropHandler extends StatefulWidget {
  final Widget child;
  final void Function(File file)? onFileDropped;

  const FileDropHandler({super.key, this.onFileDropped, required this.child});

  @override
  State<FileDropHandler> createState() => _FileDropHandlerState();
}

class _FileDropHandlerState extends State<FileDropHandler> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) {
        for (final file in details.files) {
          if (file.path.isNotEmpty) {
            widget.onFileDropped?.call(File(file.path));
          }
        }
        setState(() => _dragging = false);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          // Your app content
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: _dragging,
              child: Container(
                color: _dragging
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
                child: const Center(child: Text('Drop file here')),
              ),
            ),
          ),
          if (_dragging)
            Container(
              color: Colors.blue.withValues(alpha: 0.1),
              alignment: Alignment.center,
              child: const Text(
                'Drop to open file',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }
}
