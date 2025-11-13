import 'package:flutter/material.dart';

import '../../../core/services/import_file/imported_file.dart';
import '../../../utils/app_colors.dart';

class EditorTab extends StatelessWidget {
  final ImportedFile file;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const EditorTab({
    super.key,
    required this.file,
    this.onClose,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.mainGreyDarker : AppColor.mainGreyDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(file.name, style: TextStyle(color: AppColor.mainGreyLighter)),
            const SizedBox(width: 10),

            InkWell(
              onTap: () {
                onClose?.call();
              },
              child: Icon(
                Icons.close,
                color: AppColor.mainGreyLighter,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditorTabView extends StatelessWidget {
  final List<ImportedFile> files;
  final int selectedTab;
  final Function(int)? onSelect;
  final Function(int)? onClose;

  const EditorTabView({
    super.key,
    this.files = const [],
    this.selectedTab = 0,
    this.onSelect,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return SizedBox();

    return Container(
      color: AppColor.mainGrey,
      height: 30,
      width: double.infinity,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        separatorBuilder: (_, __) => const SizedBox(width: 3),
        itemBuilder: (_, i) {
          return EditorTab(
            file: files[i],
            onTap: () => onSelect?.call(i),
            onClose: () => onClose?.call(i),
            isSelected: i == selectedTab,
          );
        },
      ),
    );
  }
}
