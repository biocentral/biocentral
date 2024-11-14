class BiocentralServiceEndpoints {
  static const servicesEndpoint = '/biocentral_service/services';
  static const hashesEndpoint = '/biocentral_service/hashes/';
  static const transferFileEndpoint = '/biocentral_service/transfer_file';
}

enum StorageFileType {
  sequences,
  labels,
  masks,
  embeddings_per_residue,
  embeddings_per_sequence,
  biotrainer_config,
  biotrainer_logging,
  biotrainer_result,
  biotrainer_checkpoint
}
