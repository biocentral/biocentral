import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

import '../model/ppi_database_test.dart';

const List<String> hviToolkitPPIStandardizedColumns = [
  "interactor1",
  "interactor2",
  "taxon1",
  "taxon2",
  "interacting",
  "experimental_score"
];
const String ppiStdSeparator = ",";

Map<String, ProteinProteinInteraction> getInteractionsFromDatasetPPIStandardized(String dataset) {
  Map<String, ProteinProteinInteraction> ppis = {};
  final List<String> lines =
      dataset.split("\n").where((line) => line != "" && line != "\n" && line.contains(",")).toList();

  for (String line in lines.sublist(1)) {
    // Sublist: Skip header
    List<String> values = line.split(ppiStdSeparator);
    if (values.length != hviToolkitPPIStandardizedColumns.length) {
      throw Exception("Received dataset does not meet the standardized format,"
          "expected ${hviToolkitPPIStandardizedColumns.length} columns, but got ${values.length}!");
    }
    String interactor1ID = values[0];
    String interactor2ID = values[1];
    int? interactor1TaxonomyID = int.tryParse(values[2]);
    int? interactor2TaxonomyID = int.tryParse(values[3]);
    bool interacting = str2bool(values[4]);
    double? experimentalConfidenceScore = double.tryParse(values[5]);

    Taxonomy interactor1Taxonomy =
        interactor1TaxonomyID != null ? Taxonomy(id: interactor1TaxonomyID) : const Taxonomy.unknown();
    Taxonomy interactor2Taxonomy =
        interactor2TaxonomyID != null ? Taxonomy(id: interactor2TaxonomyID) : const Taxonomy.unknown();

    Protein interactor1 = Protein(interactor1ID, taxonomy: interactor1Taxonomy);
    Protein interactor2 = Protein(interactor2ID, taxonomy: interactor2Taxonomy);

    ProteinProteinInteraction ppi = ProteinProteinInteraction(interactor1, interactor2, interacting,
        experimentalConfidenceScore: experimentalConfidenceScore);
    ppis[ppi.getID()] = ppi;
  }
  return ppis;
}

List<PPIDatabaseTest> parseHVIToolkitDatasetTests(Map<String, dynamic> tests) {
  List<PPIDatabaseTest> result = [];
  for (MapEntry<String, dynamic> test in tests.entries) {
    PPIDatabaseTestType? testType = enumFromString(test.value["type"], PPIDatabaseTestType.values);
    List<PPIDatabaseTestRequirement>? requirements =
        _parseTestRequirements(List<String>.from(test.value["requirements"]));
    if (testType == null || requirements == null) {
      logger.e("Could not parse test ${test.key}!");
      continue;
    } else {
      PPIDatabaseTest datasetTest = PPIDatabaseTest(name: test.key, type: testType, requirements: requirements);
      result.add(datasetTest);
    }
  }
  return result;
}

Either<BiocentralException, BiocentralTestResult> parseTestResult(Map<String, dynamic> testResultMap) {
  // success, information, test_metrics, test_statistic, p_value, significance_level

  String information = testResultMap["information"] ?? "";
  bool? success;
  if (testResultMap["success"] != "") {
    success = str2bool(testResultMap["success"].toString());
  }
  Map<String, dynamic> testMetrics = {};
  if (testResultMap["test_metrics"] != "") {
    testMetrics = jsonDecode(testResultMap["test_metrics"])?[""] ?? "";
  }
  if (success != null && testMetrics.isNotEmpty) {
    return left(BiocentralParsingException(
        message: "Invalid type for received test result: "
            "must be binary test or metric test. $testResultMap"));
  }
  if (success == null && testMetrics.isEmpty) {
    return left(BiocentralParsingException(
        message: "Invalid type for received test result: "
            "must be binary test or metric test. $testResultMap"));
  }

  double? statistic = double.tryParse(testResultMap["test_statistic"].toString());
  double? pValue = double.tryParse(testResultMap["p_value"].toString());
  double? significanceLevel = double.tryParse(testResultMap["significance_level"].toString());
  BiocentralTestStatistic? testStatistic;
  if (statistic != null && pValue != null && significanceLevel != null) {
    testStatistic = BiocentralTestStatistic(statistic, pValue, significanceLevel);
  }
  BiocentralTestResult testResult =
      BiocentralTestResult(information, success: success, testMetrics: testMetrics, testStatistic: testStatistic);
  return right(testResult);
}

List<PPIDatabaseTestRequirement>? _parseTestRequirements(List<String>? requirements) {
  if (requirements == null || requirements.isEmpty) {
    return null;
  }

  List<PPIDatabaseTestRequirement> result = [];
  for (String requirement in requirements) {
    PPIDatabaseTestRequirement? testRequirement = enumFromString(requirement, PPIDatabaseTestRequirement.values);
    if (testRequirement == null) {
      return null;
    }
    result.add(testRequirement);
  }
  return result;
}

class DatasetEvaluatorOptions {
  final double significance = 0.05;
  final int hubThreshold = 5;
  final double biasThreshold = 0.9;
}

class PPIServiceEndpoints {
  static const String formatsEndpoint = "/ppi_service/formats";
  static const String autoDetectFormatEndpoint = "/ppi_service/auto_detect_format";
  static const String importEndpoint = "/ppi_service/import";
  static const String getDatasetTestsEndpoint = "/ppi_service/dataset_tests/tests";
  static const String runDatasetTestEndpoint = "/ppi_service/dataset_tests/run_test";
}
