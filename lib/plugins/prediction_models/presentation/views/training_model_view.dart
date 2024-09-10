import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/biotrainer_training_bloc.dart';

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
    BiotrainerTrainingBloc biotrainerTrainingBloc = BlocProvider.of<BiotrainerTrainingBloc>(context);
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
                    title: Text("Training ${state.modelArchitecture ?? "unknown"} model.."),
                    trailing: SizedBox(
                        width: SizeConfig.screenWidth(context) * 0.2, child: BiocentralStatusIndicator(state: state)),
                    children: [ExpansionTile(title: const Text("Training logs"), children: buildLogResult(state))])),
          ],
        ),
      ),
    );
  }

  Widget buildSanityCheckIcon() {
    return const CircularProgressIndicator();
  }

  List<Widget> buildLogResult(BiotrainerTrainingState state) {
    // TODO Should be lacy
    return state.trainingOutput.map((e) => Text(e, maxLines: 2)).toList();
  }
}
