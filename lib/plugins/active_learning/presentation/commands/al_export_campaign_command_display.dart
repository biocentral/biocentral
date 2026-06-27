import 'package:biocentral/plugins/active_learning/bloc/al_commands.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_file_path_selection.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ALExportCampaignCommandDisplay extends StatefulWidget {
  const ALExportCampaignCommandDisplay({super.key});

  @override
  State<ALExportCampaignCommandDisplay> createState() => _ALExportCampaignCommandDisplayState();
}

class _ALExportCampaignCommandDisplayState extends State<ALExportCampaignCommandDisplay> {
  ALCampaign? _selectedCampaign;
  String? _exportPath;

  ALExportCampaignCommand? collectCommand() {
    if (_selectedCampaign != null && _exportPath != null) {
      return ALExportCampaignCommand(
        projectRepository: context.read<BiocentralProjectRepository>(),
        campaign: _selectedCampaign!,
        filePath: _exportPath!,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ALHubBloc, ALHubState>(
      listenWhen: (previous, current) => previous.selectedCampaign != current.selectedCampaign,
      listener: (context, state) {
        setState(() {
          _selectedCampaign = state.selectedCampaign;
          _exportPath = null;
        });
      },
      builder: (context, state) {
        final availability = BiocentralCommandAvailability(
          available: state.campaigns.isNotEmpty,
          unavailableMessage: 'No campaigns available to export!',
        );
        return BiocentralCommandWidget(
          icon: const Icon(Icons.save),
          name: 'Export campaign',
          description: 'Save a campaign to a JSON file',
          executeButtonLabel: 'Export',
          parameterSelection: () => buildParameterSelection(state.campaigns),
          collectCommand: collectCommand,
          visualizeResult: BiocentralCommandWidget.visualizeDatabaseResult,
          commandAvailability: availability,
          alwaysAutoAccept: true,
        );
      },
    );
  }

  Widget buildParameterSelection(List<ALCampaign> campaigns) {
    final defaultFileName = 'campaign_${_selectedCampaign?.config.name ?? 'export'}.json';
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          BiocentralDiscreteSelection<ALCampaign>(
            title: 'Campaign to export',
            selectableValues: campaigns,
            initialValue: _selectedCampaign,
            displayConversion: (c) => c.config.name,
            onChangedCallback: (ALCampaign? selected) {
              setState(() {
                _selectedCampaign = selected;
                _exportPath = null;
              });
            },
          ),
          BiocentralFilePathSelection(
            defaultName: _exportPath ?? defaultFileName,
            allowedExtensions: const ['json'],
            fileSelectedCallback: (_, path) => setState(() {
              _exportPath = path;
            }),
            pickForExport: true,
          ),
        ].withPadding(const Padding(padding: EdgeInsets.all(8.0))),
      ),
    );
  }
}
