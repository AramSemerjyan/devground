import 'package:dartpad_lite/core/pages_service/app_page.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class EditorTab extends StatelessWidget {
  final AppPage page;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const EditorTab({
    super.key,
    required this.page,
    this.onClose,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.mainGreyDarker : AppColor.mainGreyDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Row(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              page.file.name,
              style: TextStyle(color: AppColor.mainGreyLighter),
            ),
            GestureDetector(
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
  final List<AppPage> pages;
  final int selectedTab;
  final Function(int)? onSelect;
  final Function(int)? onClose;
  final Function(int)? onCloseOthers;
  final VoidCallback? onCloseAll;

  const EditorTabView({
    super.key,
    this.pages = const [],
    this.selectedTab = 0,
    this.onSelect,
    this.onClose,
    this.onCloseAll,
    this.onCloseOthers,
  });

  void _showContextMenu(
    BuildContext context,
    TapDownDetails details,
    int index,
  ) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final result = await showMenu<String>(
      context: context,
      color: AppColor.mainGreyDark,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        overlay.size.width - details.globalPosition.dx,
        overlay.size.height - details.globalPosition.dy,
      ),
      items: [
        const PopupMenuItem(
          value: 'close',
          child: Text(
            'Close',
            style: TextStyle(color: AppColor.mainGreyLighter),
          ),
        ),
        const PopupMenuItem(
          value: 'close_others',
          child: Text(
            'Close others',
            style: TextStyle(color: AppColor.mainGreyLighter),
          ),
        ),
        const PopupMenuItem(
          value: 'close_all',
          child: Text(
            'Close all',
            style: TextStyle(color: AppColor.mainGreyLighter),
          ),
        ),
      ],
    );

    switch (result) {
      case 'close':
        onClose?.call(index);
        break;
      case 'close_others':
        onCloseOthers?.call(index);
        break;
      case 'close_all':
        onCloseAll?.call();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pages.isEmpty) return SizedBox();

    return Container(
      color: AppColor.mainGrey,
      height: 30,
      width: double.infinity,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 3),
        itemBuilder: (_, i) {
          return GestureDetector(
            onSecondaryTapDown: (details) =>
                _showContextMenu(context, details, i),
            child: EditorTab(
              page: pages[i],
              onTap: () => onSelect?.call(i),
              onClose: () => onClose?.call(i),
              isSelected: i == selectedTab,
            ),
          );
        },
      ),
    );
  }
}
