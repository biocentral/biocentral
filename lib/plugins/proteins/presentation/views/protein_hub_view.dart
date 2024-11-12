import 'package:biocentral/plugins/proteins/presentation/views/protein_database_view.dart';
import 'package:biocentral/sdk/util/size_config.dart';
import 'package:flutter/material.dart';

import 'protein_insights_view.dart';

class ProteinHubView extends StatefulWidget {

  const ProteinHubView({super.key});

  @override
  State<ProteinHubView> createState() => _ProteinHubViewState();
}

class _ProteinHubViewState extends State<ProteinHubView> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ProteinDatabaseViewState> _proteinDatabaseViewState = GlobalKey<ProteinDatabaseViewState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 1,
              child: TabBar(tabs: const [
                Tab(icon: Icon(Icons.list_alt), text: "Database"),
                Tab(icon: Icon(Icons.auto_graph), text: "Insights"),
              ],),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            Flexible(
              flex: 5,
              child: TabBarView(children: [
                ProteinDatabaseView(key: _proteinDatabaseViewState, onProteinSelected: (protein) => null), // TODO
                ProteinInsightsView()
              ]),
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
