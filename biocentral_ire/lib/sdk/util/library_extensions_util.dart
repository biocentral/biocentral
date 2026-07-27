import 'package:bio_flutter/bio_flutter.dart';

extension DisplayName on EmbeddingType {
  String displayName() {
    switch (this) {
      case EmbeddingType.perSequence:
        return 'Per Sequence';
      case EmbeddingType.perResidue:
        return 'Per Residue';
    }
  }
}
