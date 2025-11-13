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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.mainGreyLighter.withValues(alpha: 0.15)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColor.mainGreyLighter),
        ),
      ),
    );
  }
}
