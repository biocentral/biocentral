import 'dart:convert';

import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:biocentral/sdk/model/biocentral_ml_metrics.dart';
import 'package:biocentral/sdk/util/logging.dart';

extension BiotrainerLogFileHandler on BiotrainerFileHandler {
  static Set<BiocentralMLMetric> _parseMLMetricsMap(Map<String, dynamic> metricsMap) {
    if (!metricsMap.containsKey('results')) {
      return _parseRegularMetrics(metricsMap);
    }
    return _parseBootstrappingMetrics(metricsMap);
  }

  static Set<BiocentralMLMetric> _parseRegularMetrics(Map<String, dynamic> metricsMap) {
    final Set<BiocentralMLMetric> result = {};

    for (var entry in metricsMap.entries) {
      final mlMetric = BiocentralMLMetric.tryParse(entry.key, entry.value.toString());
      if (mlMetric == null) {
        logger.e('MLMetric could not be parsed: $entry');
        continue;
      }
      result.add(mlMetric);
    }

    return result;
  }

  static Set<BiocentralMLMetric> _parseBootstrappingMetrics(Map<String, dynamic> metricsMap) {
    final Set<BiocentralMLMetric> result = {};
    final results = metricsMap['results'] as Map<String, dynamic>;
    final iterations = metricsMap['iterations'] as int?;
    final sampleSize = metricsMap['sample_size'] as int?;

    for (var entry in results.entries) {
      final uncertaintyData = entry.value as Map<String, dynamic>;
      final mean = double.tryParse(uncertaintyData['mean'].toString());
      final error = double.tryParse(uncertaintyData['error'].toString());

      if (mean == null || error == null) {
        logger.e('Could not parse bootstrapping result: $entry');
        continue;
      }

      result.add(
        _createBootstrappingMetric(
          name: entry.key,
          mean: mean,
          error: error,
          iterations: iterations,
          sampleSize: sampleSize,
        ),
      );
    }

    return result;
  }

  static BiocentralMLMetric _createBootstrappingMetric({
    required String name,
    required double mean,
    required double error,
    int? iterations,
    int? sampleSize,
  }) {
    final uncertaintyEstimate = UncertaintyEstimate(
      method: 'bootstrap',
      mean: mean,
      error: error,
      iterations: iterations,
      sampleSize: sampleSize,
    );

    return BiocentralMLMetric(
      name: name,
      value: mean,
      uncertaintyEstimate: uncertaintyEstimate,
    );
  }

  static BiotrainerTrainingResult parseBiotrainerLog({
    required String trainingLog,
    BiocentralTaskStatus? trainingStatus,
  }) {
    final parser = _BiotrainerLogParser(trainingLog);

    parser.parse();

    final status = trainingStatus ??
        (parser.testSetMetrics.isEmpty ? BiocentralTaskStatus.running : BiocentralTaskStatus.finished);

    return BiotrainerTrainingResult(
      trainingLoss: parser.trainingLoss,
      validationLoss: parser.validationLoss,
      testSetMetrics: parser.testSetMetrics,
      sanityCheckWarnings: parser.sanityCheckWarnings,
      sanityCheckBaselineMetrics: parser.sanityCheckBaselineMetrics,
      trainingLogs: parser.logs,
      trainingStatus: status,
    );
  }
}

class _BiotrainerLogIdentifiers {
  static final String testSetMetrics = 'INFO Test set metrics: ';
  static final String bootstrappingResults = 'INFO Bootstrapping results: ';
  static final String sanityChecksStart = 'INFO Running sanity checks on test results..';
  static final String sanityChecksEnd = 'INFO Sanity check on test results finished!';
  static final String warning = ' WARNING ';
  static final String info = ' INFO ';
  static final String epoch = 'INFO Epoch ';
  static final String trainingResults = 'INFO Training results';
  static final String validationResults = 'INFO Validation results';
  static final String loss = '\tloss: ';
}

class _BiotrainerLogParser {
  final List<String> logs;
  final Set<BiocentralMLMetric> testSetMetrics = {};
  final Set<String> sanityCheckWarnings = {};
  final Map<String, Set<BiocentralMLMetric>> sanityCheckBaselineMetrics = {};
  final Map<int, double> trainingLoss = {};
  final Map<int, double> validationLoss = {};

  bool _inSanityCheckArea = false;
  bool _inTrainingResults = false;
  bool _inValidationResults = false;
  int _currentEpoch = -1;

  _BiotrainerLogParser(String trainingLog) : logs = trainingLog.split('\n');

  void parse() {
    for (String line in logs) {
      _parseLine(line);
    }
  }

  void _parseLine(String line) {
    if (_parseEpochInfo(line)) return;
    if (_parseResultsType(line)) return;
    if (_parseLoss(line)) return;
    if (_parseMetricsAndSanityChecks(line)) return;
  }

  bool _parseEpochInfo(String line) {
    if (!line.contains(_BiotrainerLogIdentifiers.epoch)) return false;

    _currentEpoch = int.parse(line.split(_BiotrainerLogIdentifiers.epoch).last.trim());
    _inTrainingResults = false;
    _inValidationResults = false;
    return true;
  }

  bool _parseResultsType(String line) {
    if (line.contains(_BiotrainerLogIdentifiers.trainingResults)) {
      _inTrainingResults = true;
      _inValidationResults = false;
      return true;
    }
    if (line.contains(_BiotrainerLogIdentifiers.validationResults)) {
      _inTrainingResults = false;
      _inValidationResults = true;
      return true;
    }
    return false;
  }

  bool _parseLoss(String line) {
    if (!line.contains(_BiotrainerLogIdentifiers.loss)) return false;

    final double? loss = double.tryParse(line.split(_BiotrainerLogIdentifiers.loss).last.trim());
    if (loss == null) return true;

    if (_inTrainingResults) {
      trainingLoss[_currentEpoch] = loss;
    } else if (_inValidationResults) {
      validationLoss[_currentEpoch] = loss;
    }
    return true;
  }

  bool _parseMetricsAndSanityChecks(String line) {
    if (_parseTestSetMetrics(line)) return true;
    if (_parseBootstrappingResults(line)) return true;
    if (_parseSanityCheckBoundaries(line)) return true;
    if (_inSanityCheckArea) {
      _parseSanityCheckContent(line);
      return true;
    }
    return false;
  }

  bool _parseTestSetMetrics(String line) {
    if (!line.contains(_BiotrainerLogIdentifiers.testSetMetrics)) return false;

    final String metrics = line.split(_BiotrainerLogIdentifiers.testSetMetrics).last;
    final Map<String, dynamic> metricsMap = jsonDecode(metrics.replaceAll("'", '"'));
    testSetMetrics.addAll(BiotrainerLogFileHandler._parseMLMetricsMap(metricsMap));
    return true;
  }

  bool _parseBootstrappingResults(String line) {
    if (!line.contains(_BiotrainerLogIdentifiers.bootstrappingResults)) return false;

    final String metrics = line.split(_BiotrainerLogIdentifiers.bootstrappingResults).last;
    final Map<String, dynamic> metricsMap = jsonDecode(metrics.replaceAll("'", '"'));
    testSetMetrics.clear(); // Bootstrapping results overwrite regular test set metrics
    testSetMetrics.addAll(BiotrainerLogFileHandler._parseMLMetricsMap(metricsMap));
    return true;
  }

  bool _parseSanityCheckBoundaries(String line) {
    if (line.contains(_BiotrainerLogIdentifiers.sanityChecksStart)) {
      _inSanityCheckArea = true;
      return true;
    }
    if (line.contains(_BiotrainerLogIdentifiers.sanityChecksEnd)) {
      _inSanityCheckArea = false;
      return true;
    }
    return false;
  }

  void _parseSanityCheckContent(String line) {
    if (line.isEmpty) return;

    if (line.contains(_BiotrainerLogIdentifiers.warning)) {
      final String sanityCheckWarning = line.split(_BiotrainerLogIdentifiers.warning).last;
      sanityCheckWarnings.add(sanityCheckWarning);
    } else if (line.contains(_BiotrainerLogIdentifiers.info)) {
      _parseSanityCheckBaselineMetrics(line);
    } else {
      logger.e('Invalid sanity check line: $line');
    }
  }

  void _parseSanityCheckBaselineMetrics(String line) {
    final List<String> baselineNameAndMetrics = line.split(_BiotrainerLogIdentifiers.info).last.split('Baseline: ');

    if (baselineNameAndMetrics.length != 2) {
      logger.e('Invalid baseline metrics format: $line');
      return;
    }

    final String baselineName = '${baselineNameAndMetrics[0]}Baseline';

    try {
      final Map<String, dynamic> baselineMetricsMap = jsonDecode(baselineNameAndMetrics[1].replaceAll("'", '"'));
      final Set<BiocentralMLMetric> baselineMLMetrics = BiotrainerLogFileHandler._parseMLMetricsMap(baselineMetricsMap);
      sanityCheckBaselineMetrics[baselineName] = baselineMLMetrics;
    } catch (e) {
      logger.e('Failed to parse baseline metrics: $e');
    }
  }
}
