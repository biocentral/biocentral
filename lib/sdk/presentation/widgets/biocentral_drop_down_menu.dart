import 'package:flutter/material.dart';

class BiocentralDropdownMenu<T> extends StatefulWidget {
  final TextEditingController? controller;
  final List<DropdownMenuEntry<T>> dropdownMenuEntries;
  final Widget label;

  final T? initialSelection;
  final void Function(T?)? onSelected;

  const BiocentralDropdownMenu({
    required this.dropdownMenuEntries,
    required this.label,
    required this.onSelected,
    this.initialSelection,
    this.controller,
    super.key,
  });

  @override
  State<BiocentralDropdownMenu> createState() => _BiocentralDropdownMenuState<T>();
}

class _BiocentralDropdownMenuState<T> extends State<BiocentralDropdownMenu<T>> {
  TextEditingController? _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = widget.controller ?? TextEditingController();
    if(widget.initialSelection != null) {
      _textEditingController?.text = widget.initialSelection.toString();
      if(widget.onSelected != null) {
        widget.onSelected!(widget.initialSelection);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      expandedInsets: EdgeInsets.zero,
      controller: _textEditingController,
      leadingIcon: const Icon(Icons.search),
      label: widget.label,
      initialSelection: widget.initialSelection,
      dropdownMenuEntries: widget.dropdownMenuEntries,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
      ),
      onSelected: widget.onSelected,
    );
  }
}
