import 'package:flutter/material.dart';

import 'package:biocentral/sdk/util/size_config.dart';

class BiocentralDialog extends StatefulWidget {
  final bool small;
  final List<Widget> children;

  const BiocentralDialog({required this.children, super.key, this.small = false});

  @override
  State<BiocentralDialog> createState() => _BiocentralDialogState();
}

class _BiocentralDialogState extends State<BiocentralDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // Set up the fade animation controller and animation
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Start the animation to fade in the dialog
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    // TODO Small does not work yet
    final double sizeFactor = widget.small ? 0.4 : 0.8;

    return AnimatedBuilder(
        animation: _fadeInAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeInAnimation.value,
            child: Dialog(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              child: Center(
                child: SizedBox(
                  width: SizeConfig.screenWidth(context) * sizeFactor,
                  height: SizeConfig.screenHeight(context) * sizeFactor,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: buildChildrenWithPadding(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },);
  }

  List<Widget> buildChildrenWithPadding() {
    final List<Widget> result = [];
    final double height = SizeConfig.safeBlockVertical(context);
    for (Widget widget in widget.children) {
      result.add(widget);
      result.add(SizedBox(height: height));
    }
    return result;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
