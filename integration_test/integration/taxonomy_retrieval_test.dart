import 'package:biocentral/plugins/proteins/bloc/proteins_command_bloc.dart';
import 'package:biocentral/plugins/proteins/bloc/proteins_commands.dart';
import 'package:biocentral/plugins/proteins/data/protein_client.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bio_flutter/bio_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockBiocentralProjectRepository extends Mock implements BiocentralProjectRepository {}
class MockProteinClient extends Mock implements ProteinClient {}
class MockProteinRepository extends Mock implements ProteinRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('RetrieveTaxonomy Integration Test', () {
    late MockBiocentralProjectRepository mockProjectRepo;
    late MockProteinRepository mockProteinRepo;
    late MockProteinClient mockProteinClient;
    late RetrieveTaxonomyCommand retrieveTaxonomyCommand;

    setUp(() {
      mockProjectRepo = MockBiocentralProjectRepository();
      mockProteinRepo = MockProteinRepository();
      mockProteinClient = MockProteinClient();

      // Set up default behavior for mockProteinRepo
      when(() => mockProteinRepo.databaseToMap()).thenReturn({
        'Test1': const Protein('Test1', taxonomy: Taxonomy(id: 9606)),
        'Test2': const Protein('Test2', taxonomy: Taxonomy(id: 10090)),
      });
      when(() => mockProteinRepo.getTaxonomyIDs()).thenReturn({9606, 10090});
      when(() => mockProteinRepo.addTaxonomyData(any())).thenAnswer((invocation) async {
        final Map<int, Taxonomy> taxonomyData = invocation.positionalArguments[0];
        final proteins = mockProteinRepo.databaseToMap();
        for (var entry in proteins.entries) {
          if (taxonomyData.containsKey(entry.value.taxonomy.id)) {
            proteins[entry.key] = entry.value.copyWith(taxonomy: taxonomyData[entry.value.taxonomy.id]);
          }
        }
        return proteins;
      });

      retrieveTaxonomyCommand = RetrieveTaxonomyCommand(
        biocentralProjectRepository: mockProjectRepo,
        proteinRepository: mockProteinRepo,
        proteinClient: mockProteinClient,
        importMode: DatabaseImportMode.overwrite,
      );
    });

    testWidgets('Successfully retrieve and update taxonomy data', (WidgetTester tester) async {
      // Arrange
      final mockTaxonomyData = {
        9606: const Taxonomy(id: 9606, name: 'Homo sapiens', family: 'Hominidae'),
        10090: const Taxonomy(id: 10090, name: 'Mus musculus', family: 'Muridae'),
      };

      when(() => mockProteinClient.retrieveTaxonomy(any()))
          .thenAnswer((_) async => Right(mockTaxonomyData));

      // Act
      final result = retrieveTaxonomyCommand.execute<ProteinsCommandState>(const ProteinsCommandState.idle());

      // Assert
      await for (final either in result) {
        either.match(
              (state) {
            if (state.status == BiocentralCommandStatus.finished) {
              expect(state.stateInformation.information, contains('Finished retrieving taxonomy information'));
            }
          },
              (updatedProteins) {
            expect(updatedProteins, isA<Map<String, Protein>>());
            expect(updatedProteins.length, equals(2));
            expect(updatedProteins['Test1']?.taxonomy, equals(mockTaxonomyData[9606]));
            expect(updatedProteins['Test2']?.taxonomy, equals(mockTaxonomyData[10090]));
          },
        );
      }

      verify(() => mockProteinClient.retrieveTaxonomy(any())).called(1);
    });

    testWidgets('Handle empty taxonomy IDs', (WidgetTester tester) async {
      // Arrange
      when(() => mockProteinRepo.getTaxonomyIDs()).thenReturn({});

      // Act
      final result = retrieveTaxonomyCommand.execute<ProteinsCommandState>(const ProteinsCommandState.idle());

      // Assert
      Either<ProteinsCommandState, Map<String, Protein>> lastEither;
      await for (final either in result) {
        lastEither = either;
      }
      lastEither.match(
            (state) {
          expect(state.status, equals(BiocentralCommandStatus.errored));
          expect(state.stateInformation.information, contains('No taxonomy data available'));
        },
            (_) => fail('Expected Left, but got Right'),
      );
    });

    testWidgets('Handle error from ProteinClient', (WidgetTester tester) async {
      // Arrange
      when(() => mockProteinClient.retrieveTaxonomy(any()))
          .thenAnswer((_) async => Left(BiocentralNetworkException(message: 'Network error', log: false)));

      // Act
      final result = retrieveTaxonomyCommand.execute<ProteinsCommandState>(const ProteinsCommandState.idle());

      // Assert
      await for (final either in result) {
        either.match(
              (state) {
            if (state.status == BiocentralCommandStatus.errored) {
              expect(state.stateInformation.information, contains('Taxonomy data could not be retrieved'));
              expect(state.stateInformation.information, contains('Network error'));
            }
          },
              (_) => fail('Expected Left, but got Right'),
        );
      }

      verify(() => mockProteinClient.retrieveTaxonomy(any())).called(1);
    });
  });
}
