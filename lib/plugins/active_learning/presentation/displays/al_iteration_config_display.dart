import 'dart:math';

import 'package:biocentral_api/biocentral_api.dart';
import 'package:built_collection/src/list.dart';
import 'package:flutter/material.dart';

class AlIterationConfigDisplay extends StatefulWidget {
  final int iteration;
  final int maxNumberPossibleSuggestions;
  final List<SequenceTrainingData> iterationData;

  final void Function(ActiveLearningIterationConfig?) onChanged;

  const AlIterationConfigDisplay({
    required this.iteration,
    required this.maxNumberPossibleSuggestions,
    required this.iterationData,
    required this.onChanged,
    super.key,
  });

  @override
  State<AlIterationConfigDisplay> createState() => _AlIterationConfigDisplayState();
}

class _AlIterationConfigDisplayState extends State<AlIterationConfigDisplay> {
  int? _nSuggestions;
  double? _exploitationExplorationValue = 0.5;

  @override
  void initState() {
    super.initState();
    _nSuggestions = min(10, widget.maxNumberPossibleSuggestions);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nSuggestions = min(10, widget.maxNumberPossibleSuggestions);
  }

  ActiveLearningIterationConfig? collectConfig() {
    if (_nSuggestions != null && _nSuggestions! > 0 && _exploitationExplorationValue != null) {
      return ActiveLearningIterationConfig(
        (b) => b
          ..iteration = widget.iteration
          ..coefficient = _exploitationExplorationValue
          ..nSuggestions = _nSuggestions
          ..iterationData = ListBuilder<SequenceTrainingData>(widget.iterationData),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Iteration ${widget.iteration}'),
        buildNSuggestionsSelection(),
        buildExploitationVsExplorationSelection(),
      ],
    );
  }

  Widget buildNSuggestionsSelection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      const Text('Select number of candidates to suggest:', style: TextStyle(fontSize: 16)),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Number of suggestions',
              ),
              controller: TextEditingController(
                text: _nSuggestions?.toString() ?? '',
              ),
              onChanged: (value) {
                final parsedValue = int.tryParse(value);
                if (parsedValue != null && parsedValue >= 0 && parsedValue <= widget.maxNumberPossibleSuggestions) {
                  setState(() {
                    _nSuggestions = parsedValue;
                    widget.onChanged(collectConfig());
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_drop_up),
                onPressed: () {
                  setState(() {
                    final currentValue = _nSuggestions ?? 0;
                    if (currentValue < widget.maxNumberPossibleSuggestions) {
                      _nSuggestions = currentValue + 1;
                    }
                    widget.onChanged(collectConfig());
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_drop_down),
                onPressed: () {
                  setState(() {
                    final currentValue = _nSuggestions ?? 0;
                    if (currentValue > 0) {
                      _nSuggestions = currentValue - 1;
                    }
                    widget.onChanged(collectConfig());
                  });
                },
              ),
            ],
          ),
        ],
      ),
    ]);
  }

  Widget buildExploitationVsExplorationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Select Exploitation vs Exploration:', style: TextStyle(fontSize: 16)),
        Row(
          children: [
            const Text('Exploitation'),
            Expanded(
              child: Slider(
                value: _exploitationExplorationValue ?? 0.5,
                divisions: 10,
                label: (_exploitationExplorationValue ?? 0.5).toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _exploitationExplorationValue = value;
                    widget.onChanged(collectConfig());
                  });
                },
              ),
            ),
            const Text('Exploration'),
          ],
        ),
      ],
    );
  }
}
