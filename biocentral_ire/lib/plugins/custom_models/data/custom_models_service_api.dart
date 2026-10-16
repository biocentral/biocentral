import 'package:biocentral/sdk/model/biocentral_config.dart';
import 'package:biocentral/sdk/util/seed_util.dart';

List<BiocentralConfigOption> filterBiotrainerOptionsForBiocentral(List<BiocentralConfigOption> options) {
  const Set<String> ignoreCategories = {'input_files'};
  const Set<String> ignoreNames = {
    'device',
    'embeddings_file',
    'ignore_file_inconsistencies',
    'pretrained_model',
    'auto_resume',
    'custom_tokenizer_config',
    'output_dir',
    'embedder_name', // Handled separately
  };
  return options
      .where((option) => !ignoreCategories.contains(option.category) && !ignoreNames.contains(option.name))
      .map(_withBiocentralDefault)
      .toList();
}

/// Replaces biotrainer's default seed with today's, see [dateSeed].
BiocentralConfigOption _withBiocentralDefault(BiocentralConfigOption option) {
  if (option.name != 'seed') {
    return option;
  }
  return BiocentralConfigOption(
    name: option.name,
    required: option.required,
    defaultValue: dateSeed(),
    category: option.category,
    description: option.description,
    constraints: option.constraints,
  );
}
