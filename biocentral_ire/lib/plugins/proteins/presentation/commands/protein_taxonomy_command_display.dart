import 'package:biocentral/plugins/proteins/bloc/proteins_commands.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProteinTaxonomyCommandDisplay extends StatefulWidget {
  const ProteinTaxonomyCommandDisplay({super.key});

  @override
  State<ProteinTaxonomyCommandDisplay> createState() => _ProteinTaxonomyCommandDisplayState();
}

class _ProteinTaxonomyCommandDisplayState extends State<ProteinTaxonomyCommandDisplay> {
  DatabaseImportMode _importMode = DatabaseImportMode.defaultMode;

  RetrieveTaxonomyCommand? collectCommand() {
    return RetrieveTaxonomyCommand(
      biocentralProjectRepository: context.read(),
      proteinRepository: context.read(),
      apiRepository: context.read(),
      importMode: _importMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProteinRepository proteinRepository = context.read();
    final BiocentralAPIRepository apiRepository = context.read();
    return StreamBuilder(
      initialData: apiRepository.currentHealth,
      stream: apiRepository.healthStatusStream,
      builder: (context, asyncSnapshotHealth) {
        return StreamBuilder(
          initialData: proteinRepository.databaseToMap(),
          stream: proteinRepository.databaseStream,
          builder: (context, asyncSnapshotDatabase) {
            final currentHealth = asyncSnapshotHealth.data ?? [];
            final apiAvailability = BiocentralCommandAvailability.fromHealth(currentHealth);
            final anyIdsAvailable =
                RetrieveTaxonomyCommand.checkNumberOfIDsAvailable(asyncSnapshotDatabase.data ?? {}) > 0;
            return BiocentralCommandWidget(
              icon: const Icon(Icons.nature_people_rounded),
              name: 'Retrieve taxonomy information',
              description: 'Get missing taxonomy data for your proteins',
              executeButtonLabel: 'Retrieve',
              parameterSelection: buildParameterSelection,
              collectCommand: collectCommand,
              visualizeResult: BiocentralCommandWidget.visualizeDatabaseResult,
              commandAvailability: apiAvailability.and(
                  condition: anyIdsAvailable,
                  unavailableMessage: 'No taxonomy information available for your proteins'),
            );
          },
        );
      },
    );
  }

  Widget buildParameterSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          BiocentralImportModeSelection(
            onChangedCallback: (importMode) => setState(() {
              _importMode = importMode ?? DatabaseImportMode.defaultMode;
            }),
          ),
        ].withPadding(const Padding(
          padding: EdgeInsetsGeometry.all(8.0),
        )),
      ),
    );
  }
}
