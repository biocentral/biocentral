import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/plugins/prediction_models/presentation/views/model_comparison_view.dart';
import 'package:biocentral/plugins/prediction_models/presentation/views/model_list_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/animations/biocentral_blinking_animation.dart';
import 'package:flutter/material.dart';

class ModelHubView extends StatefulWidget {
  const ModelHubView({super.key});

  @override
  State<ModelHubView> createState() => _ModelHubViewState();
}

class _ModelHubViewState extends State<ModelHubView> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final List<PredictionModel> modelsToCompare = [];

  bool _animateComparisonTab = false;

  void onDragStarted() {
    setState(() {
      _animateComparisonTab = true;
    });
  }

  void onDragEnd() {
    setState(() {
      _animateComparisonTab = false;
    });
  }

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
                  const Tab(icon: Icon(Icons.list_alt), text: 'Model List'),
                  DragTarget<PredictionModel>(
                    onWillAcceptWithDetails: (dragTargetDetails) => !modelsToCompare.contains(dragTargetDetails.data),
                    onAcceptWithDetails: (dragTargetDetails) {
                      setState(() {
                        modelsToCompare.add(dragTargetDetails.data);
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return buildComparisonTab();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            Flexible(
              flex: 5,
              child: TabBarView(
                children: [
                  ModelListView(
                    onDragStarted: onDragStarted,
                    onDragEnd: onDragEnd,
                  ),
                  ModelComparisonView(
                    modelsToCompare: modelsToCompare,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildComparisonTab() {
    final modelComparisonTab = const Tab(icon: Icon(Icons.compare_arrows), text: 'Model Comparison');
    if (_animateComparisonTab) {
      return BiocentralBlinkingAnimation(
        child: modelComparisonTab,
      );
    }
    return modelComparisonTab;
  }

  @override
  bool get wantKeepAlive => true;
}
