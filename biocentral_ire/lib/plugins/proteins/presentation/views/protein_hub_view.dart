import 'package:biocentral/plugins/proteins/presentation/views/protein_database_view.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_view.dart';
import 'package:biocentral/sdk/util/size_config.dart';
import 'package:flutter/material.dart';

import 'package:biocentral/plugins/proteins/presentation/views/protein_insights_view.dart';

class ProteinHubView extends StatefulWidget {
  final List<Widget> commandWidgets;

  const ProteinHubView({required this.commandWidgets, super.key});

  @override
  State<ProteinHubView> createState() => _ProteinHubViewState();
}

class _ProteinHubViewState extends State<ProteinHubView> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ProteinDatabaseViewState> _proteinDatabaseViewState = GlobalKey<ProteinDatabaseViewState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: TabBar(
                labelColor: Theme.of(context).colorScheme.onSurface,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(icon: Icon(Icons.list_alt), text: 'Database'),
                  Tab(icon: Icon(Icons.auto_graph), text: 'Insights'),
                  Tab(icon: Icon(Icons.insert_chart), text: 'Commands'),
                ],
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            Flexible(
              flex: 5,
              child: TabBarView(
                children: [
                  ProteinDatabaseView(key: _proteinDatabaseViewState, onProteinSelected: (protein) => null), // TODO
                  const ProteinInsightsView(),
                  BiocentralCommandView(commandWidgets: widget.commandWidgets),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
