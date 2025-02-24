import 'package:flutter/material.dart';

class BiocentralTooltip extends StatefulWidget {
  final String message;
  final Widget child;
  final Color? color;

  const BiocentralTooltip({required this.message, required this.child, super.key, this.color});

  @override
  State<BiocentralTooltip> createState() => _BiocentralTooltipState();
}

class _BiocentralTooltipState extends State<BiocentralTooltip> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.message,
      textStyle: Theme.of(context).textTheme.labelMedium,
      decoration: BoxDecoration(color: widget.color ?? Theme.of(context).colorScheme.secondary),
      child: widget.child,
    );
  }
}
