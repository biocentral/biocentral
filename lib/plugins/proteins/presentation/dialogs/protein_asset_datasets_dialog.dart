import 'package:biocentral/plugins/proteins/model/analyze_example_dataset_tutorial.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_system/tutorial_system.dart';

class ProteinAssetDatasetsDialog extends BiocentralAssetDatasetLoadingDialog {
  const ProteinAssetDatasetsDialog({required super.loadDatasetCallback, required super.assetDatasets, super.key});

  @override
  BiocentralAssetDatasetLoadingDialogState createState() => _ProteinAssetDatasetsDialogState();
}

class _ProteinAssetDatasetsDialogState extends BiocentralAssetDatasetLoadingDialogState with TutorialRegistrationMixin {
  @override
  void initState() {
    super.initState();
    registerForTutorials([AnalyzeExampleDatasetTutorial]);
  }
}

extension TutorialExtExampleDialog on ProteinAssetDatasetsDialog {
  BuildContext? getDialogContext(dynamic state) {
    return state is _ProteinAssetDatasetsDialogState ? state.context : null;
  }

  Map<TutorialID, GlobalKey> getAssetDatasetKeys(dynamic state) {
    final Map<TutorialID, GlobalKey> result = {};
    if (state is _ProteinAssetDatasetsDialogState) {
      for (MapEntry<BiocentralAssetDataset, GlobalKey> entry in state.assetDatasetKeys.entries) {
        if (entry.key.tutorialID != null) {
          result[entry.key.tutorialID!] = entry.value;
        }
      }
    }
    return result;
  }

  GlobalKey? getImportButtonKey(dynamic state) {
    return state is _ProteinAssetDatasetsDialogState ? state.importButtonKey : null;
  }

  BiocentralAssetDataset? getSelectedAssetDataset(dynamic state) {
    return state is _ProteinAssetDatasetsDialogState ? state.selectedAssetDataset : null;
  }
}
