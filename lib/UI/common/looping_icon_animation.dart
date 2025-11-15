import 'package:flutter/material.dart';

class LoopingIconAnimation extends StatefulWidget {
  final List<Icon> icons;
  final Duration duration;

  const LoopingIconAnimation({
    super.key,
    required this.icons,
    this.duration = const Duration(seconds: 1),
  }) : assert(icons.length >= 2, "At least 2 icons are required");

  @override
  State<LoopingIconAnimation> createState() => _LoopingIconAnimationState();
}

class _LoopingIconAnimationState extends State<LoopingIconAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final progress = _controller.value;

        final current =
            (progress * widget.icons.length).floor() % widget.icons.length;
        final next = (current + 1) % widget.icons.length;

        final localT = (progress * widget.icons.length) % 1.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(opacity: 1.0 - localT, child: widget.icons[current]),
            Opacity(opacity: localT, child: widget.icons[next]),
          ],
        );
      },
    );
  }
}
