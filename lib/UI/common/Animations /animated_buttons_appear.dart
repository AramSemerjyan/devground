import 'package:flutter/material.dart';

class AnimatedButtonsRow extends StatefulWidget {
  final List<Widget> buttons;

  const AnimatedButtonsRow({super.key, this.buttons = const []});

  @override
  State<AnimatedButtonsRow> createState() => _AnimatedButtonsRowState();
}

class _AnimatedButtonsRowState extends State<AnimatedButtonsRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<Offset>> _slideAnimations;
  late final List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();

    final itemCount = widget.buttons.length - 1; // first button always visible
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimations = List.generate(itemCount, (i) {
      return Tween<Offset>(
        begin: const Offset(-0.5, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.1, 1.0, curve: Curves.easeOut),
        ),
      );
    });

    _fadeAnimations = List.generate(itemCount, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.1, 1.0, curve: Curves.easeIn),
        ),
      );
    });
  }

  void _onHover(bool hovering) {
    if (hovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstButton = widget.buttons.firstOrNull;
    final otherButtons = widget.buttons.sublist(1);

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: Row(
        spacing: 8,
        children: [
          if (firstButton != null) firstButton,
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Row(
                children: List.generate(otherButtons.length, (i) {
                  final btn = otherButtons[i];
                  return Transform.translate(
                    offset: _slideAnimations[i].value * 100,
                    child: Opacity(
                      opacity: _fadeAnimations[i].value,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: btn,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
