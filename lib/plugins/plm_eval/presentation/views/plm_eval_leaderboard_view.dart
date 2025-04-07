import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_leaderboard_bloc.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_leaderboard.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/plots/biocentral_bar_plot.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PLMEvalLeaderboardSelectionView extends StatefulWidget {
  const PLMEvalLeaderboardSelectionView({super.key});

  @override
  State<PLMEvalLeaderboardSelectionView> createState() => _PLMEvalLeaderboardSelectionViewState();
}

class _PLMEvalLeaderboardSelectionViewState extends State<PLMEvalLeaderboardSelectionView> {
  PLMLeaderboardKind _selection = PLMLeaderboardKind.mixed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PLMEvalLeaderboardBloc, PLMEvalLeaderboardState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            children: [
              BiocentralDiscreteSelection<PLMLeaderboardKind>(
                title: 'Leaderboard Selection',
                selectableValues: PLMLeaderboardKind.values,
                displayConversion: (kind) => kind.name,
                initialValue: PLMLeaderboardKind.mixed,
                onChangedCallback: (PLMLeaderboardKind? value) {
                  setState(() {
                    if (value != null) {
                      _selection = value;
                    }
                  });
                },
              ),
              buildLeaderboardFromSelection(state),
            ].withPadding(const Padding(padding: EdgeInsets.all(10.0))),
          ),
        );
      },
    );
  }

  Widget buildLeaderboardFromSelection(PLMEvalLeaderboardState state) {
    switch (_selection) {
      case PLMLeaderboardKind.mixed:
        return PLMEvalLeaderboardView(
          leaderboard: state.mixedLeaderboard,
          recommendedMetrics: state.recommendedMetrics,
          publishableModels: state.getPublishableModels(),
        );
      case PLMLeaderboardKind.remote:
        return PLMEvalLeaderboardView(
          leaderboard: state.remoteLeaderboard,
          recommendedMetrics: state.recommendedMetrics,
          publishableModels: const {},
        );
      case PLMLeaderboardKind.local:
        return PLMEvalLeaderboardView(
          leaderboard: state.localLeaderboard,
          recommendedMetrics: state.recommendedMetrics,
          publishableModels: state.getPublishableModels(),
        );
    }
  }
}

class PLMEvalLeaderboardView extends StatefulWidget {
  final PLMLeaderboard leaderboard;
  final Map<String, String> recommendedMetrics;
  final Set<String> publishableModels;

  const PLMEvalLeaderboardView({
    required this.leaderboard,
    required this.recommendedMetrics,
    required this.publishableModels,
    super.key,
  });

  @override
  State<PLMEvalLeaderboardView> createState() => _PLMEvalLeaderboardViewState();
}

class _PLMEvalLeaderboardViewState extends State<PLMEvalLeaderboardView> with AutomaticKeepAliveClientMixin {
  String? _selectedRankingName;
  final Set<String> _selectableRankingKeys = {'global'};

  @override
  void initState() {
    super.initState();
    addBenchmarkKeys();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    addBenchmarkKeys();
  }

  void addBenchmarkKeys() {
    // Add all benchmark combinations to selectable rankings
    final combinedBenchmarkKeys = widget.leaderboard.benchmarkDatasets
        .map((benchmark) => '${benchmark.datasetName}-${benchmark.splitName}')
        .toSet();
    _selectableRankingKeys.addAll(combinedBenchmarkKeys);
    _selectedRankingName = 'global';
  }

  String getMetric(String datasetName) {
    return widget.recommendedMetrics[datasetName] ?? PLMLeaderboard.fallbackMetric;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.leaderboard.isEmpty()) {
      return const Text('No leaderboard entries yet!');
    }
      return Column(
      children: [
        BiocentralDropdownMenu(
          dropdownMenuEntries:
              _selectableRankingKeys.map((name) => DropdownMenuEntry(value: name, label: name)).toList(),
          label: const Text('Select ranking..'),
          controller: TextEditingController.fromValue(TextEditingValue(text: _selectedRankingName ?? '')),
          onSelected: (String? value) {
            if (value != null && value.isNotEmpty) {
              setState(() {
                _selectedRankingName = value;
              });
            }
          },
        ),
        Container(
          child:
              _selectedRankingName == 'global' ? _buildGlobalRankingTable() : _buildTaskRankings(_selectedRankingName!),
        ),
      ],
    );
  }

  Widget _buildGlobalRankingTable() {
    final globalRanking = widget.leaderboard.getRanking(widget.recommendedMetrics);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Global Embedder Ranking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(2),
              },
              children: [
                const TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Embedder', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Score', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                ...globalRanking.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final embedder = entry.value.$1;
                  final score = entry.value.$2.toStringAsFixed(2);
                  return TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(rank.toString()),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () => launchUrlString('https://huggingface.co/$embedder'),
                                child: Text(
                                  embedder,
                                  style:
                                      Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.lightBlueAccent),
                                ),
                              ),
                              _buildPublishingButton(embedder),
                            ],
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(score),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishingButton(String model) {
    if (widget.publishableModels.contains(model)) {
      final PLMEvalLeaderboardBloc plmEvalLeaderboardBloc = BlocProvider.of<PLMEvalLeaderboardBloc>(context);

      Widget textButtonChild = const Text('Publish!');
      if (plmEvalLeaderboardBloc.state.status == PLMEvalLeaderBoardStatus.publishing) {
        textButtonChild = const CircularProgressIndicator();
      }
      var textButtonFunction = () => plmEvalLeaderboardBloc.add(PLMEvalLeaderboardPublishEvent(model));
      if (plmEvalLeaderboardBloc.state.status == PLMEvalLeaderBoardStatus.publishing) {
        textButtonFunction = () {};
      }
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton(onPressed: textButtonFunction, child: textButtonChild),
      );
    }
    return Container();
  }

  Widget _buildTaskRankings(String datasetSplit) {
    final parts = datasetSplit.split('-');
    if (parts.length != 2) return const SizedBox();

    final benchmark = BenchmarkDataset(
      datasetName: parts[0],
      splitName: parts[1],
    );

    final metricForDataset = getMetric(benchmark.datasetName);
    final (tableData, plotData) = widget.leaderboard.getMetricsDataForBenchmark(benchmark, metricForDataset);
    return Column(
      children: [
        BiocentralMetricsTable(
          metrics: tableData,
          initialSortingMetric: metricForDataset,
          prominentMetric: metricForDataset,
        ),
        SizedBox(
          height: SizeConfig.screenHeight(context) * 0.2,
          width: SizeConfig.screenWidth(context) * 0.4,
          child: BiocentralBarPlot(
            data: BiocentralBarPlotData.withErrors(plotData),
            xAxisLabel: 'Model',
            yAxisLabel: metricForDataset,
            maxLabelLength: 30,
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
