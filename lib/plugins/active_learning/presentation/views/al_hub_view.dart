import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/presentation/views/al_iteration_result_view.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_view.dart';
import 'package:biocentral/sdk/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ALHubView extends StatefulWidget {
  final List<Widget> commandWidgets;

  const ALHubView({required this.commandWidgets, super.key});

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
                tabs: const [
                  Tab(icon: Icon(Icons.list_alt), text: 'Campaigns'),
                  Tab(icon: Icon(Icons.insert_chart), text: 'Commands'),
                ],
              ),
            ),
            BlocBuilder<ALHubBloc, ALHubState>(
              buildWhen: (previous, current) => previous.datasetChangeStatus != current.datasetChangeStatus,
              builder: (context, state) => _buildDatasetChangeBanner(state),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            Flexible(
              flex: 5,
              child: TabBarView(
                children: [
                  const ALIterationResultView(), // TODO
                  BiocentralCommandView(commandWidgets: widget.commandWidgets),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatasetChangeBanner(ALHubState state) {
    switch (state.datasetChangeStatus) {
      case ALDatasetChangeStatus.none:
        return const SizedBox.shrink();
      case ALDatasetChangeStatus.suggestionsMissing:
        return MaterialBanner(
          backgroundColor: Colors.orange.shade100,
          leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          content: const Text(
            'Some suggested proteins from the latest iteration are no longer in the loaded dataset. '
            'Consider exporting the campaign before making further changes.',
          ),
          actions: const [SizedBox.shrink()],
        );
      case ALDatasetChangeStatus.columnMissing:
        return MaterialBanner(
          backgroundColor: Colors.red.shade100,
          leading: const Icon(Icons.error_outline, color: Colors.red),
          content: Text(
            'The target column "${state.selectedCampaign?.columnName}" no longer exists in the loaded dataset. '
            'Further iterations are disabled. Export the campaign and fix your dataset before continuing!',
          ),
          actions: const [SizedBox.shrink()],
        );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
