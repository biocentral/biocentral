import 'dart:async';

import 'package:biocentral/plugins/proteins/presentation/dialogs/protein_column_wizard_dialog.dart';
import 'package:biocentral/plugins/proteins/presentation/views/proteins_command_view.dart';
import 'package:biocentral/plugins/proteins/protein_plugin.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_bloc.dart';
import 'package:biocentral/sdk/bloc/biocentral_events.dart';
import 'package:biocentral/sdk/bloc/column_wizard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_system/tutorial_system.dart';

class AnalyzeExampleDatasetTutorial implements Tutorial {
  @override
  String getName() => 'Analyze an example protein dataset';

  @override
  void registrationFunction(TutorialRepository tutorialRepository, dynamic caller, {State? state}) {
    switch (caller) {
      case final ProteinPlugin proteinPlugin:
        {
          tutorialRepository.registerKey(AnalyzeExampleDatasetTutorialID.proteinsTabKey, proteinPlugin.proteinTabKey);
          tutorialRepository.registerCondition(
            AnalyzeExampleDatasetTutorialID.proteinsTabKeyActive,
            (timeout) async {
              final completer = Completer<bool>();
              final subscription = proteinPlugin.eventBus.on<BiocentralPluginTabSwitchedEvent>().listen((event) {
                bool eventConditionMet = false;
                if (event.switchedTab.key == proteinPlugin.proteinTabKey) {
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
      // TODO
      //case final ProteinsCommandView proteinsCommandView:
      //  {
      //    final BiocentralCommandBloc? commandBloc = proteinsCommandView.getCommandBloc(state);
      //    tutorialRepository.registerKey(
      //      AnalyzeExampleDatasetTutorialID.showProteinAssetDatasetsButton,
      //      proteinsCommandView.getLoadProteinsExampleDatasetsButtonKey(state),
      //    );
      //    tutorialRepository.registerCondition(
      //      AnalyzeExampleDatasetTutorialID.amylaseDatasetImported,
      //      (timeout) => TutorialStepWithWaiting.conditionWithTimeout(
      //        timeout,
      //        () => commandBloc?.state.isFinished() ?? false,
      //      ),
      //    );
      //    tutorialRepository.registerKey(
      //      AnalyzeExampleDatasetTutorialID.showProteinsColumnWizardButton,
      //      proteinsCommandView.getShowProteinsColumnWizardButtonKey(state),
      //    );
      //    break;
      //  }
      //case final ProteinAssetDatasetsDialog proteinAssetDatasetDialog:
      //  {
      //    tutorialRepository.registerContext(
      //      AnalyzeExampleDatasetTutorialID.proteinAssetDatasetsDialogContext,
      //      proteinAssetDatasetDialog.getDialogContext(state),
      //    );
      //    tutorialRepository.registerKeys(proteinAssetDatasetDialog.getAssetDatasetKeys(state));
      //    tutorialRepository.registerKey(
      //      AnalyzeExampleDatasetTutorialID.proteinAssetDatasetsDialogImportButton,
      //      proteinAssetDatasetDialog.getImportButtonKey(state),
      //    );
      //    tutorialRepository.registerCondition(AnalyzeExampleDatasetTutorialID.amylaseDatasetSelected, (timeout) async {
      //      bool condition() =>
      //          proteinAssetDatasetDialog.getSelectedAssetDataset(state)?.tutorialID ==
      //          AnalyzeExampleDatasetTutorialID.amylaseDatasetSelector;
      //      return TutorialStepWithWaiting.conditionWithTimeout(timeout, condition);
      //    });
      //    break;
      //  }
      case final ProteinColumnWizardDialog proteinColumnWizardDialog:
        {
          final ColumnWizardBloc? columnWizardBloc = proteinColumnWizardDialog.getColumnWizardBloc(state);
          tutorialRepository.registerContext(
            AnalyzeExampleDatasetTutorialID.proteinColumnWizardDialogContext,
            proteinColumnWizardDialog.getDialogContext(state),
          );
          tutorialRepository.registerKey(
            AnalyzeExampleDatasetTutorialID.columnWizardColumnSelection,
            proteinColumnWizardDialog.getColumnSelectionKey(state),
          );
          tutorialRepository.registerCondition(AnalyzeExampleDatasetTutorialID.targetColumnSelected, (timeout) async {
            bool condition() => columnWizardBloc?.state.selectedColumn == 'TARGET';
            return TutorialStepWithWaiting.conditionWithTimeout(timeout, condition);
          });
          tutorialRepository.registerKey(
            AnalyzeExampleDatasetTutorialID.columnWizardOperationSelection,
            proteinColumnWizardDialog.getOperationSelectionKey(state),
          );
          tutorialRepository.registerCondition(AnalyzeExampleDatasetTutorialID.removeOutliersOperationSelected,
              (timeout) async {
            bool condition() =>
                proteinColumnWizardDialog.getCalculateButtonKey(state)?.currentContext?.mounted ?? false;
            return TutorialStepWithWaiting.conditionWithTimeout(timeout, condition);
          });
          tutorialRepository.registerKey(
            AnalyzeExampleDatasetTutorialID.columnWizardCalculateButton,
            proteinColumnWizardDialog.getCalculateButtonKey(state),
          );
          tutorialRepository.registerCondition(AnalyzeExampleDatasetTutorialID.removeOutliersOperationPerformed,
                  (timeout) async {
                bool condition() {
                  final historyLength = columnWizardBloc?.state.columnWizardHistory?['TARGET']?.length ?? 0;
                  return historyLength > 1;
                };
                return TutorialStepWithWaiting.conditionWithTimeout(timeout, condition);
              });
        }
    }
  }

  @override
  List<TutorialStep> get tutorialSteps => [
        WidgetHighlightTutorialStep(
          tutorialText: 'Click here to switch to the protein module',
          tutorialID: AnalyzeExampleDatasetTutorialID.proteinsTabKey,
        ),
        WaitForConditionTutorialStep(
          tutorialID: AnalyzeExampleDatasetTutorialID.proteinsTabKeyActive,
        ),
        WidgetHighlightTutorialStep(
          tutorialText: 'Click here to load an example protein dataset',
          tutorialID: AnalyzeExampleDatasetTutorialID.showProteinAssetDatasetsButton,
        ),
        WaitForContextTutorialStep(
          tutorialID: AnalyzeExampleDatasetTutorialID.proteinAssetDatasetsDialogContext,
        ),
        WidgetHighlightTutorialStep(
          tutorialText: 'Select the amylase dataset',
          tutorialID: AnalyzeExampleDatasetTutorialID.amylaseDatasetSelector,
        ),
        WaitForConditionTutorialStep(
          tutorialID: AnalyzeExampleDatasetTutorialID.amylaseDatasetSelected,
        ),
        WidgetHighlightTutorialStep(
          tutorialText: 'Import the amylase dataset',
          tutorialID: AnalyzeExampleDatasetTutorialID.proteinAssetDatasetsDialogImportButton,
        ),
        WaitForConditionTutorialStep(
          tutorialID: AnalyzeExampleDatasetTutorialID.amylaseDatasetImported,
        ),
        WidgetHighlightTutorialStep(
          tutorialText: 'Click here to analyze the columns of the dataset',
          tutorialID: AnalyzeExampleDatasetTutorialID.showProteinsColumnWizardButton,
        ),
        WaitForContextTutorialStep(
          tutorialID: AnalyzeExampleDatasetTutorialID.proteinColumnWizardDialogContext,
        ),
        WidgetHighlightTutorialStep(
          tutorialText: 'Select the `TARGET` column of the dataset',
          tutorialID: AnalyzeExampleDatasetTutorialID.columnWizardColumnSelection,
        ),
        WaitForConditionTutorialStep(
          tutorialID: AnalyzeExampleDatasetTutorialID.targetColumnSelected,
        ),
        PlainTextTutorialStep(
          tutorialText: 'The dataset has quite some high-value outliers, let\'s remove them..',
        ),
        WidgetHighlightTutorialStep(
          tutorialText: 'Select the `removeOutliers` operation and perform the default `byStandardDeviation` method',
          tutorialID: AnalyzeExampleDatasetTutorialID.columnWizardOperationSelection,
        ),
        WaitForConditionTutorialStep(
          tutorialID: AnalyzeExampleDatasetTutorialID.removeOutliersOperationSelected,
        ),
        WidgetHighlightTutorialStep(
          tutorialText: 'Perform the operation by pressing the `Calculate` button',
          tutorialID: AnalyzeExampleDatasetTutorialID.columnWizardCalculateButton,
        ),
        WaitForConditionTutorialStep(
          tutorialID: AnalyzeExampleDatasetTutorialID.removeOutliersOperationPerformed,
        ),
        PlainTextTutorialStep(
          tutorialText: 'You have successfully imported and analyzed the dataset! Tutorial finished.',
        ),
      ];
}

/// Utility class to start the interactive tutorial directly from the welcome screen
/// Could be refactored by adding a skip condition to the highlight tutorial steps
class AnalyzeExampleDatasetTutorialFromWelcomeScreen extends AnalyzeExampleDatasetTutorial {
  @override
  List<TutorialStep> get tutorialSteps => super.tutorialSteps.sublist(2);
}

enum AnalyzeExampleDatasetTutorialID implements TutorialID {
  // Keys
  proteinsTabKey,
  showProteinAssetDatasetsButton,
  amylaseDatasetSelector,
  proteinAssetDatasetsDialogImportButton,
  showProteinsColumnWizardButton,
  columnWizardColumnSelection,
  columnWizardOperationSelection,
  columnWizardCalculateButton,
  // Conditions
  proteinsTabKeyActive,
  amylaseDatasetSelected,
  amylaseDatasetImported,
  targetColumnSelected,
  removeOutliersOperationSelected,
  removeOutliersOperationPerformed,
  //Contexts
  proteinAssetDatasetsDialogContext,
  proteinColumnWizardDialogContext
}
