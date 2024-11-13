import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_command_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/plm_selection_dialog_bloc.dart';

class PLMSelectionDialog extends StatefulWidget {
  final void Function(String) onStartAutoeval;

  const PLMSelectionDialog({super.key, required this.onStartAutoeval});

  @override
  State<PLMSelectionDialog> createState() => _PLMSelectionDialogState();
}

class _PLMSelectionDialogState extends State<PLMSelectionDialog> {
  String? plmSelection;

  @override
  void initState() {
    super.initState();
  }

  void startAutoeval(PLMSelectionDialogState state) {
    if(state.plmHuggingface != null) {
      closeDialog();
      widget.onStartAutoeval(state.plmHuggingface!);
    }
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PLMSelectionDialogBloc, PLMSelectionDialogState>(
      builder: (context, state) => buildDialog(state),
    );
  }

  Widget buildDialog(PLMSelectionDialogState state) {
    PLMSelectionDialogBloc plmSelectionDialogBloc = BlocProvider.of<PLMSelectionDialogBloc>(context);
    List<Widget> dialogChildren = [];

    // Helper Text for errors
    String helperText = state.errorMessage ?? "";
    Color helperStyleColor = Colors.red;

    if(state.status == PLMSelectionDialogStatus.validated) {
      helperText = "Successfully validated, you are good to go!";
      helperStyleColor = Colors.green;
    }

    dialogChildren.addAll([
      Text(
        "Create an evaluation for your protein language model",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      TextFormField(
          initialValue: "",
          decoration: InputDecoration(
              labelText: "Enter a valid huggingface model ID here",
              hintText: "e.g. Rostlab/prot_t5_xl_uniref50",
              helperText: helperText,
              helperStyle: Theme.of(context).textTheme.labelSmall?.copyWith(color: helperStyleColor)),
          onChanged: (String? value) {
            setState(() {
              plmSelection = value ?? "";
            });
          }),
      buildDatasetSplitsDisplay(state.availableDatasets),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [buildCheckAndEvaluateButton(plmSelectionDialogBloc, state), buildCancelButton()],
      )
    ]);

    return BiocentralDialog(
      small: false, // TODO Small Dialog not working yet
      children: dialogChildren,
    );
  }


  Widget buildDatasetSplitsDisplay(Map<String, List<String>> availableDatasets) {
    if (availableDatasets.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        Text("Benchmark Datasets (FLIP):"),
        SizedBox(height: 8,),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: availableDatasets.entries.map((entry) {
              String datasetName = entry.key;
              List<String> splits = entry.value;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      datasetName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_forward, size: 20),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: splits.map((split) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(split),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildCheckAndEvaluateButton(PLMSelectionDialogBloc plmSelectionDialogBloc, PLMSelectionDialogState state) {
    if (state.status == PLMSelectionDialogStatus.validated && state.availableDatasets.isNotEmpty) {
      return BiocentralSmallButton(onTap: () => startAutoeval(state), label: "Start Evaluation");
    }
    return BiocentralSmallButton(
        onTap: () => plmSelectionDialogBloc.add(PLMSelectionDialogSelectedEvent(plmSelection ?? "")),
        label: "Check Model");
  }

  Widget buildCancelButton() {
    return BiocentralSmallButton(onTap: closeDialog, label: "Close");
  }

}
