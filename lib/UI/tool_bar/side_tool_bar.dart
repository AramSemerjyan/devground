import 'package:flutter/material.dart';
import 'package:multi_window/multi_window.dart';

import '../../utils/app_colors.dart';

class SideToolBar extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const SideToolBar({super.key, required this.navigatorKey});

  @override
  State<SideToolBar> createState() => _SideToolBarState();
}

class _SideToolBarState extends State<SideToolBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: 50,
      color: AppColor.mainGrey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
            message: 'New window',
            child: InkWell(
              onTap: () async {
                await MultiWindow.create(
                  DateTime.now().microsecondsSinceEpoch.toString(),
                  alignment: Alignment.center,
                );
              },
              child: Icon(Icons.add, color: AppColor.mainGreyLighter),
            ),
          ),
          const SizedBox(height: 10),
          Tooltip(
            message: 'History',
            child: InkWell(
              onTap: () async {
                widget.navigatorKey.currentState?.pushNamed('history');
              },
              child: Icon(Icons.history_edu, color: AppColor.mainGreyLighter),
            ),
          ),
          const SizedBox(height: 10),
          Tooltip(
            message: 'Settings',
            child: InkWell(
              onTap: () {
                widget.navigatorKey.currentState?.pushNamed('settings');
              },
              child: Icon(Icons.settings, color: AppColor.mainGreyLighter),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
