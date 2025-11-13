import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class SideBarButton extends StatelessWidget {
  final String? toolTip;
  final VoidCallback? onTap;
  final IconData icon;
  final bool isSelected;

  const SideBarButton({
    super.key,
    required this.icon,
    this.toolTip,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: toolTip,
      child: InkWell(
        onTap: onTap,
        child: Icon(icon, color: AppColor.mainGreyLighter),
      ),
    );
  }
}
