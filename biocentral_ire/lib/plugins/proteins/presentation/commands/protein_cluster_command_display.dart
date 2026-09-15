import 'package:biocentral/plugins/proteins/bloc/proteins_commands.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProteinClusterCommandDisplay extends StatefulWidget {
  const ProteinClusterCommandDisplay({super.key});

  @override
  State<ProteinClusterCommandDisplay> createState() => _ProteinClusterCommandDisplayState();
}

class _ProteinClusterCommandDisplayState extends State<ProteinClusterCommandDisplay> {
  double _sequenceIdentity = 0.3;
  DatabaseImportMode _importMode = DatabaseImportMode.defaultMode;

  ClusterProteinsCommand? collectCommand() {
    return ClusterProteinsCommand(
      biocentralProjectRepository: context.read(),
      proteinRepository: context.read(),
      apiRepository: context.read(),
      sequenceIdentityThreshold: _sequenceIdentity,
      importMode: _importMode,
    );
  }

  Widget buildVisualization(dynamic result) {
    String? svgString;
    try {
      svgString = (result as dynamic)?.chartSvg ?? (result as dynamic)?.output?.chartSvg;
    } catch (_) {}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (svgString != null && svgString.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: SvgPicture.string(
                svgString,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Divider(),
        ],
        BiocentralCommandWidget.visualizeDatabaseResult(result),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final BiocentralAPIRepository apiRepository = context.read();
    return StreamBuilder(
      initialData: apiRepository.currentHealth,
      stream: apiRepository.healthStatusStream,
      builder: (context, asyncSnapshot) {
        final currentHealth = asyncSnapshot.data ?? [];
        final availability = BiocentralCommandAvailability.fromHealth(currentHealth);
        return BiocentralCommandWidget(
          icon: const Icon(Icons.hub_outlined),
          name: 'Cluster protein sequences',
          description: 'Use pymmseqs to group protein sequences by similarity',
          executeButtonLabel: 'Cluster',
          parameterSelection: buildParameterSelection,
          collectCommand: collectCommand,
          visualizeResult: BiocentralCommandWidget.visualizeDatabaseResult,
          commandAvailability: availability,
        );
      },
    );
  }

  Widget buildParameterSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sequence Identity Threshold: ${(_sequenceIdentity * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _sequenceIdentity,
            min: 0.1,
            max: 1.0,
            divisions: 18,
            label: '${(_sequenceIdentity * 100).toInt()}%',
            onChanged: (value) {
              setState(() {
                _sequenceIdentity = value;
              });
            },
          ),
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
