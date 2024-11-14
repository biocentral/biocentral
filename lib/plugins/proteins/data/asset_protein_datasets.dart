import 'package:biocentral/sdk/biocentral_sdk.dart';

class AssetProteinDatasetContainer {
  static final BiocentralAssetDataset meltomeFLIP = BiocentralAssetDataset(
      name: 'FLIP Meltome - Mixed Split',
      path: 'assets/example_datasets/protein/mixed_split_meltome_flip.fasta',
      docs: 'Selected proteins with their meltdown temperatures',);

  static List<BiocentralAssetDataset> assetProteinDatasets() {
    return [meltomeFLIP];
  }
}
