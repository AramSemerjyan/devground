import 'package:flutter/material.dart';

import '../looping_icon_animation.dart';

class AIModeAnimation extends StatelessWidget {
  const AIModeAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return LoopingIconAnimation(
      icons: [
        Icon(Icons.accessible, color: Colors.white54, size: 18),
        Icon(Icons.accessible_forward, color: Colors.white54, size: 18),
      ],
    );
  }
}
