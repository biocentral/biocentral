import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/plugins/prediction_models/presentation/displays/prediction_model_display.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

class PLMEvalPipelineView extends StatefulWidget {
  final String modelName;
  final AutoEvalProgress progress;
  final Map<String, List<String>> _datasetNamesToSplits;

  PLMEvalPipelineView({
    required this.modelName,
    required this.progress,
    super.key,
  }) : _datasetNamesToSplits = BenchmarkDataset.benchmarkDatasetsByDatasetName(progress.results.keys.toList());

  @override
  State<PLMEvalPipelineView> createState() => _PLMEvalPipelineViewState();
}

class _PLMEvalPipelineViewState extends State<PLMEvalPipelineView> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildModelCard(),
          const SizedBox(width: 20),
          _buildArrow('Evaluation Progress: ${widget.progress.completedTasks}/${widget.progress.totalTasks}'),
          const SizedBox(width: 20),
          _buildDatasets(),
        ],
      ),
    );
  }

  Widget _buildModelCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: SizeConfig.screenWidth(context) * 0.2,
          height: SizeConfig.screenHeight(context) * 0.2,
          child: Center(
            child: Text(
              widget.modelName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrow(String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.arrow_forward, size: 30),
        Text(label),
      ],
    );
  }

  Widget _buildDatasets() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            widget._datasetNamesToSplits.entries.map((entry) => _buildDatasetGroup(entry.key, entry.value)).toList(),
      ),
    );
  }

  Widget _buildDatasetGroup(String datasetName, List<String> splits) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(datasetName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...splits.map((split) => _buildSplitCard(datasetName, split)),
        ],
      ),
    );
  }

  Widget _buildSplitCard(String datasetName, String splitName) {
    final BenchmarkDataset current = BenchmarkDataset(datasetName: datasetName, splitName: splitName);
    final PredictionModel? model = widget.progress.results[current];
    if (model != null) {
      // TODO [Refactoring] Usage of the trainingState should be reflected and probably refactored
      return PredictionModelDisplay(predictionModel: model, trainingState: widget.progress.currentModelTrainingState);
    }
    final bool isCurrentProcess = widget.progress.currentProcess == current;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: SizeConfig.screenWidth(context) * 0.3,
          height: SizeConfig.screenHeight(context) * 0.1,
          child: Center(
            child: Text(
              splitName,
              style: TextStyle(fontSize: 14, color: isCurrentProcess ? Colors.purple : Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
