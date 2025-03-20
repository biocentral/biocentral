import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

class BiocentralDiscreteSelection<T> extends StatefulWidget {
  final String title;
  final List<T> selectableValues;
  final void Function(T? value) onChangedCallback;
  final String Function(T value) displayConversion;
  final T? initialValue;
  final Axis direction;

  const BiocentralDiscreteSelection({
    required this.title,
    required this.selectableValues,
    required this.onChangedCallback,
    super.key,
    this.displayConversion = _defaultDisplayConversion,
    this.initialValue,
    this.direction = Axis.horizontal,
  });

  static String _defaultDisplayConversion(dynamic value) {
    return value.toString().capitalize();
  }

  @override
  State<BiocentralDiscreteSelection<T>> createState() => _BiocentralDiscreteSelectionState<T>();
}

class _BiocentralDiscreteSelectionState<T> extends State<BiocentralDiscreteSelection<T>> {
  T? _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.initialValue;
  }

  @override
  void didUpdateWidget(BiocentralDiscreteSelection<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _selection = widget.initialValue;
    }
  }

  void onSelection(T? selected) {
    if (_selection != selected) {
      setState(() {
        _selection = selected;
      });
      widget.onChangedCallback(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectableValues.length > Constants.discreteSelectionThreshold) {
      return buildDropdown();
    }
    return widget.direction == Axis.horizontal ? buildHorizontal() : buildVertical();
  }

  Widget buildDropdown() {
    return BiocentralDropdownMenu<T>(
      dropdownMenuEntries: widget.selectableValues
          .map(
            (value) => DropdownMenuEntry(value: value, label: widget.displayConversion(value)),
          )
          .toList(),
      label: Text(widget.title),
      initialSelection: _selection,
      onSelected: onSelection,
    );
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
        selected: {_selection},
        onSelectionChanged: (selectionSet) => onSelection(selectionSet.firstOrNull),
      ),
    );
  }

  Widget buildVertical() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
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
                groupValue: _selection,
                activeColor: Theme.of(context).primaryColor,
                onChanged: onSelection,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
