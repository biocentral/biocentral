import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

class PredictionModelsServiceEndpoints {
  static const String protocolsEndpoint = "/prediction_models_service/protocols";
  static const String configOptionsEndpoint = "/prediction_models_service/config_options/";
  static const String verifyConfigEndpoint = "/prediction_models_service/verify_config/";
  static const String startTrainingEndpoint = "/prediction_models_service/start_training";
  static const String trainingStatusEndpoint = "/prediction_models_service/training_status";
  static const String modelFilesEndpoint = "/prediction_models_service/model_files";
}

class BiotrainerOption {
  final String name;
  final String category;
  final bool required;
  final String defaultValue;
  final List<String> possibleValues;

  BiotrainerOption(this.name, this.category, this.required, this.defaultValue, this.possibleValues);

  BiotrainerOption.fromMap(Map<String, dynamic> map)
      : name = map["name"],
        category = map["category"],
        required = str2bool(map["required"]),
        defaultValue = map["default_value"],
        possibleValues = List<String>.from(map["possible_values"]);
}

enum BiotrainerTrainingStatus {
  running,
  finished,
  failed;
}

class BiotrainerTrainingStatusDTO {
  final String logFile;
  final BiotrainerTrainingStatus trainingStatus;

  BiotrainerTrainingStatusDTO({required this.logFile, required this.trainingStatus});

  BiotrainerTrainingStatusDTO.failed()
      : logFile = "",
        trainingStatus = BiotrainerTrainingStatus.failed;

  static Either<BiocentralException, BiotrainerTrainingStatusDTO> fromResponseBody(Map responseBody) {
    String? logFile = responseBody["log_file"]?.toString();
    String? status = responseBody["status"]?.toString();
    if (logFile == null || status == null) {
      return left(BiocentralParsingException(message: "BiotrainerTrainingStatusDTO is missing logFile and/or status!"));
    }
    BiotrainerTrainingStatus? trainingStatus = enumFromString(status.toLowerCase(), BiotrainerTrainingStatus.values);
    if (trainingStatus == null) {
      return left(BiocentralParsingException(message: "BiotrainerTrainingStatusDTO is missing trainingStatus!"));
    }
    return right(BiotrainerTrainingStatusDTO(logFile: logFile, trainingStatus: trainingStatus));
  }
}

class BiotrainerTrainingResult implements Comparable<BiotrainerTrainingResult> {
  final Map<int, double> trainingLoss;
  final Map<int, double> validationLoss;
  final Set<BiocentralMLMetric> testSetMetrics;
  final Set<String> sanityCheckWarnings;
  final Map<String, Set<BiocentralMLMetric>> sanityCheckBaselineMetrics;

  BiotrainerTrainingResult(
      {required this.trainingLoss,
      required this.validationLoss,
      required this.testSetMetrics,
      required this.sanityCheckWarnings,
      required this.sanityCheckBaselineMetrics});

  @override
  int compareTo(BiotrainerTrainingResult other) {
    return this == other ? 0 : -1;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiotrainerTrainingResult &&
          runtimeType == other.runtimeType &&
          trainingLoss == other.trainingLoss &&
          validationLoss == other.validationLoss &&
          testSetMetrics == other.testSetMetrics &&
          sanityCheckWarnings == other.sanityCheckWarnings &&
          sanityCheckBaselineMetrics == other.sanityCheckBaselineMetrics;

  @override
  int get hashCode => testSetMetrics.hashCode ^ sanityCheckWarnings.hashCode ^ sanityCheckBaselineMetrics.hashCode;
}
