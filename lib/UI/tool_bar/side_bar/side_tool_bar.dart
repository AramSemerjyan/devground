import 'dart:async';

import 'package:dartpad_lite/UI/app/app_pages.dart';
import 'package:dartpad_lite/UI/tool_bar/side_bar/side_bar_button.dart';
import 'package:dartpad_lite/core/services/event_service/event_service.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../app/app_scope.dart';

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

  final List<StreamSubscription<AppPages>> _subscriptions = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscriptions.add(
        AppPageScope.of(context).observer.routeUpdated.listen((page) {
          _selectedPage.value = page;
        }),
      );
    });
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: 50,
      color: AppColor.mainGrey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 15),
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
          ValueListenableBuilder(
            valueListenable: _selectedPage,
            builder: (_, selectedTab, __) {
              return Column(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _pages.map((page) {
                  return SideBarButton(
                    icon: page.icon,
                    toolTip: page.value,
                    isSelected: page == selectedTab,
                    onTap: () {
                      if (page == selectedTab) return;

                      EventService.emit(
                        type: EventType.aiModeChanged,
                        data: false,
                      );

                      widget.navigatorKey.currentState?.pushReplacementNamed(
                        page.value,
                      );
                      _selectedPage.value = page;
                    },
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
