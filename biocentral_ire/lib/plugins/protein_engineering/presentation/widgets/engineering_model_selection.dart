import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:flutter/material.dart';

/// Embedder used when the user doesn't pick one.
const defaultEngineeringEmbedderName = 'facebook/esm2_t33_650M_UR50D';

/// Embedders offered for campaigns, as (wire name, label). Small models first: they are
/// fast enough for a laptop or a local server without an inference backend.
const _embedderOptions = [
  ('one_hot_encoding', 'One-hot encoding'),
  ('blosum62', 'BLOSUM62'),
  ('facebook/esm2_t6_8M_UR50D', 'ESM-2 8M'),
  (defaultEngineeringEmbedderName, 'ESM-2 650M'),
  ('Rostlab/prot_t5_xl_uniref50', 'ProtT5-XL'),
];

const _modelOptions = [
  ActiveLearningModelType.GAUSSIAN_PROCESS,
  ActiveLearningModelType.FNN_MCD,
  ActiveLearningModelType.RANDOM,
];

/// Embedder and model pickers for the new-campaign wizard.
class EngineeringModelSelection extends StatelessWidget {
  final String embedderName;
  final ActiveLearningModelType modelType;
  final ValueChanged<String> onEmbedderChanged;
  final ValueChanged<ActiveLearningModelType> onModelTypeChanged;

  const EngineeringModelSelection({
    required this.embedderName,
    required this.modelType,
    required this.onEmbedderChanged,
    required this.onModelTypeChanged,
    super.key,
  });

  static String embedderLabel(String name) =>
      _embedderOptions.firstWhere((option) => option.$1 == name, orElse: () => (name, name)).$2;

  static String modelTypeLabel(ActiveLearningModelType type) => switch (type) {
    ActiveLearningModelType.GAUSSIAN_PROCESS => 'Gaussian process',
    ActiveLearningModelType.FNN_MCD => 'Neural network (MC dropout)',
    ActiveLearningModelType.RANDOM => 'Random (baseline)',
    _ => type.name,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BiocentralDiscreteSelection<String>(
          title: 'Embedder',
          initialValue: embedderName,
          selectableValues: [
            for (final (name, _) in _embedderOptions) name,
            // Keep values from imported campaigns selectable.
            if (!_embedderOptions.any((option) => option.$1 == embedderName)) embedderName,
          ],
          displayConversion: embedderLabel,
          onChangedCallback: (name) {
            if (name != null) {
              onEmbedderChanged(name);
            }
          },
        ),
        const SizedBox(height: 14),
        BiocentralDiscreteSelection<ActiveLearningModelType>(
          title: 'Model',
          initialValue: modelType,
          selectableValues: [..._modelOptions, if (!_modelOptions.contains(modelType)) modelType],
          displayConversion: modelTypeLabel,
          onChangedCallback: (type) {
            if (type != null) {
              onModelTypeChanged(type);
            }
          },
        ),
      ],
    );
  }
}
