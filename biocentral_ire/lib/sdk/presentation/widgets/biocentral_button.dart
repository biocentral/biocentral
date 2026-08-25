import 'package:flutter/material.dart';


class BiocentralButton extends StatefulWidget {
  final void Function()? onTap;
  final IconData iconData;
  final String? label;

  const BiocentralButton({
    required this.onTap,
    required this.iconData,
    super.key,
    this.label,
  });

  @override
  State<BiocentralButton> createState() => _BiocentralButtonState();
}

class _BiocentralButtonState extends State<BiocentralButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildButton(widget.onTap);
  }

  Widget buildButton(void Function()? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 44.0,
          maxWidth: 44.0,
          minHeight: 44.0,
          maxHeight: 44.0,
        ),
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: onTap == null ? Colors.grey.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          color: onTap == null ? Colors.grey.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.9),
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.1),
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  widget.iconData,
                  size: 20.0,
                  color: onTap == null ? Colors.red : Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
