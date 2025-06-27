import 'package:biocentral/sdk/data/biocentral_task_dto.dart';

extension EmbeddingsDTO on BiocentralDTO {
  (int, int)? get embeddingProgress => get<int>('embedding_current') != null
      ? (get<int>('embedding_current') ?? 0, get<int>('embedding_total') ?? 0)
      : null;

  String? get embeddings => get<String>('embeddings_file');
}
