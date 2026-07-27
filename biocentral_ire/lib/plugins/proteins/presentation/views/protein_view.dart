import 'package:bio_flutter/bio_flutter.dart';
import 'package:flutter/material.dart';

class ProteinView extends StatefulWidget {
  final Protein protein;

  const ProteinView({required this.protein, super.key});

  @override
  State<ProteinView> createState() => _ProteinViewState();
}

class _ProteinViewState extends State<ProteinView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Protein protein = widget.protein;
    return Scaffold(
      body: Column(
        children: [
          Center(child: Text(protein.id)),
          Text('Sequence: ${protein.sequence.seq}', maxLines: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            child: Column(
              children: [const Text('Training properties'), Text("SET: ${protein.attributes["SET"] ?? ""}")],
            ),
          ),
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
        ],
      ),
    );
  }
}
