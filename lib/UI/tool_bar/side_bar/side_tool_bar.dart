import 'package:dartpad_lite/UI/app/app_pages.dart';
import 'package:dartpad_lite/UI/tool_bar/side_bar/side_bar_button.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class SideToolBar extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const SideToolBar({super.key, required this.navigatorKey});

  @override
  State<SideToolBar> createState() => _SideToolBarState();
}

class _SideToolBarState extends State<SideToolBar> {
  final List<AppPages> _pages = [
    AppPages.editor,
    AppPages.history,
    AppPages.settings,
  ];

  final ValueNotifier<AppPages> _selectedPage = ValueNotifier(AppPages.editor);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: 50,
      color: AppColor.mainGrey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 10),
          Tooltip(
            message: 'New window',
            child: InkWell(
              onTap: () async {
                final controller = await WindowController.create(
                  WindowConfiguration(
                    hiddenAtLaunch: false,
                    arguments: 'YOUR_WINDOW_ARGUMENTS_HERE',
                  ),
                );

                await controller.show();
              },
              child: Icon(Icons.add, color: AppColor.mainGreyLighter),
            ),
          ),
          const Spacer(),
          Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _pages.map((page) {
              return SideBarButton(
                icon: page.icon,
                toolTip: page.value,
                onTap: () {
                  widget.navigatorKey.currentState?.pushReplacementNamed(
                    page.value,
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
