import 'package:biocentral/sdk/model/biocentral_config.dart';

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
      .toList();
}
