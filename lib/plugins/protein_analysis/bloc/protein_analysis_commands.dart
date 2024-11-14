import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

import 'package:biocentral/plugins/protein_analysis/data/protein_analysis_client.dart';
import 'package:biocentral/plugins/protein_analysis/model/levenshtein_distance.dart';

final class CalculateLevenshteinDistanceCommand
    extends BiocentralCommand<Map<String, Map<String, LevenshteinDistance>>> {
  // TODO
  final ProteinRepository _proteinRepository;
  final ProteinAnalysisClient _proteinAnalysisClient;

  CalculateLevenshteinDistanceCommand(
      {required ProteinRepository proteinRepository, required ProteinAnalysisClient proteinAnalysisClient,})
      : _proteinRepository = proteinRepository,
        _proteinAnalysisClient = proteinAnalysisClient;

  @override
  Stream<Either<T, Map<String, Map<String, LevenshteinDistance>>>> execute<T extends BiocentralCommandState<T>>(
      T state,) async* {
    yield left(state.setOperating(information: 'Calculating Levenshtein distance ratios..'));
    final String databaseHash = await _proteinRepository.getHash();

    final transferResult = await _proteinAnalysisClient.transferFile(
        databaseHash, StorageFileType.sequences, () async => _proteinRepository.convertToString('fasta'),);

    transferResult.match((error) async* {
      yield left(state.setErrored(information: 'Database file could not be transferred!'));
    }, (u) async* {
      final levenshteinDistanceMapEither = await _proteinAnalysisClient.calculateLevenshteinDistance(databaseHash);
      levenshteinDistanceMapEither.match((error) async* {
        yield left(state = state.setErrored(information: 'Levenshtein distances could not be calculated!'));
      }, (levenshteinDistanceMap) async* {
        logger.i(levenshteinDistanceMap);
        yield left(state.setFinished(information: 'Finished calculating levenshtein distances!'));
        yield right(levenshteinDistanceMap);
      });
    });
  }

  @override
  Map<String, dynamic> getConfigMap() {
    // TODO Change if more parameters are necessary
    return {};
  }
}
