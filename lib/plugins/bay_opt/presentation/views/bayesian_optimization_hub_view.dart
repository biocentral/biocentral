import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_hub_bloc.dart';
import 'package:biocentral/plugins/bay_opt/presentation/views/bayesian_optimization_database_grid_view.dart';
import 'package:biocentral/plugins/bay_opt/presentation/views/bayesian_optimization_plot_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
              child: BlocBuilder<BayesianOptimizationHubBloc, BayesianOptimizationHubState>(
                builder: (context, state) {
                  final BayesianOptimizationHubBloc bloc = context.read<BayesianOptimizationHubBloc>();
                  if (state.isOperating()) {
                    return const TabBarView(
                      children: [
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                  } else if (state.trainingResults.isEmpty) {
                    return const TabBarView(
                      children: [
                        Center(
                          child: Text('No results yet'),
                        ),
                        Center(
                          child: Text('No results yet'),
                        ),
                      ],
                    );
                  } else if (state.latestResult != null) {
                    return TabBarView(
                      children: [
                        BayesianOptimizationPlotView(
                          yLabel: 'Score',
                          data: state.latestResult,
                        ),
                        BayesianOptimizationDatabaseGridView(
                          data: state.latestResult,
                        ),
                      ],
                    );
                  } else {
                    return const TabBarView(
                      children: [
                        Center(
                          child: Text('Error occurred'),
                        ),
                        Center(
                          child: Text('Error occurred'),
                        ),
                      ],
                    );
                  }
                },
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
