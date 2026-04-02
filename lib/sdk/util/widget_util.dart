import 'package:biocentral/sdk/util/constants.dart';
import 'package:flutter/material.dart';

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
