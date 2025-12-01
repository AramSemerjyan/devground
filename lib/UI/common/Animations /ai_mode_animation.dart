import 'package:flutter/material.dart';

import '../looping_icon_animation.dart';

class AIModeAnimation extends StatelessWidget {
  final Color? color;

  const AIModeAnimation({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return LoopingIconAnimation(
      icons: [
        Icon(Icons.accessible, color: color ?? Colors.white54, size: 18),
        Icon(
          Icons.accessible_forward,
          color: color ?? Colors.white54,
          size: 18,
        ),
      ],
    );
  }
}

class WorkTimerAnimation extends StatelessWidget {
  final double? size;
  final Color? color;

  const WorkTimerAnimation({super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return LoopingIconAnimation(
      duration: const Duration(seconds: 1),
      icons: [
        Icon(
          Icons.hourglass_bottom_outlined,
          color: color ?? Colors.white54,
          size: size ?? 18,
        ),
        Icon(
          Icons.hourglass_top_outlined,
          color: color ?? Colors.white54,
          size: size ?? 18,
        ),
      ],
    );
  }
}
