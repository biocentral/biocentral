import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

import '../../bloc/biocentral_events.dart';
import '../../bloc/biocentral_state.dart';
import 'biocentral_status_indicator.dart';

class BiocentralStatusBar extends StatefulWidget {
  final EventBus eventBus;

  const BiocentralStatusBar({super.key, required this.eventBus});

  @override
  State<BiocentralStatusBar> createState() => _BiocentralStatusBarState();
}

class _BiocentralStatusBarState extends State<BiocentralStatusBar> {
  final Map<Type, BiocentralCommandState> _commandStateMap = {};

  @override
  void initState() {
    super.initState();
    widget.eventBus.on<BiocentralCommandStateChangedEvent>().listen((event) {
      setState(() {
        _commandStateMap[event.state.runtimeType] = event.state;
        if (event.state.isIdle()) {
          _commandStateMap.remove(event.state.runtimeType);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: _commandStateMap.values.map((state) {
          return Flexible(
            flex: 1,
            child: BiocentralStatusIndicator(state: state),
          );
        }).toList());
  }
}
