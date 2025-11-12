import 'package:test/test.dart';
import 'package:biocentral_api/biocentral_api.dart';


/// tests for EmbeddingsApi
void main() {
  final instance = BiocentralApi().getEmbeddingsApi();

  group(EmbeddingsApi, () {
    // Add embeddings
    //
    // Add pre-computed embeddings from HDF5 file to the embeddings database
    //
    //Future<AddEmbeddingsResponse> addEmbeddingsApiV1EmbeddingsServiceAddEmbeddingsPost(AddEmbeddingsRequest addEmbeddingsRequest) async
    test('test addEmbeddingsApiV1EmbeddingsServiceAddEmbeddingsPost', () async {
      // TODO
    });

    // Calculate embeddings
    //
    // Submit sequences for embedding calculation using specified embedder model
    //
    //Future<StartTaskResponse> embedApiV1EmbeddingsServiceEmbedPost(EmbedRequest embedRequest) async
    test('test embedApiV1EmbeddingsServiceEmbedPost', () async {
      // TODO
    });

    // Check missing embeddings
    //
    // Check which sequences are missing embeddings for a given embedder and reduction setting
    //
    //Future<GetMissingEmbeddingsResponse> getMissingEmbeddingsApiV1EmbeddingsServiceGetMissingEmbeddingsPost(GetMissingEmbeddingsRequest getMissingEmbeddingsRequest) async
    test('test getMissingEmbeddingsApiV1EmbeddingsServiceGetMissingEmbeddingsPost', () async {
      // TODO
    });

  });
}
