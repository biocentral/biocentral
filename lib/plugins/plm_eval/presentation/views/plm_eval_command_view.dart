import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_evaluation_bloc.dart';
import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_hub_bloc.dart';
import 'package:biocentral/plugins/plm_eval/bloc/plm_selection_dialog_bloc.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/plm_eval/presentation/dialogs/plm_selection_dialog.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Either;

class PLMEvalCommandView extends StatefulWidget {
  const PLMEvalCommandView({super.key});

  @override
  State<PLMEvalCommandView> createState() => _PLMEvalCommandViewState();
}

class _PLMEvalCommandViewState extends State<PLMEvalCommandView> {
  @override
  void initState() {
    super.initState();
  }

  void openSelectPLMDialog() {
    final PLMEvalEvaluationBloc plmCommandBloc = BlocProvider.of<PLMEvalEvaluationBloc>(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => PLMSelectionDialogBloc(
              context.read<BiocentralProjectRepository>(), context.read<BiocentralClientRepository>()),
          child: PLMSelectionDialog(
            onStartAutoeval: (
              Either<String, XFile> modelSelection,
              Map<String, dynamic> tokenizerConfig,
              List<BenchmarkDataset> datasets,
              bool recommendedOnly,
            ) {
              modelSelection.match(
                (modelID) =>
                    plmCommandBloc.add(PLMEvalHuggingfaceEvaluationStartEvent(modelID, datasets, recommendedOnly)),
                (onnxFile) => plmCommandBloc
                    .add(PLMEvalONNXEvaluationStartEvent(onnxFile, tokenizerConfig, datasets, recommendedOnly)),
              );
            },
          ),
        );
      },
    );
  }

  void pickResultsFilePath() async {
    final PLMEvalHubBloc hubBloc = BlocProvider.of<PLMEvalHubBloc>(context);

    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowedExtensions: ['json'], type: FileType.custom, withData: kIsWeb);

    if (result != null && result.xFiles.isNotEmpty) {
      // TODO Import Mode
      hubBloc.add(PLMEvalHubLoadPersistentResultsEvent(result.xFiles.first));
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandBar(
      commands: [
        BiocentralTooltip(
          message: 'Evaluate a protein language model against benchmarks',
          child: BiocentralButton(
            label: 'New evaluation..',
            requiredServices: const ['plm_eval_service'],
            iconData: Icons.fact_check_outlined,
            onTap: openSelectPLMDialog,
          ),
        ),
        BiocentralTooltip(
          message: 'Load existing benchmark results',
          child: BiocentralButton(
            label: 'Load existing benchmarks..',
            iconData: Icons.file_open,
            onTap: pickResultsFilePath,
          ),
        ),
      ],
    );
  }
}
