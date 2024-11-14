import 'package:flutter/material.dart';

@immutable
class BiocentralLogContainer extends StatelessWidget {
  final String title;
  final Widget logsWidget;

  const BiocentralLogContainer({required this.title, required this.logsWidget, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: logsWidget),
        ],
      ),
    );
  }
}
