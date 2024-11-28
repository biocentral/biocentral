import 'package:biocentral/sdk/presentation/widgets/biocentral_entity_type_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartBOTrainingDialog extends StatefulWidget {
  const StartBOTrainingDialog({super.key});

  @override
  _StartBOTrainingDialogState createState() => _StartBOTrainingDialogState();
}

class _StartBOTrainingDialogState extends State<StartBOTrainingDialog> {
  Type? selectedDataset;
  String? selectedModel;
  List<String> models = ['Gaussian Processes', 'Random Forest']; // Example models
  double exploitationExplorationValue = 0.5; // Initial value for the slider

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start Training'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select Dataset:'),
          BiocentralEntityTypeSelection(
            onChangedCallback: (Type? value) {
              setState(() {
                selectedDataset = value;
              });
            },
            initialValue: selectedDataset,
          ),
          const SizedBox(height: 16),
          const Text('Select Model:'),
          DropdownButton<String>(
            value: selectedModel,
            hint: const Text('Choose a model'),
            items: models.map((model) {
              return DropdownMenuItem(
                value: model,
                child: Text(model),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedModel = value;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('Exploitation vs Exploration:'),
          Slider(
            value: exploitationExplorationValue,
            min: 0,
            max: 1,
            divisions: 10,
            label: exploitationExplorationValue.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                exploitationExplorationValue = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Add your start training logic here
            Navigator.of(context).pop();
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}
