import 'dart:async';

import 'package:biocentral/plugins/ppi/bloc/ppi_command_bloc.dart';
import 'package:biocentral/plugins/ppi/presentation/views/ppi_command_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:tutorial_system/tutorial_system.dart';

import '../ppi_plugin.dart';
import '../presentation/dialogs/ppi_example_dataset_dialog.dart';

class LoadExampleInteractionDatasetTutorialContainer implements Tutorial {
  @override
  String getName() => "Load an example ppi dataset";

  @override
  void registrationFunction(TutorialRepository tutorialRepository, dynamic caller, {State? state}) {
    switch (caller) {
      case PpiPlugin ppiPlugin:
        {
          tutorialRepository.registerKey(ExamplePPITutorialID.ppiTabKey, ppiPlugin.ppiTabKey);
          tutorialRepository.registerCondition(
            ExamplePPITutorialID.ppiCommandTabActive,
            (timeout) async {
              final completer = Completer<bool>();
              final subscription = ppiPlugin.eventBus.on<BiocentralPluginTabSwitchedEvent>().listen((event) {
                bool eventConditionMet = false;
                if (event.switchedTab.key == ppiPlugin.ppiTabKey) {
                  eventConditionMet = true;
                }
                if (eventConditionMet && !completer.isCompleted) {
                  completer.complete(true);
                }
              });
              return TutorialStepWithWaiting.conditionWithSubscription(timeout, completer, subscription);
            },
          );
          break;
        }
      case PPICommandView ppiCommandView:
        {
          PPICommandBloc? interactionsCommandBloc = ppiCommandView.getPPICommandBloc(state);
          tutorialRepository.registerKey(ExamplePPITutorialID.showExamplePPIDialogButton,
              ppiCommandView.getExampleInteractionDatasetButtonKey(state));
          tutorialRepository.registerCondition(
              ExamplePPITutorialID.examplePPIDatasetImported,
              (timeout) => TutorialStepWithWaiting.conditionWithTimeout(
                  timeout, () => interactionsCommandBloc?.state.isFinished() ?? false));
          break;
        }
      case PPIExampleDatasetDialog ppiExampleDatasetDialog:
        {
          tutorialRepository.registerContext(
              ExamplePPITutorialID.examplePPIDialogContext, ppiExampleDatasetDialog.getDialogContext(state));
          tutorialRepository.registerKeys(ppiExampleDatasetDialog.getAssetDatasetKeys(state));
          tutorialRepository.registerKey(
              ExamplePPITutorialID.examplePPIDialogImportButton, ppiExampleDatasetDialog.getImportButtonKey(state));
          tutorialRepository.registerCondition(ExamplePPITutorialID.lyssavirusExamplePPIDatasetSelected,
              (timeout) async {
            condition() =>
                ppiExampleDatasetDialog.getSelectedAssetDataset(state)?.tutorialID ==
                ExamplePPITutorialID.lyssavirusExamplePPIDatasetSelector;
            return TutorialStepWithWaiting.conditionWithTimeout(timeout, condition);
          });
          break;
        }
    }
  }

  @override
  List<TutorialStep> get tutorialSteps => [
        WidgetHighlightTutorialStep(
            tutorialText: "Click here to switch to the interaction commands",
            tutorialID: ExamplePPITutorialID.ppiTabKey),
        WaitForConditionTutorialStep(tutorialID: ExamplePPITutorialID.ppiCommandTabActive),
        WidgetHighlightTutorialStep(
            tutorialText: "Click here to load the example interaction datasets",
            tutorialID: ExamplePPITutorialID.showExamplePPIDialogButton),
        WaitForContextTutorialStep(
          tutorialID: ExamplePPITutorialID.examplePPIDialogContext,
        ),
        WidgetHighlightTutorialStep(
            tutorialText: "Select the lyssavirus dataset",
            tutorialID: ExamplePPITutorialID.lyssavirusExamplePPIDatasetSelector),
        WaitForConditionTutorialStep(tutorialID: ExamplePPITutorialID.lyssavirusExamplePPIDatasetSelected),
        WidgetHighlightTutorialStep(
            tutorialText: "Import the dataset", tutorialID: ExamplePPITutorialID.examplePPIDialogImportButton),
        WaitForConditionTutorialStep(tutorialID: ExamplePPITutorialID.examplePPIDatasetImported),
        PlainTextTutorialStep(tutorialText: "You have successfully imported the dataset! Tutorial finished..")
      ];
}

enum ExamplePPITutorialID implements TutorialID {
  // Keys
  ppiTabKey,
  showExamplePPIDialogButton,
  lyssavirusExamplePPIDatasetSelector,
  examplePPIDialogImportButton,
  // Conditions
  ppiCommandTabActive,
  lyssavirusExamplePPIDatasetSelected,
  examplePPIDatasetImported,
  //Contexts
  examplePPIDialogContext
}
