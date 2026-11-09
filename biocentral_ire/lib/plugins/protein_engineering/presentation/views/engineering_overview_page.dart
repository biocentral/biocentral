import 'package:biocentral/plugins/protein_engineering/domain/campaign_insights.dart';
import 'package:biocentral/plugins/protein_engineering/domain/mutation_descriptor.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/engineering_actions.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/widgets/round_box_plot.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Campaign overview composed from shared metrics, cards, and page structure.
class EngineeringOverviewPage extends StatelessWidget {
  final EngineeringCampaign campaign;
  final ValueChanged<int> onOpenRound;
  final VoidCallback onOpenHistory;

  const EngineeringOverviewPage({
    required this.campaign,
    required this.onOpenRound,
    required this.onOpenHistory,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final series = bestPerRound(campaign);
    final errors = predictionErrorsPerRound(campaign);
    final measured = measuredValuesPerRound(campaign);
    final best = bestMeasuredVariant(campaign);
    final busy = context.select<BiocentralCommandBloc, bool>((bloc) => bloc.state.isBusy());
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 32),
      children: [
        BiocentralPageHeader(
          title: campaign.config.name,
          description:
              'Goal — ${campaign.measurementName} (${campaign.measurementUnit}), '
              '${campaign.config.optimizationMode == ActiveLearningOptimizationMode.MAXIMIZE ? 'higher' : 'lower'} is better',
          actions: [
            ElevatedButton(
              onPressed: busy
                  ? null
                  : () => performEngineeringAction(context, () => showEngineeringRoundDialog(context, campaign)),
              child: const Text('Suggest next round →'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final (label, value, detail) in [
              (
                'Best variant',
                best == null
                    ? '—'
                    : wildtypeRelativeDescriptor(campaign.wildtypeSequence, best.sequence)?.replaceAll(':', ' + ') ??
                          'Wildtype',
                best?.fitness?.toString(),
              ),
              (
                'Over wildtype',
                bestOverWildtype(campaign)?.toStringAsFixed(2) ?? '—',
                'baseline ${campaign.wildtypeFitness ?? '—'}',
              ),
              ('Rounds completed', '${campaign.rounds.length}', null),
              ('Variants measured', '${campaign.measurements.length}', null),
            ])
              SizedBox(
                width: 220,
                child: BiocentralMetricCard(label: label, value: value, detail: detail),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _chart(
              'Best so far',
              series.length < 2
                  ? const BiocentralEmptyState(message: 'Complete rounds to see progress.')
                  : LineChart(
                      LineChartData(
                        titlesData: roundAxisTitles(context),
                        lineBarsData: [
                          LineChartBarData(
                            spots: series.map((point) => FlSpot(point.$1.toDouble(), point.$2)).toList(),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
            ),
            _chart(
              'Measured values per round',
              measured.isEmpty
                  ? const BiocentralEmptyState(message: 'No measurements yet.')
                  : RoundBoxPlot(series: measured),
            ),
            _chart(
              'Prediction errors per round',
              errors.isEmpty
                  ? const BiocentralEmptyState(message: 'Measure suggested variants to compare predictions.')
                  : RoundBoxPlot(series: errors, showZeroLine: true),
            ),
          ],
        ),
        const SizedBox(height: 20),
        BiocentralSectionCard(
          title: 'Rounds',
          child: Column(
            children: [
              for (var index = 0; index < campaign.rounds.length; index++)
                ListTile(
                  title: Text('Round ${campaign.rounds[index].sentConfig.iteration}'),
                  subtitle: Text('${campaign.rounds[index].result.suggestions.length} suggestions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onOpenRound(index),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        BiocentralSectionCard(
          title: 'Recent measurements',
          actions: [TextButton(onPressed: onOpenHistory, child: const Text('View all →'))],
          child: Column(
            children: [
              for (final value in campaign.measurements.values.toList().reversed.take(5))
                ListTile(
                  title: Text(value.seqId),
                  trailing: Text(value.didNotExpress ? 'Did not express' : '${value.fitness}'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chart(String title, Widget child) => SizedBox(
    width: 430,
    child: BiocentralSectionCard(
      title: title,
      child: SizedBox(height: 220, child: child),
    ),
  );
}
