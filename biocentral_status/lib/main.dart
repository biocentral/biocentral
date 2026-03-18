import 'package:biocentral_api/biocentral_api.dart';
import 'package:biocentral_status/biocentral_status_info.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const BiocentralStatusApp());
}

class BiocentralStatusApp extends StatelessWidget {
  const BiocentralStatusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biocentral Status',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: BiocentralStatusView(title: 'Biocentral Status'),
    );
  }
}

class BiocentralStatusView extends StatefulWidget {
  const BiocentralStatusView({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;

  @override
  State<BiocentralStatusView> createState() => _BiocentralStatusViewState();
}

class _BiocentralStatusViewState extends State<BiocentralStatusView> {
  final List<String> urls = ["https://biocentral.rostlab.org", "http://localhost:9540"];
  final Map<String, Future<BiocentralStatusInfo>> statusMap = {};

  @override
  void initState() {
    super.initState();
    for (final url in urls) {
      statusMap[url] = BiocentralStatusInfo.fromURL(url);
    }
  }

  void refreshServiceStats(String url) {
    setState(() {
      statusMap[url] = BiocentralStatusInfo.fromURL(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: statusMap.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Center(child: Text(widget.title)),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80.0),
            child: TabBar(
              tabs: statusMap.entries.map((entry) {
                return FutureBuilder(
                  future: entry.value,
                  builder: (context, snapshot) {
                    var tab;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      tab = Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      tab = Tab(text: entry.key);
                    } else if (snapshot.hasData) {
                      if(entry.key.contains("localhost") && !snapshot.data!.health.healthy) {
                       tab = Container(); // Don't show tab for localhost if not available
                      } else {
                        tab = buildTab(snapshot.data!);
                      }
                    }
                    tab ??= Tab(text: entry.key);
                    return tab;
                  },
                );
              }).toList(),
            ),
          ),
        ),
        body: TabBarView(
          children: statusMap.entries.map((entry) {
            return FutureBuilder<BiocentralStatusInfo>(
              future: entry.value,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return SingleChildScrollView(child: buildTabView(snapshot.data!));
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            );
          }).toList(),
        ),
        bottomSheet: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("A biocentral service.", style: TextStyle(fontStyle: FontStyle.italic)),
            Row(
              children: [
                Text("Inprint & Information: "),
                Text("https://biocentral.cloud", style: TextStyle(decoration: TextDecoration.underline)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultCard({required Widget child}) {
    return Card(margin: EdgeInsets.all(16.0), elevation: 4.0, child: child);
  }

  Widget buildTab(BiocentralStatusInfo statusInfo) {
    return _defaultCard(
      child: ListTile(
        leading: Icon(Icons.circle, color: statusInfo.health.healthy ? Colors.green : Colors.red, size: 24.0),
        title: Text(statusInfo.health.url, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: statusInfo.health.version != null ? Text('Version: ${statusInfo.health.version}') : null,
        trailing: IconButton(onPressed: () => refreshServiceStats(statusInfo.health.url), icon: Icon(Icons.refresh)),
      ),
    );
  }

  Widget buildTabView(BiocentralStatusInfo statusInfo) {
    return Column(
      children: [
        ListTile(
          title: Text("Server URL:", style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(statusInfo.health.url),
        ),
        ListTile(
          title: Text("Server Status:", style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(statusInfo.health.healthy ? "Online" : "Offline"),
        ),
        ListTile(
          title: Text("Server Version:", style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(statusInfo.health.version ?? "N/A"),
        ),
        buildServiceStats(statusInfo.serviceStats),
        buildResearchStats(statusInfo.researchStats),
      ],
    );
  }

  Widget buildServiceStats(BiocentralServiceStats? serviceStats) {
    return ExpansionTile(
      title: Text("Service Statistics", style: TextStyle(fontWeight: FontWeight.bold)),
      initiallyExpanded: serviceStats == null,
      children: serviceStats == null
          ? [Text("N/A")]
          : [
              ListTile(
                title: Text("Embeddings Database Size (MB):", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text((serviceStats.embeddingsDatabaseSize / (1024 * 1024)).toStringAsFixed(2)),
              ),
              ListTile(
                title: Text("Total Submitted Tasks Since Start:", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(serviceStats.totalTasks.toString()),
              ),
              ListTile(
                title: Text("Current Length of Task Queue:", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(serviceStats.queueLength.toString()),
              ),
              ListTile(
                title: Text("Usable CPU Count:", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(serviceStats.usableCpuCount.toString()),
              ),
              ListTile(
                title: Text("CUDA Available:", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(serviceStats.cudaAvailable ? "True" : "False"),
              ),
              ListTile(
                title: Text("CUDA Device Names:", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(serviceStats.cudaDeviceNames.isEmpty ? "None" : serviceStats.cudaDeviceNames.join(", ")),
              ),
              ListTile(
                title: Text("CUDA Device Count:", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(serviceStats.cudaDeviceCount.toString()),
              ),
            ],
    );
  }

  Widget buildResearchStats(ResearchStats? researchStats) {
    return _defaultCard(
      child: Column(
        children: [
          ListTile(
            title: Text("Research Data Statistics", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(researchStats?.updatedAt.toLocal().toString() ?? "N/A"),
          ),
          ...(researchStats == null
              ? [Container()]
              : [
                  ListTile(
                    title: Text("Total Number of Submitted Sequences:", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(researchStats.totalSequencesAllTime.toString()),
                  ),
                  ListTile(
                    title: Text("Average Submitted Sequence Length:", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(researchStats.avgSequenceLength.toString()),
                  ),
                  buildTopChart("Top Embedders (by usage):", researchStats.topEmbedders.asMap()),
                  buildTopChart("Top Predictors (by usage):", researchStats.topPredictors.asMap()),
                  buildAminoAcidDistributionChart(researchStats),
                ]),
        ],
      ),
    );
  }

  Widget buildTopChart(String title, Map<String, num> topMap) {
    if (topMap.isEmpty) {
      return ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("No data available"),
      );
    }

    final entries = topMap.entries.toList();
    final maxValue = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue * 1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < entries.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 14.0),
                            child: Transform.rotate(
                              angle: -0.785398,
                              child: Text(entries[value.toInt()].key, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          );
                        }
                        return Text('');
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: entries.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        color: Colors.deepPurple,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAminoAcidDistributionChart(ResearchStats researchStats) {
    if (researchStats.aaDistribution.isEmpty) {
      return ListTile(
        title: Text("Amino Acid Distribution:", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("No data available"),
      );
    }

    final entries = researchStats.aaDistribution.entries.toList();
    // Sort alphabetically for consistent display
    entries.sort((a, b) => a.key.compareTo(b.key));

    // Calculate total for percentages
    final totalAminoAcids = entries.fold<int>(0, (sum, entry) => sum + entry.value);

    // Convert to percentages
    final maxPercentage = entries
        .map((e) => (e.value / totalAminoAcids) * 100)
        .toList()
        .reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Amino Acid Distribution (%):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                maxY: maxPercentage * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final percentage = rod.toY;
                      return BarTooltipItem('${percentage.toStringAsFixed(1)}%', TextStyle(color: Colors.white));
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < entries.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(entries[value.toInt()].key, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          );
                        }
                        return Text('');
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toStringAsFixed(1)}%', style: TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: entries.asMap().entries.map((entry) {
                  final percentage = (entry.value.value / totalAminoAcids) * 100;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [BarChartRodData(toY: percentage, width: 20, borderRadius: BorderRadius.circular(4))],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
