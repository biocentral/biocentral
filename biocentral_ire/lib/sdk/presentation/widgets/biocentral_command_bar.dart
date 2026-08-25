import 'package:flutter/material.dart';

class BiocentralCommandBar extends StatelessWidget {
  final List<Widget> commands;

  const BiocentralCommandBar({required this.commands, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Theme.of(context).primaryColor.withAlpha(175),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: commands,
          ),
        ),
      ],
    );
  }
}
