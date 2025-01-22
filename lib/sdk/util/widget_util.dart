import 'package:flutter/material.dart';

extension PaddedWigets on List<Widget> {

  List<Widget> withPadding(Padding padding) {
    final List<Widget> result = [];
    for(final widget in this) {
      result.add(padding);
      result.add(widget);
    }
    result.add(padding);
    return result;
  }
}