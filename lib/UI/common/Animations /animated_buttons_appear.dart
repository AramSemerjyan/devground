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
  List<Animation<Offset>> _slideAnimations = const [];
  List<Animation<double>> _fadeAnimations = const [];
  List<Animation<Offset>> _verticalSlideAnimations = const [];
  List<Animation<double>> _verticalFadeAnimations = const [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rebuildAnimations();
  }

  @override
  void didUpdateWidget(covariant AnimatedButtonsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.buttons.length != oldWidget.buttons.length ||
        widget.verticalButtons.length != oldWidget.verticalButtons.length) {
      _rebuildAnimations();
    }
  }

  void _rebuildAnimations() {
    final itemCount = widget.buttons.length > 1 ? widget.buttons.length - 1 : 0;
    final verticalCount = widget.verticalButtons.length;

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
    final otherButtons = widget.buttons.length > 1
        ? widget.buttons.sublist(1)
        : const <Widget>[];
    final verticalButtons = widget.verticalButtons;

    if (firstButton == null) {
      return const SizedBox.shrink();
    }

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final progress = _controller.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (verticalButtons.isNotEmpty)
                ClipRect(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    heightFactor: progress,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(verticalButtons.length, (i) {
                        final reversedIndex = verticalButtons.length - 1 - i;
                        final btn = verticalButtons[reversedIndex];
                        final isLast = i == verticalButtons.length - 1;
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                          child: Transform.translate(
                            offset:
                                _verticalSlideAnimations[reversedIndex].value *
                                100,
                            child: Opacity(
                              opacity:
                                  _verticalFadeAnimations[reversedIndex].value,
                              child: btn,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              SizedBox(height: verticalButtons.isNotEmpty ? 16 * progress : 0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  firstButton,
                  if (otherButtons.isNotEmpty) SizedBox(width: 8 * progress),
                  if (otherButtons.isNotEmpty)
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(otherButtons.length, (i) {
                            final btn = otherButtons[i];
                            final hasLeftSpace = i != 0;
                            return Transform.translate(
                              offset: _slideAnimations[i].value * 100,
                              child: Opacity(
                                opacity: _fadeAnimations[i].value,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: hasLeftSpace ? 8 : 0,
                                  ),
                                  child: btn,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
