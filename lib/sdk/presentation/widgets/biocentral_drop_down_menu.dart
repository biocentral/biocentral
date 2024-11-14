import 'package:flutter/material.dart';

class BiocentralDropdownMenu<T> extends StatefulWidget {
  final TextEditingController? controller;
  final List<DropdownMenuEntry<T>> dropdownMenuEntries;
  final Widget label;
  final void Function(T?)? onSelected;

  const BiocentralDropdownMenu(
      {required this.dropdownMenuEntries, required this.label, required this.onSelected, super.key, this.controller,});

  @override
  State<BiocentralDropdownMenu> createState() => _BiocentralDropdownMenuState<T>();
}

class _BiocentralDropdownMenuState<T> extends State<BiocentralDropdownMenu<T>> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      expandedInsets: EdgeInsets.zero,
      controller: widget.controller,
      leadingIcon: const Icon(Icons.search),
      label: widget.label,
      dropdownMenuEntries: widget.dropdownMenuEntries,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
      ),
      onSelected: widget.onSelected,
    );
  }
}
