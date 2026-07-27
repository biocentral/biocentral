import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:flutter/material.dart';

class BiocentralCommandView extends StatefulWidget {
  final List<Widget> commandWidgets;

  const BiocentralCommandView({required this.commandWidgets, super.key});

  @override
  State<BiocentralCommandView> createState() => _BiocentralCommandViewState();
}

class _BiocentralCommandViewState extends State<BiocentralCommandView> with AutomaticKeepAliveClientMixin {
  final _expandedToken = ValueNotifier<Object?>(null);

  @override
  void dispose() {
    _expandedToken.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BiocentralCommandGroupScope(
      notifier: _expandedToken,
      child: SingleChildScrollView(
        child: Column(
          spacing: 2.0,
          children: widget.commandWidgets,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}