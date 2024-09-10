import 'package:flutter/material.dart';

class BiocentralCommandBar extends StatelessWidget {
  final List<Widget> commands;

  const BiocentralCommandBar({super.key, required this.commands});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Theme.of(context).primaryColor.withAlpha(175),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: commands,
          ),
        )
      ],
    );
  }
}
