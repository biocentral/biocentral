import 'package:biocentral/plugins/proteins/model/analyze_example_dataset_tutorial.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

class AssetProteinDatasetContainer {
  static final BiocentralAssetDataset meltomeFLIP = BiocentralAssetDataset(
    name: 'FLIP Meltome - Mixed Split',
    path: 'assets/example_datasets/protein/mixed_split_meltome_flip.fasta',
    docs: 'Selected proteins with their meltdown temperatures',
  );

  static final BiocentralAssetDataset amylasePET = BiocentralAssetDataset(
      name: 'Amylase Mutations Expression Levels',
      path: 'assets/example_datasets/protein/amylase_pet.fasta',
      docs: 'Alpha Amylase (PDB: 1UA7) Single and Double Mutations with Normalized Expression Levels',
      tutorialID: AnalyzeExampleDatasetTutorialID.amylaseDatasetSelector);

  static List<BiocentralAssetDataset> assetProteinDatasets() {
    return [meltomeFLIP, amylasePET];
  }
}
