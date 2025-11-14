import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/proteins/bloc/proteins_command_bloc.dart';
import 'package:biocentral/plugins/proteins/bloc/proteins_commands.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBiocentralProjectRepository extends Mock implements BiocentralProjectRepository {}

class MockBiocentralAPIRepository extends Mock implements BiocentralAPIRepository {}

class MockProteinRepository extends Mock implements ProteinRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('RetrieveTaxonomy Integration Test', () {
    late MockBiocentralProjectRepository mockProjectRepo;
    late MockProteinRepository mockProteinRepo;
    late MockBiocentralAPIRepository mockAPIRepository;
    late RetrieveTaxonomyCommand retrieveTaxonomyCommand;

    setUp(() {
      mockProjectRepo = MockBiocentralProjectRepository();
      mockProteinRepo = MockProteinRepository();
      mockAPIRepository = MockBiocentralAPIRepository();

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
        apiRepository: mockAPIRepository,
        proteinRepository: mockProteinRepo,
        importMode: DatabaseImportMode.overwrite,
      );
    });

    testWidgets('Successfully retrieve and update taxonomy data', (WidgetTester tester) async {
      // Arrange
      final mockTaxonomyData = [
        TaxonomyItem((b) => b
          ..taxonomyId = 9606
          ..name = 'Homo sapiens'
          ..family = 'Hominidae',),
        TaxonomyItem((b) => b
          ..taxonomyId = 10090
          ..name = 'Mus musculus'
          ..family = 'Muridae',),
      ];

      when(() => mockAPIRepository.getBiocentralAPI().taxonomy(taxonomyIds: any()))
          .thenAnswer((_) async => mockTaxonomyData);
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

      verify(() => mockAPIRepository.getBiocentralAPI().taxonomy(taxonomyIds: any())).called(1);
    });

    testWidgets('Handle empty taxonomy IDs', (WidgetTester tester) async {
      // Arrange
      when(() => mockProteinRepo.getTaxonomyIDs()).thenReturn({});

      // Act
      final result = retrieveTaxonomyCommand.execute<ProteinsCommandState>(const ProteinsCommandState.idle());

      // Assert
      Either lastEither = Either.right({});
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
  });
}
