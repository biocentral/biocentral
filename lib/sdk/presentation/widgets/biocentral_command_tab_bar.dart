import 'package:flutter/material.dart';

class BiocentralCommandTabBar extends TabBar {
  const BiocentralCommandTabBar({required super.tabs, required TabController super.controller, super.key});

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
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(color: Theme.of(context).primaryColor),
          tabs: widget.tabs,),
    );
  }
}
