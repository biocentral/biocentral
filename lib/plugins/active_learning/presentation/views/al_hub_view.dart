import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/presentation/views/al_iteration_result_view.dart';
import 'package:biocentral/plugins/active_learning/presentation/views/al_iterations_list_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ALHubView extends StatefulWidget {
  const ALHubView({super.key});

  @override
  State<ALHubView> createState() => _ALHubViewState();
}

class _ALHubViewState extends State<ALHubView> with AutomaticKeepAliveClientMixin {
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
                  const Tab(icon: Icon(Icons.list_alt), text: 'Iterations'),
                  const Tab(icon: Icon(Icons.graphic_eq), text: 'Iteration Results'),
                ],
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            Flexible(
              flex: 5,
              child: BlocBuilder<ALHubBloc, ALHubState>(
                builder: (context, state) {
                  return const TabBarView(
                    children: [
                      ALIterationsListView(),
                      ALIterationResultView(),
                    ],
                  );
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
