import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class ButtonsRow extends StatelessWidget {
  final List<Widget> buttons;

  const ButtonsRow({super.key, this.buttons = const []});

  @override
  Widget build(BuildContext context) {
    if (buttons.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColor.mainGrey,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: buttons.asMap().entries.map((entry) {
          final index = entry.key;
          final button = entry.value;
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
            child: button,
          );
        }).toList(),
      ),
    );
  }
}
