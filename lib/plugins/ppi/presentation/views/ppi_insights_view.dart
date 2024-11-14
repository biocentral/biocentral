import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PPIInsightsView extends StatefulWidget {

  const PPIInsightsView({super.key});

  @override
  State<PPIInsightsView> createState() => _PPIInsightsViewState();
}

class _PPIInsightsViewState extends State<PPIInsightsView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColumnWizardBloc columnWizardDialogBloc = BlocProvider.of<ColumnWizardBloc>(context);
    return BlocBuilder<ColumnWizardBloc, ColumnWizardBlocState>(
        builder: (context, state) {
          return Column(children: [
            buildColumnSelection(columnWizardDialogBloc, state),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            Expanded(child: buildColumnWizardDisplay(state)),
          ],);
        },
    );
  }

  Widget buildColumnSelection(ColumnWizardBloc columnWizardDialogBloc, ColumnWizardBlocState state) {
    return BiocentralDropdownMenu<String>(
        dropdownMenuEntries: state.columns.keys.map((key) => DropdownMenuEntry(value: key, label: key)).toList(),
        label: const Text('Select column..'),
        onSelected: (String? value) => columnWizardDialogBloc.add(ColumnWizardSelectColumnEvent(value ?? '')),);
  }

  Widget buildColumnWizardDisplay(ColumnWizardBlocState state) {
    final ColumnWizard? columnWizard = state.columnWizards?[state.selectedColumn];

    if (columnWizard == null) {
      return Container();
    }
    return ColumnWizardStatsDisplay(columnWizard: columnWizard);
  }
}
