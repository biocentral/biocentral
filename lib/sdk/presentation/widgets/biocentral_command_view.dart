import 'package:flutter/material.dart';

class BiocentralCommandView extends StatefulWidget {
  final List<Widget> commandWidgets;

  const BiocentralCommandView({required this.commandWidgets, super.key});

  @override
  State<BiocentralCommandView> createState() => _BiocentralCommandViewState();
}

class _BiocentralCommandViewState extends State<BiocentralCommandView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(child: Column(children: widget.commandWidgets));
  }

  @override
  bool get wantKeepAlive => true;
}
