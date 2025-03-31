import 'package:biocentral/sdk/util/size_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class BiocentralDirectoryPathSelection extends StatelessWidget {
  final String defaultName;
  final void Function(String) directorySelectedCallback;

  const BiocentralDirectoryPathSelection({
    required this.defaultName,
    required this.directorySelectedCallback,
    super.key,
  });

  Future<void> pickDirectory() async {
    final String? result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Pick model directory..',
      lockParentWindow: true,
    );
    if (result != null && result.isNotEmpty) {
      directorySelectedCallback(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal(context)),
      child: Row(
        children: [
          Flexible(
            child: Text(
              defaultName,
              softWrap: true,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            onPressed: pickDirectory,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
