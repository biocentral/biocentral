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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 1,
              child: TabBar(tabs: const [
                Tab(icon: Icon(Icons.list_alt), text: "Database"),
                Tab(icon: Icon(Icons.auto_graph), text: "Insights"),
                Tab(icon: Icon(Icons.check_box_rounded), text: "Data Tests")
              ],),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            Flexible(
              flex: 5,
              child: TabBarView(children: [
                PPIDatabaseView(key: _ppiDatabaseViewState, onInteractionSelected: (ppi) => null), // TODO
                PPIInsightsView(),
                PPIDatabaseTestsView()
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