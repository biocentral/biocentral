import 'package:biocentral/sdk/data/biocentral_task_dto.dart';


extension EmbeddingsDTO on BiocentralDTO {
  Map<String, dynamic>? get embeddings => get<Map<String, dynamic>?>('embeddings_file');
}
