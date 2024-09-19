import 'package:biocentral/sdk/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/biocentral_database.dart';
import '../../domain/biocentral_project_repository.dart';
import '../../model/biocentral_asset_dataset.dart';
import '../widgets/biocentral_small_button.dart';
import '../widgets/biocentral_tooltip.dart';
import 'biocentral_dialog.dart';

class BiocentralAssetDatasetLoadingDialog extends StatefulWidget {
  final void Function(FileData fileData, DatabaseImportMode importMode) loadDatasetCallback;
  final List<BiocentralAssetDataset> assetDatasets;

  const BiocentralAssetDatasetLoadingDialog(
      {super.key, required this.loadDatasetCallback, required this.assetDatasets});

  @override
  State<BiocentralAssetDatasetLoadingDialog> createState() => BiocentralAssetDatasetLoadingDialogState();
}

class BiocentralAssetDatasetLoadingDialogState extends State<BiocentralAssetDatasetLoadingDialog> {
  final Map<BiocentralAssetDataset, GlobalKey> assetDatasetKeys = {};
  final GlobalKey importButtonKey = GlobalKey();

  BiocentralAssetDataset? selectedAssetDataset;

  @override
  void initState() {
    super.initState();
    assetDatasetKeys.addEntries(widget.assetDatasets.map((assetDataset) => MapEntry(assetDataset, GlobalKey())));
  }

  void doLoading() async {
    if (selectedAssetDataset != null) {
      ByteData dataset = await rootBundle.load(selectedAssetDataset!.path);

      String fileContent = getFileContentFromAssetDataset(dataset);

      closeDialog();

      widget.loadDatasetCallback(FileData(content: fileContent, name: "", extension: ""), DatabaseImportMode.overwrite);
    }
  }

  String getFileContentFromAssetDataset(ByteData dataset) {
    final buffer = dataset.buffer;
    Uint8List bytes = buffer.asUint8List(dataset.offsetInBytes, dataset.lengthInBytes);
    return String.fromCharCodes(bytes);
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralDialog(
      small: false, // TODO Small Dialog not working yet
      children: [
        Text(
          "Load an example dataset",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Padding(padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal(context) * 2), child: buildExampleDatasetDocs()),
        buildDatasetSelection(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BiocentralTooltip(
              message: "Imports the example dataset and overwrite all existing entries in the database",
              child: BiocentralSmallButton(
                key: importButtonKey,
                label: "Import",
                onTap: doLoading,
              ),
            ),
            BiocentralSmallButton(
              label: "Close",
              onTap: closeDialog,
            ),
          ],
        )
      ],
    );
  }

  Widget buildDocStringBox(String docString) {
    return SizedBox(
        height: SizeConfig.screenHeight(context) * 0.15,
        width: SizeConfig.screenWidth(context) * 0.8,
        child: SingleChildScrollView(
            child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.grey,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(docString),
                ))));
  }

  Widget buildExampleDatasetDocs() {
    String docString = "";
    if (selectedAssetDataset != null) {
      docString = "\n${selectedAssetDataset!.name}:\n\n${selectedAssetDataset!.docs}\n";
    }
    return buildDocStringBox(docString);
  }

  Widget buildDatasetSelection() {
    List<Widget> exampleDatasetRadioTiles = [];
    for (BiocentralAssetDataset assetDataset in widget.assetDatasets) {
      Widget exampleDatasetRadioTile = RadioListTile<BiocentralAssetDataset>(
          key: assetDatasetKeys[assetDataset],
          title: Text(assetDataset.name, style: Theme.of(context).textTheme.bodyMedium),
          value: assetDataset,
          groupValue: selectedAssetDataset,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (BiocentralAssetDataset? value) {
            setState(() {
              selectedAssetDataset = value;
            });
          });
      exampleDatasetRadioTiles.add(exampleDatasetRadioTile);
    }
    return Padding(
      padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal(context)),
      child: Column(children: exampleDatasetRadioTiles),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
