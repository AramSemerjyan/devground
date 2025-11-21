import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class FloatingProgressButton extends StatelessWidget {
  final ValueNotifier<bool>? inProgress;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? tooltip;
  final String? heroTag;
  final bool mini;

  const FloatingProgressButton({
    super.key,
    this.inProgress,
    this.onPressed,
    this.icon,
    this.tooltip,
    this.heroTag,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    if (inProgress == null) {
      return _buildButton(false);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: inProgress!,
      builder: (_, value, __) => _buildButton(value),
    );
  }

  Widget _buildButton(bool loading) {
    return FloatingActionButton(
      heroTag: heroTag,
      tooltip: tooltip,
      mini: mini,
      onPressed: loading ? null : onPressed,
      child: loading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor.blue,
              ),
            )
          : Icon(icon, color: AppColor.blue),
    );
  }
}
