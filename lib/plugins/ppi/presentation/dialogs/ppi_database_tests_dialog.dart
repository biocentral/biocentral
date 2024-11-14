import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/plugins/ppi/bloc/ppi_database_tests_dialog_bloc.dart';
import 'package:biocentral/plugins/ppi/model/ppi_database_test.dart';

class PPIDatabaseTestsDialog extends StatefulWidget {
  final void Function(PPIDatabaseTest) onRunInteractionDatabaseTest;

  const PPIDatabaseTestsDialog({required this.onRunInteractionDatabaseTest, super.key});

  @override
  State<PPIDatabaseTestsDialog> createState() => _PPIDatabaseTestsDialogState();
}

class _PPIDatabaseTestsDialogState extends State<PPIDatabaseTestsDialog> {
  @override
  void initState() {
    super.initState();
  }

  void doTestRunning(PPIDatabaseTestsDialogState state) async {
    if (state.selectedTest != null && state.missingRequirement == null) {
      closeDialog();
      widget.onRunInteractionDatabaseTest(state.selectedTest!);
    }
  }

  String getFileContentFromAssetDataset(ByteData dataset) {
    final buffer = dataset.buffer;
    final Uint8List bytes = buffer.asUint8List(dataset.offsetInBytes, dataset.lengthInBytes);
    return String.fromCharCodes(bytes);
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final PPIDatabaseTestsDialogBloc ppiDatabaseTestBloc = BlocProvider.of<PPIDatabaseTestsDialogBloc>(context);
    return BlocBuilder<PPIDatabaseTestsDialogBloc, PPIDatabaseTestsDialogState>(builder: (context, state) {
      return BiocentralDialog(
        children: [
          Text(
            'Run test on interaction database',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          buildTestSelection(ppiDatabaseTestBloc, state),
          buildMissingRequirementWidget(state),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BiocentralSmallButton(
                label: 'Run',
                onTap: () => doTestRunning(state),
              ),
              BiocentralSmallButton(
                label: 'Close',
                onTap: closeDialog,
              ),
            ],
          ),
        ],
      );
    },);
  }

  Widget buildTestSelection(PPIDatabaseTestsDialogBloc ppiDatabaseTestBloc, PPIDatabaseTestsDialogState state) {
    return BiocentralDropdownMenu<PPIDatabaseTest>(
      label: const Text('Select test..'),
      dropdownMenuEntries: state.availableTests
          .map((PPIDatabaseTest test) => DropdownMenuEntry<PPIDatabaseTest>(value: test, label: test.name))
          .toList(),
      onSelected: (PPIDatabaseTest? value) {
        ppiDatabaseTestBloc.add(PPIDatabaseTestsDialogSelectTestEvent(value));
      },
    );
  }

  Widget buildMissingRequirementWidget(PPIDatabaseTestsDialogState state) {
    if (state.missingRequirement == null) {
      return Container();
    }
    return Text('Your current database does not meet '
        "the following test requirement(s): ${state.missingRequirement?.name ?? ""}");
  }

  @override
  void dispose() {
    super.dispose();
  }
}
