import 'package:biocentral/plugins/bayesian-optimization/presentation/views/bayesian_optimization_database_grid_view.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/views/bayesian_optimization_plot_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biocentral/plugins/bayesian-optimization/bloc/bayesian_optimization_bloc.dart';

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
              child: BlocBuilder<BayesianOptimizationBloc, BayesianOptimizationState>(
                builder: (context, state) {
                  final BayesianOptimizationBloc bloc = context.read<BayesianOptimizationBloc>();
                  if (state.status == BiocentralCommandStatus.operating) {
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
                  } else if (bloc.currentResult == null && bloc.previousResults == null) {
                    return const TabBarView(
                      children: [
                        Center(
                          child: Text('No training started'),
                        ),
                        Center(
                          child: Text('No training started'),
                        ),
                      ],
                    );
                  } else if (bloc.currentResult != null) {
                    return TabBarView(
                      children: [
                        BayesianOptimizationPlotView(
                          yLabel: 'Utility',
                          xLabel: 'fc 28-d - Target (MPa)',
                          data: bloc.currentResult,
                        ),
                        BayesianOptimizationDatabaseGridView(
                          yLabel: 'Utility',
                          xLabel: 'fc 28-d - Target (MPa)',
                          data: bloc.currentResult,
                        ),
                      ],
                    );
                  } else if (bloc.previousResults != null) {
                    return TabBarView(
                      children: [
                        BayesianOptimizationPlotView(
                          yLabel: 'Utility',
                          xLabel: 'fc 28-d - Target (MPa)',
                          data: bloc.previousResults?.last,
                        ),
                        BayesianOptimizationDatabaseGridView(
                          yLabel: 'Utility',
                          xLabel: 'fc 28-d - Target (MPa)',
                          data: bloc.previousResults?.last,
                        ),
                      ],
                    );
                  } else if (bloc.previousResults?.isEmpty ?? true) {
                    return const TabBarView(
                      children: [
                        Center(
                          child: Text('No previous trainings'),
                        ),
                        Center(
                          child: Text('No previous trainings'),
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
