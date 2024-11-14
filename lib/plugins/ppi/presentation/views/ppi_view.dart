import 'package:bio_flutter/bio_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:biocentral/plugins/ppi/domain/ppi_repository.dart';

class PPIView extends StatefulWidget {
  final ProteinProteinInteraction? proteinProteinInteraction;

  const PPIView({required this.proteinProteinInteraction, super.key});

  @override
  State<PPIView> createState() => _PPIViewState();
}

class _PPIViewState extends State<PPIView> {
  @override
  void initState() {
    super.initState();
  }

  void openProteinView(Protein protein) {
    // TODO
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Container()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PPIRepository>(
        builder: (context, interactionDatabase, child) {
          final ProteinProteinInteraction? interaction = widget.proteinProteinInteraction;
          if (interaction == null) {
            return Container();
          }
          return Column(
            children: [
              // INTERACTION ID
              Center(child: Text(interaction.getID())),
              const Spacer(),
              // PROTEINS
              const Text('Proteins:'),
              buildProteinButtons(interaction),
              // INTERACTION PROPERTIES
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: Column(
                  children: [
                    const Text('Interaction properties'),
                    Text('Interacting: ${interaction.interacting.toString()}'),
                    Text("Experimental confidence score: ${interaction.experimentalConfidenceScore ?? "NA"}"),
                  ],
                ),
              ),
              const Spacer(),
              // TRAINING ATTRIBUTES
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: Column(
                  children: [const Text('Training properties'), Text("SET: ${interaction.attributes["SET"] ?? ""}")],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildProteinButtons(ProteinProteinInteraction interaction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
            onPressed: () => openProteinView(interaction.interactor1), child: Text(interaction.interactor1.id),),
        ElevatedButton(
            onPressed: () => openProteinView(interaction.interactor2), child: Text(interaction.interactor2.id),),
      ],
    );
  }
}
