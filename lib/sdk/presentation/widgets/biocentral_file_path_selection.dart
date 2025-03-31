import 'package:biocentral/sdk/util/size_config.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BiocentralFilePathSelection extends StatelessWidget {
  final String defaultName;
  final void Function(XFile) fileSelectedCallback;
  final List<String>? allowedExtensions;

  const BiocentralFilePathSelection(
      {required this.defaultName, required this.fileSelectedCallback, this.allowedExtensions, super.key});

  Future<void> pickFile() async {
    final FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowedExtensions: allowedExtensions, type: FileType.custom, withData: kIsWeb);
    if (result != null) {
      fileSelectedCallback(result.xFiles.single);
    } else {
      // User canceled the picker
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
            onPressed: pickFile,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
