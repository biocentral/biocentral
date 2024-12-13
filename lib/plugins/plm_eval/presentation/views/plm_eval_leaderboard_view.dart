import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_leaderboard.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PLMEvalLeaderboardView extends StatefulWidget {
  final PLMLeaderboard leaderboard;

  const PLMEvalLeaderboardView({required this.leaderboard, super.key});

  @override
  State<PLMEvalLeaderboardView> createState() => _PLMEvalLeaderboardViewState();
}

class _PLMEvalLeaderboardViewState extends State<PLMEvalLeaderboardView> with AutomaticKeepAliveClientMixin {
  String? _selectedRankingName;
  final List<String> _selectableRankingKeys = ['global'];

  @override
  void initState() {
    super.initState();
    // Add all benchmark combinations to selectable rankings
    final combinedBenchmarkKeys = widget.leaderboard.benchmarkDatasets
        .map((benchmark) => '${benchmark.datasetName}-${benchmark.splitName}')
        .toList();
    _selectableRankingKeys.addAll(combinedBenchmarkKeys);
    _selectedRankingName = 'global';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        Expanded(
          child: SingleChildScrollView(
            child: _selectedRankingName == 'global'
                ? _buildGlobalRankingTable()
                : _buildTaskRankings(_selectedRankingName!),
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalRankingTable() {
    final globalRanking = widget.leaderboard.ranking;

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
                          child: GestureDetector(
                              onTap: () => launchUrlString('https://huggingface.co/$embedder'),
                              child: Text(
                            embedder,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.lightBlueAccent),
                          )),
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

  Widget _buildTaskRankings(String datasetSplit) {
    final parts = datasetSplit.split('-');
    if (parts.length != 2) return const SizedBox();

    final benchmark = BenchmarkDataset(
      datasetName: parts[0],
      splitName: parts[1],
    );

    final metrics = widget.leaderboard.getMetricsForBenchmark(benchmark);
    return BiocentralMetricsTable(metrics: metrics);
  }

  @override
  bool get wantKeepAlive => true;
}
