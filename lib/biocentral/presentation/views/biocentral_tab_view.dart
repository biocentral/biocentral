import 'package:biocentral/biocentral/presentation/displays/biocentral_command_log_display.dart';
import 'package:biocentral/biocentral/presentation/displays/biocentral_logs_display.dart';
import 'package:biocentral/biocentral/presentation/views/biocentral_command_view.dart';
import 'package:flutter/material.dart';

class BiocentralTabView extends StatefulWidget {
  const BiocentralTabView({super.key});

  @override
  State<BiocentralTabView> createState() => _BiocentralTabViewState();
}

class _BiocentralTabViewState extends State<BiocentralTabView> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  // LOGIC FUNCTIONS GO HERE

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Column(mainAxisSize: MainAxisSize.min, children: [
      Flexible(flex: 2, child: BiocentralCommandView()),
      Flexible(
        flex: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(flex: 3, child: BiocentralCommandLogDisplay()),
            Flexible(flex: 2, child: BiocentralLogsDisplay())
          ],
        ),
      ),
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}
