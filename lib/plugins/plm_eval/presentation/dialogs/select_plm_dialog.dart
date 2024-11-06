import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_command_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/plm_selection_dialog_bloc.dart';

class PLMSelectionDialog extends StatefulWidget {
  const PLMSelectionDialog({super.key});

  @override
  State<PLMSelectionDialog> createState() => _PLMSelectionDialogState();
}

class _PLMSelectionDialogState extends State<PLMSelectionDialog> {
  String? plmSelection;

  @override
  void initState() {
    super.initState();
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

  Widget buildCheckAndEvaluateButton(PLMSelectionDialogBloc plmSelectionDialogBloc, PLMSelectionDialogState state) {
    if (state.status == PLMSelectionDialogStatus.validated) {
      return BiocentralSmallButton(onTap: () => null, label: "Evaluate");
    }
    return BiocentralSmallButton(
        onTap: () => plmSelectionDialogBloc.add(PLMSelectionDialogSelectedEvent(plmSelection ?? "")),
        label: "Check Model");
  }

  Widget buildCancelButton() {
    return BiocentralSmallButton(onTap: closeDialog, label: "Close");
  }
}
