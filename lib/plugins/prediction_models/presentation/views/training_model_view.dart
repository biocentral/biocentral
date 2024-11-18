import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/plots/biocentral_line_plot.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_lazy_logs_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/plugins/prediction_models/bloc/biotrainer_training_bloc.dart';
/*
class TrainingModelView extends StatefulWidget {
  const TrainingModelView({super.key});

  @override
  State<TrainingModelView> createState() => _TrainingModelViewState();
}

class _TrainingModelViewState extends State<TrainingModelView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final BiotrainerTrainingBloc biotrainerTrainingBloc = BlocProvider.of<BiotrainerTrainingBloc>(context);
    return BlocBuilder<BiotrainerTrainingBloc, BiotrainerTrainingState>(
      builder: (context, state) {
        return buildModel(biotrainerTrainingBloc, state);
      },
    );
  }

  Widget buildModel(BiotrainerTrainingBloc biotrainerTrainingBloc, BiotrainerTrainingState state) {
    return SizedBox(
      width: SizeConfig.screenWidth(context) * 0.95,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
                child: ExpansionTile(
                    leading: buildSanityCheckIcon(),
                    title: Text("Training ${state.trainingModel?.architecture ?? "unknown"} Model.."),
                    trailing: SizedBox(
                        width: SizeConfig.screenWidth(context) * 0.2, child: BiocentralStatusIndicator(state: state),),
                    children: [
                  ExpansionTile(title: const Text('Loss Curves'), children: buildLossCurves(state)),
                  ExpansionTile(title: const Text('Training Logs'), children: buildLogResult(state)),
                ],),),
          ],
        ),
      ),
    );
  }

  Widget buildSanityCheckIcon() {
    return const CircularProgressIndicator();
  }

  List<Widget> buildLossCurves(BiotrainerTrainingState state) {
    if (state.trainingModel.biotrainerTrainingResult?.trainingLoss.isEmpty && state.trainingModel.biotrainerTrainingResult?.validationLoss.isEmpty) {
      return [Container()];
    }
    final Map<String, Map<int, double>> linePlotData = {
      'Training': state.trainingLoss,
      'Validation': state.validationLoss,
    };
    return [
      SizedBox(
        height: SizeConfig.safeBlockVertical(context) * 2,
      ),
      SizedBox(
          height: SizeConfig.screenHeight(context) * 0.3,
          width: SizeConfig.screenWidth(context) * 0.6,
          child: BiocentralLinePlot(data: linePlotData),),
      SizedBox(
        height: SizeConfig.safeBlockVertical(context) * 2,
      ),
    ];
  }

  List<Widget> buildLogResult(BiotrainerTrainingState state) {
    if (state.trainingModel.biotrainerTrainingLog.isEmpty) {
      return [
        Container(),
      ];
    }
    return [
      BiocentralLazyLogsViewer(logs: state.trainingModel.biotrainerTrainingLog, height: SizeConfig.screenHeight(context) * 0.4),
    ];
  }
}
*/