// TODO Available embedders should come from server
class PredefinedEmbedderContainer {
  static final PredefinedEmbedder prott5 =
      PredefinedEmbedder('ProtT5-XL-UniRef50', 'Rostlab/prot_t5_xl_uniref50', 'ProtT5');

  static final PredefinedEmbedder ankh = PredefinedEmbedder('Ankh Large', 'ElnaggarLab/ankh-large', 'Ankh Large');

  static final PredefinedEmbedder oneHotEncoding =
      PredefinedEmbedder('One Hot Encoding', 'one_hot_encoding', 'One Hot Encodings');

  static final PredefinedEmbedder customEmbedder = PredefinedEmbedder.customEmbedder();

  static List<PredefinedEmbedder> predefinedEmbedders() {
    return [oneHotEncoding, prott5, ankh, customEmbedder];
  }
}

class PredefinedEmbedder {
  final String name;
  final String? biotrainerName; // Huggingface URL or predefined name in biotrainer
  final String docs;

  static const String _customEmbedderName = 'custom_embedder';

  PredefinedEmbedder(this.name, this.biotrainerName, this.docs);

  PredefinedEmbedder.customEmbedder()
      : name = _customEmbedderName,
        biotrainerName = null,
        docs = 'Custom embedder name';

  PredefinedEmbedder copyWith({required String biotrainerName}) {
    return PredefinedEmbedder(name, biotrainerName, docs);
  }

  bool isCustomEmbedder() {
    return name == _customEmbedderName;
  }
}
