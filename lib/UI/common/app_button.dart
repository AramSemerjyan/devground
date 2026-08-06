import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class AppButton extends StatefulWidget {
  final ValueNotifier<bool>? inProgress;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? tooltip;
  final String? heroTag;
  final bool isSelected;

  const AppButton({
    super.key,
    this.inProgress,
    this.onPressed,
    this.icon,
    this.tooltip,
    this.heroTag,
    this.isSelected = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.inProgress == null) {
      return _buildButton(false);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: widget.inProgress!,
      builder: (_, value, __) => _buildButton(value),
    );
  }

  Widget _buildButton(bool loading) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _hovered ? AppColor.selected : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: loading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.blue,
                ),
              )
            : GestureDetector(
                onTap: widget.onPressed,
                child: Tooltip(
                  message: widget.tooltip ?? '',
                  child: Icon(
                    widget.icon,
                    color: _hovered
                        ? AppColor.white50
                        : widget.isSelected
                        ? AppColor.white
                        : AppColor.mainGreyLighter,
                  ),
                ),
              ),
      ),
    );
  }
}
