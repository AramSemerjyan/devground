import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';

class SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: TextStyle(fontSize: 19, color: AppColor.white)),
        const SizedBox(height: 5),
        Container(width: double.infinity, height: 1, color: AppColor.white),
        const SizedBox(height: 15),
        Flexible(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}
