import 'package:biocentral/plugins/ppi/model/load_example_ppi_dataset_tutorial.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

class PPIAssetDatasetContainer {
  static final BiocentralAssetDataset lyssaVirus = BiocentralAssetDataset(
      name: "Experimental Human-Lyssavirus Interactions",
      path: "assets/example_datasets/interaction/lyssa_experimental_interactions_biocentral.fasta",
      docs:
          "Rabies Lyssavirus interactions that have been "
              "extracted from Zandi et al. 2021 (https://doi.org/10.52547%2Fibj.25.4.226).",
      tutorialID: ExamplePPITutorialID.lyssavirusExamplePPIDatasetSelector);

  static List<BiocentralAssetDataset> assetInteractionDatasets() {
    return [lyssaVirus];
  }
}
