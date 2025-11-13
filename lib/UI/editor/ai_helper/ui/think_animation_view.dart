import 'dart:async';

import 'package:flutter/material.dart';

class ThinkingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration interval;

  const ThinkingText({
    super.key,
    this.text = 'Thinking',
    this.style,
    this.interval = const Duration(milliseconds: 500),
  });

  @override
  State<ThinkingText> createState() => _ThinkingTextState();
}

class _ThinkingTextState extends State<ThinkingText> {
  int _dotCount = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) {
      setState(() {
        _dotCount = (_dotCount + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    return Text('${widget.text}$dots', style: widget.style);
  }
}
