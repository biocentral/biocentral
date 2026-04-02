import 'dart:async';
import 'dart:math';

import 'package:biocentral/sdk/bloc/biocentral_command.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:biocentral/sdk/bloc/biocentral_state.dart';
import 'package:biocentral/sdk/util/format_util.dart';
import 'package:biocentral/sdk/util/size_config.dart';

class BiocentralStatusIndicator extends StatefulWidget {
  final BiocentralCommandMetaData? metaData;
  final bool center;

  const BiocentralStatusIndicator({
    required this.metaData,
    super.key,
    this.center = false,
  });

  @override
  State<BiocentralStatusIndicator> createState() => _BiocentralStatusIndicatorState();
}

class _BiocentralStatusIndicatorState extends State<BiocentralStatusIndicator> {
  final String _animatedLogoBaseUrl = 'assets/animated_logo/animated_logo';
  final String _animatedLogoFileFormat = '.png';
  final int _numberAnimatedLogos = 6;
  final Duration _switchDuration = const Duration(milliseconds: 500);

  bool _shimmer = true;
  int _currentShownLogo = 1;
  late Timer _logoTimer;
  String _currentLogoPath = '';

  @override
  void initState() {
    super.initState();
    _setInitialLogo();
    _startLogoAnimation();
  }

  @override
  void didUpdateWidget(covariant BiocentralStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // TODO Can be deleted?
    if(oldWidget.metaData.runtimeType != widget.metaData.runtimeType) {
      _setInitialLogo();
      _startLogoAnimation();
    }
  }

  @override
  void dispose() {
    _logoTimer.cancel();
    super.dispose();
  }

  void _setInitialLogo() {
    _currentLogoPath = '$_animatedLogoBaseUrl$_currentShownLogo$_animatedLogoFileFormat';
  }

  void _startLogoAnimation() {
    _logoTimer = Timer.periodic(_switchDuration, (timer) {
      if (mounted) {
        setState(() {
          if (widget.metaData!.endTime != null || widget.metaData?.error != null) {
            _currentLogoPath = fullLogo();
            _shimmer = false;
            timer.cancel();
          } else {
            _currentShownLogo = (_currentShownLogo % _numberAnimatedLogos) + 1;
            _currentLogoPath = '$_animatedLogoBaseUrl$_currentShownLogo$_animatedLogoFileFormat';
          }
        });
      }
    });
  }

  String fullLogo() {
    return '$_animatedLogoBaseUrl$_numberAnimatedLogos$_animatedLogoFileFormat';
  }

  @override
  Widget build(BuildContext context) {
    if(widget.metaData == null) {
      return Container();
    }
    final BiocentralCommandMetaData metaData = widget.metaData!;

    Color shimmerHighlightColor = Theme.of(context).primaryColor;
    if (metaData.error != null) {
      shimmerHighlightColor = Colors.red;
    } else if (metaData.endTime != null) {
      shimmerHighlightColor = Colors.green;
    }

    final logo = _logoTimer.isActive ? _currentLogoPath : fullLogo();
    return Row(
      mainAxisAlignment: widget.center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: shimmerHighlightColor,
            period: const Duration(seconds: 3),
            enabled: _shimmer,
            child: AnimatedSwitcher(
                    duration: _switchDuration,
                    child: Image.asset(
                      logo,
                      key: ValueKey(logo),
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
        Flexible(flex: 2, child: buildStateInformation(metaData)),
      ],
    );
  }

  Widget buildStateInformation(BiocentralCommandMetaData metaData) {
    final progress = metaData.progressLog.lastOrNull;
    final stateInformationText = Text(
      metaData.error ?? progress?.information ?? '',
      maxLines: 2,
      style: Theme.of(context).textTheme.labelSmall,
    );
    if (progress?.total == null || progress?.total == 0) {
      return stateInformationText;
    }

    return Column(
      children: [
        stateInformationText,
        const SizedBox(height: 6),
        SizedBox(
          width: min(SizeConfig.screenWidth(context) * 0.125, 125),
          child: LinearProgressIndicator(
            value: progress!.progress(),
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _formatProgressInformation(progress),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  String _formatProgressInformation(BiocentralCommandProgress progress) {
    final String currentString =
        progress.isByteProgress ? bytesAsFormatString(progress.current) : progress.current.toString();
    final String hint = progress.hint?.trim() ?? '';
    if (progress.total != null) {
      final String totalString = progress.isByteProgress ? bytesAsFormatString(progress.total!) : progress.total.toString();
      final percent = (progress.progress() ?? 0) * 100;
      return '$hint $currentString / $totalString (${percent.toStringAsFixed(0)}%)';
    } else {
      return '$hint $currentString';
    }
  }
}
