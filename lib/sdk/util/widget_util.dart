import 'dart:typed_data';

import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/util/constants.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

extension PaddedWigets on List<Widget> {
  List<Widget> withPadding(Padding padding) {
    final List<Widget> result = [];
    for (final widget in this) {
      result.add(padding);
      result.add(widget);
    }
    result.add(padding);
    return result;
  }
}

Widget textFuture({required Future<dynamic> future, String? additionalText}) {
  return FutureBuilder<dynamic>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.hasData && snapshot.data != null) {
        String? valueString = '';
        if (snapshot.data is int) {
          valueString = snapshot.data?.toStringAsFixed(0);
        } else if (snapshot.data is double) {
          valueString = snapshot.data?.toStringAsPrecision(Constants.maxDoublePrecision);
        } else {
          valueString = snapshot.data?.toString();
        }
        valueString ??= 'N/A';
        return Row(
          children: [
            if (additionalText != null) Text('$additionalText '),
            Text(valueString),
          ],
        );
      }
      return Row(children: [Text('$additionalText '), const CircularProgressIndicator()]);
    },
  );
}

Widget withCondition({required bool condition, required Widget Function() childFunction}) {
  if (condition) {
    return childFunction();
  }
  return Container();
}

Future<void> exportWidgetAsPng({required BuildContext context, required WidgetsToImageController controller, required String defaultFileName}) async {
  final Uint8List? bytes = await controller.capturePng(pixelRatio: 3.0);
  
  if (bytes == null) return;

  final String? savePath = await FilePicker.platform.saveFile(
    dialogTitle: 'Export plot as PNG',
    fileName: defaultFileName,
  );
  
  if (savePath == null) return;

  final xFile = XFile(savePath);
  final fileName = xFile.name;
  final dirPath = savePath.substring(0, savePath.length - fileName.length - 1);

  if (!context.mounted) return;
  
  final projectRepository = context.read<BiocentralProjectRepository>();
  final saveEither = await projectRepository.handleExternalSave(
    fileName: fileName,
    bytesFunction: () async => bytes,
    dirPath: dirPath,
  );

  if (!context.mounted) return;
  
  saveEither.match(
    (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export plot: ${error.message}'))),
    (path) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Plot exported to ${path ?? fileName}'))),
  );
}
