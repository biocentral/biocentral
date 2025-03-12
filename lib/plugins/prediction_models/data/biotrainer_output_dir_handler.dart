import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:cross_file/cross_file.dart';

class BiotrainerOutputDirHandler {
  static (XFile?, XFile?, XFile?, XFile?) scanDirectoryFiles(List<XFile> files) {
    final XFile? configFile = files.where((file) => StorageFileType.biotrainer_config.isFileOfType(file)).firstOrNull;
    final XFile? outputFile = files.where((file) => StorageFileType.biotrainer_result.isFileOfType(file)).firstOrNull;
    final XFile? loggingFile = files.where((file) => StorageFileType.biotrainer_logging.isFileOfType(file)).firstOrNull;
    // TODO [Feature] Support multiple checkpoints
    final XFile? checkpointFile =
        files.where((file) => StorageFileType.biotrainer_checkpoint.isFileOfType(file)).firstOrNull;
    return (configFile, outputFile, loggingFile, checkpointFile);
  }
}
