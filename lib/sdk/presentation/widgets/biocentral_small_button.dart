import 'package:flutter/material.dart';

import '../../util/size_config.dart';

class BiocentralSmallButton extends StatefulWidget {
  final void Function()? onTap;
  final String label;

  const BiocentralSmallButton({super.key, required this.onTap, required this.label});

  @override
  State<BiocentralSmallButton> createState() => _BiocentralSmallButtonState();
}

class _BiocentralSmallButtonState extends State<BiocentralSmallButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.safeBlockHorizontal(context) * 6,
      width: SizeConfig.safeBlockHorizontal(context) * 12,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor, textStyle: Theme.of(context).textTheme.labelMedium),
          onPressed: widget.onTap,
          child: Text(widget.label, style: const TextStyle(color: Colors.white))),
    );
  }
}
