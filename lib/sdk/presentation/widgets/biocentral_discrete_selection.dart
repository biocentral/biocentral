import 'package:flutter/material.dart';

import 'package:biocentral/sdk/util/type_util.dart';

class BiocentralDiscreteSelection<T> extends StatefulWidget {
  final String title;
  final List<T> selectableValues;
  final void Function(T? value) onChangedCallback;
  final String Function(T value) displayConversion;
  final T? initialValue;
  final Axis direction;

  const BiocentralDiscreteSelection(
      {required this.title, required this.selectableValues, required this.onChangedCallback, super.key,
      this.displayConversion = _defaultDisplayConversion,
      this.initialValue,
      this.direction = Axis.horizontal,});

  static String _defaultDisplayConversion(dynamic value) {
    return value.toString().capitalize();
  }

  @override
  State<BiocentralDiscreteSelection<T>> createState() => _BiocentralDiscreteSelectionState<T>();
}

class _BiocentralDiscreteSelectionState<T> extends State<BiocentralDiscreteSelection<T>> {
  late Set<T?> selection;

  @override
  void initState() {
    super.initState();
    selection = {widget.initialValue};
  }

  @override
  void didUpdateWidget(BiocentralDiscreteSelection<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      selection = {widget.initialValue};
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.direction == Axis.horizontal ? buildHorizontal() : buildVertical();
  }

  Widget buildHorizontal() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.title,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: SegmentedButton(
        segments: widget.selectableValues
            .map((value) => ButtonSegment(value: value, label: Text(widget.displayConversion(value))))
            .toList(),
        selected: selection,
        onSelectionChanged: (selected) {
          if (selection.first != selected) {
            setState(() {
              selection = selected;
            });
            widget.onChangedCallback(selected.first);
          }
        },
      ),
    );
  }

  Widget buildVertical() {
    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Flexible(
        child: Text(
          widget.title,
          softWrap: true,
          maxLines: 1,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      ...widget.selectableValues.map(
        (value) => Flexible(
          child: RadioListTile<T>(
            title: Text(widget.displayConversion(value), style: Theme.of(context).textTheme.bodyMedium),
            value: value,
            dense: true,
            groupValue: selection.first,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (T? selected) {
              if (selection != {selected}) {
                setState(() {
                  selection = {selected};
                });
                widget.onChangedCallback(selected);
              }
            },
          ),
        ),
      ),
    ],),);
  }
}
