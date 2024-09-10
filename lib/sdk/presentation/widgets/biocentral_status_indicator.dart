import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../bloc/biocentral_state.dart';
import '../../util/format_util.dart';
import '../../util/size_config.dart';

class BiocentralStatusIndicator extends StatefulWidget {
  final BiocentralCommandState state;
  final bool center;

  const BiocentralStatusIndicator({
    super.key,
    required this.state,
    this.center = false,
  });

  @override
  State<BiocentralStatusIndicator> createState() => _BiocentralStatusIndicatorState();
}

class _BiocentralStatusIndicatorState extends State<BiocentralStatusIndicator> {
  final String _animatedLogoBaseUrl = "assets/animated_logo/animated_logo";
  final String _animatedLogoFileFormat = ".png";
  final int _numberAnimatedLogos = 6;
  final Duration _switchDuration = const Duration(milliseconds: 500);

  bool _shimmer = true;
  int _currentShownLogo = 1;
  late Timer _logoTimer;
  String _currentLogoPath = "";

  @override
  void initState() {
    super.initState();
    _setInitialLogo();
    _startLogoAnimation();
  }

  @override
  void dispose() {
    _logoTimer.cancel();
    super.dispose();
  }

  void _setInitialLogo() {
    _currentLogoPath = "$_animatedLogoBaseUrl$_currentShownLogo$_animatedLogoFileFormat";
  }

  void _startLogoAnimation() {
    _logoTimer = Timer.periodic(_switchDuration, (timer) {
      if (mounted) {
        setState(() {
          if (widget.state.isOperating()) {
            _currentShownLogo = (_currentShownLogo % _numberAnimatedLogos) + 1;
            _currentLogoPath = "$_animatedLogoBaseUrl$_currentShownLogo$_animatedLogoFileFormat";
          } else {
            _currentLogoPath = fullLogo();
            _shimmer = false;
            timer.cancel();
          }
        });
      }
    });
  }

  String fullLogo() {
    return "$_animatedLogoBaseUrl$_numberAnimatedLogos$_animatedLogoFileFormat";
  }

  @override
  Widget build(BuildContext context) {
    Color shimmerHighlightColor = Theme.of(context).primaryColor;
    if (widget.state.isErrored()) {
      shimmerHighlightColor = Colors.red;
    } else if (widget.state.isFinished()) {
      shimmerHighlightColor = Colors.green;
    }

    return Row(
      mainAxisAlignment: widget.center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: shimmerHighlightColor,
            period: const Duration(seconds: 3),
            enabled: _shimmer,
            child: widget.state.isIdle()
                ? Container()
                : AnimatedSwitcher(
                    duration: _switchDuration,
                    child: Image.asset(
                      _currentLogoPath,
                      key: ValueKey(_currentLogoPath),
                      fit: BoxFit.contain,
                      height: SizeConfig.screenWidth(context) * 0.04,
                      width: SizeConfig.screenWidth(context) * 0.04,
                    ),
                  ),
          ),
        ),
        SizedBox(
          width: SizeConfig.safeBlockHorizontal(context) * 1,
        ),
        Flexible(flex: 2, child: buildStateInformation(widget.state.stateInformation))
      ],
    );
  }

  Widget buildStateInformation(BiocentralCommandStateInformation stateInformation) {
    final stateInformationText = Text(
      stateInformation.information,
      maxLines: 2,
      style: Theme.of(context).textTheme.labelSmall,
    );
    if (stateInformation.commandProgress == null) {
      return stateInformationText;
    }
    final progress = stateInformation.commandProgress!;

    return Column(
      children: [
        stateInformationText,
        const SizedBox(height: 8),
        SizedBox(
          width: min(SizeConfig.screenWidth(context) * 0.125, 125),
          child: LinearProgressIndicator(
            value: progress.progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatProgressInformation(progress),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  String _formatProgressInformation(BiocentralCommandProgress progress) {
    String currentString =
        progress.isByteProgress ? bytesAsFormatString(progress.current) : progress.current.toString();
    if (progress.total != null) {
      String totalString = progress.isByteProgress ? bytesAsFormatString(progress.total!) : progress.total.toString();
      final percent = (progress.progress ?? 0) * 100;
      return '$currentString / $totalString (${percent.toStringAsFixed(0)}%)';
    } else {
      return currentString;
    }
  }
}
