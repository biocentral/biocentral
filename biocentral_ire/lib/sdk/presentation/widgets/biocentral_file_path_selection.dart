import 'package:biocentral/sdk/util/size_config.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BiocentralFilePathSelection extends StatelessWidget {
  final String defaultName;
  final void Function(XFile?, String?) fileSelectedCallback; // Contains file and file path
  final List<String>? allowedExtensions;
  final bool pickForExport;

  const BiocentralFilePathSelection({
    required this.defaultName,
    required this.fileSelectedCallback,
    this.allowedExtensions,
    this.pickForExport = false,
    super.key,
  });

  Future<void> pickFile() async {
    final FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowedExtensions: allowedExtensions ?? [], type: FileType.custom, withData: kIsWeb);
    if (result != null) {
      fileSelectedCallback(result.xFiles.single, result.xFiles.single.path);
    } else {
      // User canceled the picker
    }
  }

  Future<void> pickSave() async {
    final String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save file as',
      fileName: defaultName,
    );
    if (result != null) {
      fileSelectedCallback(null, result);
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Select file path..',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Padding(
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
              onPressed: pickForExport ? pickSave : pickFile,
              icon: const Icon(Icons.search),
            ),
          ],
        ),
      ),
    );
  }
}
