import 'dart:math';

import 'package:flutter/material.dart';

import 'package:biocentral/sdk/util/size_config.dart';

class BiocentralQuickMessage extends StatefulWidget {
  final String message;
  final Widget child;
  final bool triggered;
  final Function() callback;

  const BiocentralQuickMessage({
    required this.message, required this.child, required this.triggered, required this.callback, super.key,
  });

  @override
  State<BiocentralQuickMessage> createState() => _BiocentralQuickMessageState();
}

class _BiocentralQuickMessageState extends State<BiocentralQuickMessage> {
  final Duration _duration = const Duration(seconds: 1);
  final int _animationSteps = 25;
  final double _startOpacity = 0.5;

  @override
  void initState() {
    super.initState();
  }

  Stream<double> opacityStream() async* {
    double opacity = _startOpacity;
    final int decreaseDurationMS = (_duration.inMilliseconds / _animationSteps).round();
    for (int i = 0; i < _animationSteps; i++) {
      await Future.delayed(Duration(milliseconds: decreaseDurationMS));

      opacity += (1.0 - _startOpacity) / _animationSteps;
      yield min(1.0, opacity);
    }
    yield 0.0;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.triggered) {
      return Container(child: widget.child);
    }
    return Stack(
      children: [
        StreamBuilder<double>(
            stream: opacityStream(),
            builder: (context, snapshot) {
              return AnimatedOpacity(
                duration: _duration,
                opacity: snapshot.hasData ? snapshot.data! : 0.0,
                onEnd: widget.callback(),
                child: Padding(
                  padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal(context)),
                  child: Text(widget.message, style: Theme.of(context).textTheme.labelSmall),
                ),
              );
            },),
        widget.child,
      ],
    );
  }
}
