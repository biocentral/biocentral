import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

@immutable
class BiocentralDatabaseUpdateDisplay extends StatelessWidget {
  final BiocentralDatabaseUpdate update;

  const BiocentralDatabaseUpdateDisplay({required this.update, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
          },
          children: [
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Database Length After Accept:'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${update.result.length}'),
                ),
              ],
            ),
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Current Entries Deleted After Accept:'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${update.toDelete.length}'),
                ),
              ],
            ),
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Current Entries Updated After Accept:'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${update.toUpdate.length}'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
