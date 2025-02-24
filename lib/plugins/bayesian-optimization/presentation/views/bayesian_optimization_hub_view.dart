import 'package:biocentral/plugins/bayesian-optimization/presentation/views/bayesian_optimization_database_grid_view.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/views/bayesian_optimization_plot_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

class BayesianOptimizationHubView extends StatefulWidget {
  const BayesianOptimizationHubView({super.key});

  @override
  State<BayesianOptimizationHubView> createState() => _BayesianOptimizationHubViewState();
}

class _BayesianOptimizationHubViewState extends State<BayesianOptimizationHubView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: TabBar(
                labelColor: Theme.of(context).colorScheme.onSurface,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                tabs: [
                  const Tab(icon: Icon(Icons.graphic_eq), text: 'Plot'),
                  const Tab(icon: Icon(Icons.list_alt), text: 'Database'),
                ],
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            Flexible(
              flex: 5,
              child: TabBarView(
                children: [
                  BayesianOptimizationPlotView(
                    yLabel: 'Utility',
                    xLabel: 'fc 28-d - Target (MPa)',
                  ),
                  BayesianOptimizationDatabaseGridView(
                    yLabel: 'Utility',
                    xLabel: 'fc 28-d - Target (MPa)',
                  ),
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
