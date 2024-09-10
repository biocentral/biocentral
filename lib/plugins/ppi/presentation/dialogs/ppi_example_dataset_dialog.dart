import 'package:biocentral/plugins/ppi/model/load_example_ppi_dataset_tutorial.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_system/tutorial_system.dart';

class PPIExampleDatasetDialog extends BiocentralAssetDatasetLoadingDialog {
  const PPIExampleDatasetDialog({super.key, required super.loadDatasetCallback, required super.assetDatasets});

  @override
  BiocentralAssetDatasetLoadingDialogState createState() => _PPIExampleDatasetDialogState();
}

class _PPIExampleDatasetDialogState extends BiocentralAssetDatasetLoadingDialogState with TutorialRegistrationMixin {
  @override
  void initState() {
    super.initState();
    registerForTutorials([LoadExampleInteractionDatasetTutorialContainer]);
  }
}

extension TutorialExtExampleDialog on PPIExampleDatasetDialog {
  BuildContext? getDialogContext(dynamic state) {
    return state is _PPIExampleDatasetDialogState ? state.context : null;
  }

  Map<TutorialID, GlobalKey> getAssetDatasetKeys(dynamic state) {
    Map<TutorialID, GlobalKey> result = {};
    if (state is _PPIExampleDatasetDialogState) {
      for (MapEntry<BiocentralAssetDataset, GlobalKey> entry in state.assetDatasetKeys.entries) {
        if (entry.key.tutorialID != null) {
          result[entry.key.tutorialID!] = entry.value;
        }
      }
    }
    return result;
  }

  GlobalKey? getImportButtonKey(dynamic state) {
    return state is _PPIExampleDatasetDialogState ? state.importButtonKey : null;
  }

  BiocentralAssetDataset? getSelectedAssetDataset(dynamic state) {
    return state is _PPIExampleDatasetDialogState ? state.selectedAssetDataset : null;
  }
}
