import 'dart:async';

import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class ToolBarContainer extends StatefulWidget {
  final Widget child;
  final Color mainColor;
  final Color pulsingStart;
  final Color pulsingEnd;
  final Duration pulseDuration;
  final Color? overrideColor;
  final Duration? overrideDuration;
  final bool pulsing;

  const ToolBarContainer({
    super.key,
    required this.child,
    required this.mainColor,
    this.pulsingStart = AppColor.aiBlue,
    this.pulsingEnd = AppColor.blue,
    this.pulseDuration = const Duration(seconds: 1),
    this.overrideColor = AppColor.mainGrey,
    this.overrideDuration,
    this.pulsing = false,
  });

  @override
  State<ToolBarContainer> createState() => _ToolBarContainerState();
}

class _ToolBarContainerState extends State<ToolBarContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _pulseAnimation;
  Color? _currentColor;

  Timer? _overrideTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    );

    _pulseAnimation = ColorTween(
      begin: widget.pulsingStart,
      end: widget.pulsingEnd,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _currentColor = widget.mainColor;
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant ToolBarContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() {
    _overrideTimer?.cancel();

    if (widget.overrideColor != null && widget.overrideDuration != null) {
      // Temporarily override color
      setState(() => _currentColor = widget.overrideColor);
      _overrideTimer = Timer(widget.overrideDuration!, () {
        _overrideTimer = null;
        if (widget.pulsing) {
          _controller.repeat(reverse: true);
        } else {
          setState(() => _currentColor = widget.mainColor);
        }
      });
      _controller.stop();
    } else {
      if (widget.pulsing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        setState(() => _currentColor = widget.mainColor);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _overrideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, __) {
        return AnimatedContainer(
          height: 20,
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
          color: _overrideTimer != null
              ? _currentColor
              : (widget.pulsing ? _pulseAnimation.value : _currentColor),
          child: widget.child,
        );
      },
    );
  }
}
