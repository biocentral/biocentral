import 'package:flutter/material.dart';

class BiocentralBlinkingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double opacityEnd;

  const BiocentralBlinkingAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.opacityEnd = 0.3,
    super.key,
  });

  @override
  State<BiocentralBlinkingAnimation> createState() => _BiocentralBlinkingAnimationState();
}

class _BiocentralBlinkingAnimationState extends State<BiocentralBlinkingAnimation> with TickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - (_animationController.value * (1.0 - widget.opacityEnd)),
          child: widget.child,
        );
      },
    );
  }
}
