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
