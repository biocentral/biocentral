import 'package:cross_file/cross_file.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

class BiocentralServiceEndpoints {
  static const services = '/biocentral_service/services';
  static const hashes = '/biocentral_service/hashes/';
  static const transferFile = '/biocentral_service/transfer_file';
  static const taskStatus = '/biocentral_service/task_status';
  static const taskStatusResumed = '/biocentral_service/task_status_resumed';
}

// TODO [Refactoring] Refactor to BiocentralFile and make available via some repository for generic enhance-ability
enum StorageFileType {
  sequences,
  labels,
  masks,
  embeddings_per_residue,
  embeddings_per_sequence,
  biotrainer_config,
  biotrainer_logging,
  biotrainer_result,
  biotrainer_checkpoint;

  /// First one is default extension
  List<String> getPossibleExtensions() {
    switch(this) {
      case StorageFileType.sequences: return ['fasta'];
      case StorageFileType.labels: return ['fasta'];
      case StorageFileType.masks: return ['fasta'];
      case StorageFileType.embeddings_per_residue: return ['h5'];
      case StorageFileType.embeddings_per_sequence: return ['h5'];
      case StorageFileType.biotrainer_config: return ['yml', 'yaml'];
      case StorageFileType.biotrainer_logging: return ['log'];
      case StorageFileType.biotrainer_result: return ['yml', 'yaml'];
      case StorageFileType.biotrainer_checkpoint: return ['safetensors', 'onnx'];
    }
  }

  String getDefaultFileName() {
    final fileName = switch(this) {
      StorageFileType.biotrainer_config => 'config',
      StorageFileType.biotrainer_logging => 'logger_out',
      StorageFileType.biotrainer_result => 'out',
      _ => name,
    };
    return '$fileName.${getPossibleExtensions().first}';
  }

  bool isFileOfType(XFile file) {
    final defaultFileName = getDefaultFileName();
    final fileExtensions = getPossibleExtensions();
    if (file.name == defaultFileName) {
      return true;
    }
    if (defaultFileName.contains(file.name) && fileExtensions.contains(file.extension)) {
      return true;
    }
    return false;
  }
}
