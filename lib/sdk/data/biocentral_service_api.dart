class BiocentralServiceEndpoints {
  static const services = '/biocentral_service/services';
  static const hashes = '/biocentral_service/hashes/';
  static const transferFile = '/biocentral_service/transfer_file';
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
