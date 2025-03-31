import 'package:biocentral/sdk/model/biocentral_config_option.dart';

class TokenizerConfig {
  final BiocentralConfigOption eosToken;
  final BiocentralConfigOption padToken;
  final BiocentralConfigOption unkToken;

  final BiocentralConfigOption vocab;

  final BiocentralConfigOption charactersToReplace;
  final BiocentralConfigOption replacementCharacter;

  final BiocentralConfigOption usesWhitespaces;

  TokenizerConfig._internal(
      {required this.eosToken,
      required this.padToken,
      required this.unkToken,
      required this.vocab,
      required this.charactersToReplace,
      required this.replacementCharacter,
      required this.usesWhitespaces});

  factory TokenizerConfig.defaultConfig() {
    final defaultStringConstraints = BiocentralConfigConstraints(typeConstraint: String);
    final defaultMapConstraints = BiocentralConfigConstraints(typeConstraint: Map, mapTypeConstraint: int);
    final defaultBoolConstraints = BiocentralConfigConstraints(typeConstraint: bool, allowedValues: {true, false});

    final eosToken = BiocentralConfigOption(
      name: 'eos_token',
      required: true,
      defaultValue: '</s>',
      category: 'special_tokens',
      constraints: defaultStringConstraints,
    );
    final padToken = BiocentralConfigOption(
      name: 'pad_token',
      required: true,
      defaultValue: '<pad>',
      category: 'special_tokens',
      constraints: defaultStringConstraints,
    );
    final unkToken = BiocentralConfigOption(
      name: 'unk_token',
      required: true,
      defaultValue: '<unk>',
      category: 'special_tokens',
      constraints: defaultStringConstraints,
    );

    final vocab = BiocentralConfigOption(
      name: 'vocab',
      category: 'vocabulary',
      required: true,
      constraints: defaultMapConstraints,
      defaultValue: Map.fromEntries(
        [
          ..._getStandardVocab(),
          eosToken.defaultValue,
          padToken.defaultValue,
          unkToken.defaultValue,
        ].indexed.map((indexChar) => MapEntry(indexChar.$2, indexChar.$1)),
      ),
    );

    final charactersToReplace = BiocentralConfigOption(
      name: 'chars_to_replace',
      required: false,
      defaultValue: 'UZOB',
      category: 'preprocessing',
      constraints: defaultStringConstraints,
    );
    final replacementCharacter = BiocentralConfigOption(
      name: 'replacement_char',
      required: false,
      defaultValue: 'X',
      category: 'preprocessing',
      constraints: defaultStringConstraints,
    );
    final usesWhitespaces = BiocentralConfigOption(
      name: 'uses_whitespaces',
      required: true,
      defaultValue: false,
      category: 'preprocessing',
      constraints: defaultBoolConstraints,
    );

    return TokenizerConfig._internal(
      eosToken: eosToken,
      padToken: padToken,
      unkToken: unkToken,
      vocab: vocab,
      charactersToReplace: charactersToReplace,
      replacementCharacter: replacementCharacter,
      usesWhitespaces: usesWhitespaces,
    );
  }

  static List<String> _getStandardVocab() {
    return [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z'
    ];
  }

  List<BiocentralConfigOption> get allOptions =>
      [eosToken, padToken, unkToken, vocab, charactersToReplace, replacementCharacter, usesWhitespaces];
}
