import 'dart:async';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

import 'package:biocentral/plugins/ppi/model/ppi_database_test.dart';
import 'package:biocentral/plugins/ppi/data/ppi_service_api.dart';

final class PPIClientFactory extends BiocentralClientFactory<PPIClient> {
  @override
  PPIClient create(BiocentralServerData? server) {
    return PPIClient(server);
  }
}

class PPIClient extends BiocentralClient {
  PPIClient(super._server);

  Future<Either<BiocentralException, Map<String, String>>> getAvailableDatasetFormats() async {
    final responseEither = await doGetRequest(PPIServiceEndpoints.formats);
    return responseEither.flatMap((responseMap) =>
        right((responseMap as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()))),);
  }

  Future<Either<BiocentralException, String>> autoDetectFormat(String header) async {
    final Map<String, String> body = {'header': header};
    final responseEither = await doPostRequest(PPIServiceEndpoints.autoDetectFormat, body);
    return responseEither.flatMap((responseMap) => right(responseMap['detected_format']));
  }

  Future<Either<BiocentralException, Map<String, ProteinProteinInteraction>>> importInteractions(
      String dataset, String format,) async {
    final Map<String, String> body = {'dataset': dataset, 'format': format};
    final responseEither = await doPostRequest(PPIServiceEndpoints.import, body);
    return responseEither
        .flatMap((responseMap) => right(getInteractionsFromDatasetPPIStandardized(responseMap['imported_dataset'])));
  }

  Future<Either<BiocentralException, List<PPIDatabaseTest>>> getAvailableDatasetTests() async {
    final responseEither = await doGetRequest(PPIServiceEndpoints.getDatasetTests);
    return responseEither.flatMap((responseMap) => right(parseHVIToolkitDatasetTests(responseMap['dataset_tests'])));
  }

  Future<Either<BiocentralException, BiocentralTestResult>> runDatasetTest(
      String datasetHash, PPIDatabaseTest test,) async {
    final Map<String, String> body = {'hash': datasetHash, 'test': test.name};
    final responseEither = await doPostRequest(PPIServiceEndpoints.runDatasetTest, body);
    return responseEither.flatMap((responseMap) => parseTestResult(responseMap['test_result']));
  }

  @override
  String getServiceName() {
    return 'ppi_service';
  }
}
