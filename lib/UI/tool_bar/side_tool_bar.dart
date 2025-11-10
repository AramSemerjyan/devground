import 'package:flutter/material.dart';

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
