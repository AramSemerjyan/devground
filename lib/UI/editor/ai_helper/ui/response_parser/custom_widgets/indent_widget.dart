import 'package:flutter/material.dart';

class BlockQuoteWidget extends StatelessWidget {
  const BlockQuoteWidget({
    super.key,
    required this.child,
    required this.direction,
    required this.color,
    this.width = 3,
  });

  /// The child widget to be indented.
  final Widget child;

  /// The direction of the indent.
  final TextDirection direction;

  /// The color of the indent.
  final Color color;

  /// The width of the indent.
  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: CustomPaint(
            foregroundPainter: BlockQuotePainter(color, direction, width),
            child: child,
          ),
        ),
      ],
    );
  }
}

class BlockQuotePainter extends CustomPainter {
  BlockQuotePainter(this.color, this.direction, this.width);
  final Color color;
  final TextDirection direction;
  final double width;
  @override
  void paint(Canvas canvas, Size size) {
    var left = direction == TextDirection.ltr;
    var start = left ? 0.0 : size.width - width;
    var rect = Rect.fromLTWH(start, 0, width, size.height);
    var paint = Paint()..color = color;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
