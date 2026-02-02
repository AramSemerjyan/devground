import 'package:flutter/material.dart';

class AnimatedButtonsRow extends StatefulWidget {
  final List<Widget> buttons;
  final List<Widget> verticalButtons;

  const AnimatedButtonsRow({
    super.key,
    this.buttons = const [],
    this.verticalButtons = const [],
  });

  @override
  State<AnimatedButtonsRow> createState() => _AnimatedButtonsRowState();
}

class _AnimatedButtonsRowState extends State<AnimatedButtonsRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<Offset>> _slideAnimations;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _verticalSlideAnimations;
  late final List<Animation<double>> _verticalFadeAnimations;

  @override
  void initState() {
    super.initState();

    final itemCount = widget.buttons.length - 1; // first button always visible
    final verticalCount = widget.verticalButtons.length;
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

    _verticalSlideAnimations = List.generate(verticalCount, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.15, 1.0, curve: Curves.easeOut),
        ),
      );
    });

    _verticalFadeAnimations = List.generate(verticalCount, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.15, 1.0, curve: Curves.easeIn),
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
    final verticalButtons = widget.verticalButtons;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: List.generate(verticalButtons.length, (i) {
                  final reversedIndex = verticalButtons.length - 1 - i;
                  final btn = verticalButtons[reversedIndex];
                  return Transform.translate(
                    offset: _verticalSlideAnimations[reversedIndex].value * 100,
                    child: Opacity(
                      opacity: _verticalFadeAnimations[reversedIndex].value,
                      child: btn,
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 16),
          // Horizontal
          Row(
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
        ],
      ),
    );
  }
}
