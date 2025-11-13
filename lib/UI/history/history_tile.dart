import 'dart:io';

import 'package:dartpad_lite/core/extension/file_extension.dart';
import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class HistoryTile extends StatelessWidget {
  final File file;
  final Function(File)? onDelete;
  final Function(File)? onReveal;
  final Function(File)? onSelect;

  const HistoryTile({
    super.key,
    required this.file,
    this.onDelete,
    this.onReveal,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColor.mainGrey,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(file.name, style: TextStyle(color: Colors.grey[400])),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(file.path, style: TextStyle(color: AppColor.mainGreyLighter)),
            const SizedBox(height: 4),
            Text(
              'Last saved: ${file.updatedDate}',
              style: TextStyle(color: AppColor.mainGreyLighter, fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_forever, color: AppColor.error),
              onPressed: () {
                onDelete?.call(file);
              },
            ),
            IconButton(
              icon: const Icon(Icons.folder, color: AppColor.mainGreyLighter),
              onPressed: () {
                onReveal?.call(file);
              },
            ),
          ],
        ),
        onTap: () async {
          onSelect?.call(file);
        },
      ),
    );
  }
}
