import 'package:biocentral/sdk/data/biocentral_task_dto.dart';


extension EmbeddingsDTO on BiocentralDTO {
  int? get embeddingProgress => get<int>('embedding_progress');
  String? get embeddings => get<String>('embeddings_file');
}
