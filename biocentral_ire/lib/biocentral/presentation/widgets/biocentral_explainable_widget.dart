import 'dart:async';

import 'package:biocentral/biocentral/bloc/biocentral_sidebar_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BiocentralExplainableWidget extends StatefulWidget {
  final String explain;
  final Widget child;

  const BiocentralExplainableWidget({
    required this.explain,
    required this.child,
    super.key,
  });

  @override
  State<BiocentralExplainableWidget> createState() => _BiocentralExplainableWidgetState();
}

class _BiocentralExplainableWidgetState extends State<BiocentralExplainableWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _isHovering = false;
  bool _showIndicator = false;
  Timer? _indicatorTimer;

  final Duration _indicatorDelay = const Duration(seconds: 2);

  @override
  void dispose() {
    _indicatorTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onEnter() {
    setState(() => _isHovering = true);
    _focusNode.requestFocus();

    // Start timer to show indicator after delay
    _indicatorTimer = Timer(_indicatorDelay, () {
      if (mounted && _isHovering) {
        setState(() => _showIndicator = true);
      }
    });
  }

  void _onExit() {
    setState(() {
      _isHovering = false;
      _showIndicator = false;
    });
    _focusNode.unfocus();

    // Cancel timer if user stops hovering before delay expires
    _indicatorTimer?.cancel();
    _indicatorTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyT) {
            final sideBarBloc = BlocProvider.of<BiocentralSideBarBloc>(context);
            sideBarBloc.add(
              BiocentralSideBarChangeVisibilityEvent(
                displayMode: BiocentralSideBarDisplayMode.help,
                showHelp: widget.explain,
              ),
            );
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          children: [
            widget.child,
            // Optional: Visual indicator (only shown after delay)
            if (_showIndicator)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 12,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Press T',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
