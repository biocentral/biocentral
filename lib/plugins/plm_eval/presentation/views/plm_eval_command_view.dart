import 'package:biocentral/plugins/plm_eval/bloc/plm_selection_dialog_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dialogs/select_plm_dialog.dart';

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
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => PLMSelectionDialogBloc(context.read<BiocentralClientRepository>()),
            child: PLMSelectionDialog(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandBar(
      commands: [
        BiocentralTooltip(
          message: "Evaluate a protein language model against benchmarks",
          child: BiocentralButton(
              label: "New evaluation..",
              requiredServices: const ["plm_eval_service"],
              iconData: Icons.fact_check_outlined,
              onTap: openSelectPLMDialog),
        )
      ],
    );
  }
}
