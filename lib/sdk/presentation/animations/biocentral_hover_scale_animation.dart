import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BiocentralHoverScaleAnimation extends StatefulWidget {
  final Widget child;

  const BiocentralHoverScaleAnimation({super.key, required this.child});

  @override
  State<BiocentralHoverScaleAnimation> createState() => _BiocentralHoverScaleAnimationState();
}

class _BiocentralHoverScaleAnimationState extends State<BiocentralHoverScaleAnimation> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  // LOGIC FUNCTIONS GO HERE

  @override
  Widget build(BuildContext context) {
    AnimationController animationController = AnimationController(vsync: this);

    return MouseRegion(
      onEnter: (pointerEnterEvent) => animationController.forward(),
      onExit: (pointerExitEvent) => animationController.reset(),
      child: Animate(
          effects: const [ScaleEffect(begin: Offset(0.95, 0.95))],
          controller: animationController,
          autoPlay: false,
          child: widget.child),
    );
  }

// WIDGET FUNCTIONS GO HERE
}
