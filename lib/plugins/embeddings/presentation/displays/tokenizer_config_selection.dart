import 'package:biocentral/plugins/embeddings/model/tokenizer_config.dart';
import 'package:biocentral/sdk/data/biocentral_generic_config_parser.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_config_selection.dart';
import 'package:flutter/material.dart';

class TokenizerConfigSelection extends StatefulWidget {
  final void Function(Map<String, dynamic>? tokenizerConfig) onConfigUpdate;

  const TokenizerConfigSelection({required this.onConfigUpdate, super.key});

  @override
  State<TokenizerConfigSelection> createState() => _TokenizerConfigSelectionState();
}

class _TokenizerConfigSelectionState extends State<TokenizerConfigSelection> {
  final TokenizerConfig _tokenizerConfig = TokenizerConfig.defaultConfig();

  @override
  Widget build(BuildContext context) {
    return BiocentralConfigSelection(
      optionMap: {'Tokenizer': _tokenizerConfig.allOptions},
      configHandler: BiocentralGenericConfigHandler(JSONConfigHandlingStrategy()),
      clusterByCategories: true,
      onConfigChangedCallback: (_, config) =>
          widget.onConfigUpdate(config['Tokenizer']?.map((k, v) => MapEntry(k.name, v))),
    );
  }
}
