import 'package:flutter/material.dart';

/// Scrollable round tabs controlled by the hub's selected round index.
class EngineeringRoundTabs extends StatefulWidget {
  final List<int> iterations;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  const EngineeringRoundTabs({required this.iterations, required this.selectedIndex, this.onSelected, super.key});

  @override
  State<EngineeringRoundTabs> createState() => _EngineeringRoundTabsState();
}

class _EngineeringRoundTabsState extends State<EngineeringRoundTabs> with TickerProviderStateMixin {
  late TabController _controller = _createController();

  TabController _createController() =>
      TabController(length: widget.iterations.length, initialIndex: widget.selectedIndex, vsync: this);

  @override
  void didUpdateWidget(EngineeringRoundTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iterations.length != widget.iterations.length) {
      _controller.dispose();
      _controller = _createController();
    } else if (_controller.index != widget.selectedIndex) {
      _controller.animateTo(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = widget.iterations.length * 96 > constraints.maxWidth;
        return TabBar(
          controller: _controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          labelPadding: EdgeInsets.zero,
          labelColor: scheme.onSurface,
          unselectedLabelColor: scheme.onSurfaceVariant,
          dividerColor: scheme.outlineVariant,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border(top: BorderSide(color: scheme.primary, width: 2)),
          ),
          onTap: widget.onSelected,
          tabs: [
            for (final iteration in widget.iterations)
              Tooltip(
                message: 'Round $iteration',
                child: SizedBox(
                  width: compact ? 44 : 96,
                  height: 36,
                  child: Tab(text: compact ? '$iteration' : 'Round $iteration'),
                ),
              ),
          ],
        );
      },
    );
  }
}
