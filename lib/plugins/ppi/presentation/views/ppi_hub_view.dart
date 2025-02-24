import 'package:biocentral/plugins/ppi/presentation/views/ppi_database_tests_view.dart';
import 'package:biocentral/plugins/ppi/presentation/views/ppi_database_view.dart';
import 'package:biocentral/plugins/ppi/presentation/views/ppi_insights_view.dart';
import 'package:biocentral/sdk/util/size_config.dart';
import 'package:flutter/material.dart';

class PPIHubView extends StatefulWidget {
  const PPIHubView({super.key});

  @override
  State<PPIHubView> createState() => _PPIHubViewState();
}

class _PPIHubViewState extends State<PPIHubView> with AutomaticKeepAliveClientMixin {
  final GlobalKey<PPIDatabaseViewState> _ppiDatabaseViewState = GlobalKey<PPIDatabaseViewState>();

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
                tabs: [
                  const Tab(icon: Icon(Icons.list_alt), text: 'Database'),
                  const Tab(icon: Icon(Icons.auto_graph), text: 'Insights'),
                  const Tab(icon: Icon(Icons.check_box_rounded), text: 'Data Tests'),
                ],
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            Flexible(
              flex: 5,
              child: TabBarView(
                children: [
                  PPIDatabaseView(key: _ppiDatabaseViewState, onInteractionSelected: (ppi) => null), // TODO
                  const PPIInsightsView(),
                  const PPIDatabaseTestsView(),
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
