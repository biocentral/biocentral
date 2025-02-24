import 'package:flutter/material.dart';

class BiocentralCommandTabBar extends TabBar {
  const BiocentralCommandTabBar({
    required super.tabs,
    required TabController super.controller,
    super.key,
  });

  @override
  State<BiocentralCommandTabBar> createState() => _BiocentralCommandTabBarState();
}

class _BiocentralCommandTabBarState extends State<BiocentralCommandTabBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        controller: widget.controller,
        isScrollable: true,
        labelColor: Theme.of(context).colorScheme.onSurface,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 4.0,
            color: Theme.of(context).secondaryHeaderColor,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        tabs: widget.tabs,
      ),
    );
  }
}
