import 'package:biocentral/sdk/data/biocentral_task_dto.dart';


extension EmbeddingsDTO on BiocentralDTO {
  String? get embeddings => get<String>('embeddings_file');
}
