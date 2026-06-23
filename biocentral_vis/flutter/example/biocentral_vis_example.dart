import 'package:biocentral_vis/biocentral_vis.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(BioVizApp());
}

class BioVizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BioViz - SVG Interactive Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Map<String, PlotData> allPlotData;

  String? selected;

  @override
  void initState() {
    super.initState();
    // Simulate loading data from Python backend
    final allData = {
      "lossCurves": MockDataGenerator.lossCurves(),
      "sequenceHighlight": MockDataGenerator.sequenceHighlight(),
      "labelDistribution": MockDataGenerator.labelDistribution(),
      "testSetPerformance": MockDataGenerator.testSetPerformance(),
    };
    allPlotData = allData.map((k, v) => MapEntry(k, PlotData.fromJson(v)));
    selected = "lossCurves";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BioViz - Interactive Gene Expression'),
        actions: [
          IconButton(
            icon: Icon(Icons.skip_previous),
            onPressed: () {
              final allKeys = allPlotData.keys.toList();
              int currentIdx = allKeys.indexOf(selected!) - 1;
              if(currentIdx <  0) {
                currentIdx = 0;
              }
              final nextKey = allKeys[currentIdx];
              setState(() {
                selected = nextKey;
              });
            },
            tooltip: 'Previous Plot',
          ),
          IconButton(
            icon: Icon(Icons.next_plan_outlined),
            onPressed: () {
              final allKeys = allPlotData.keys.toList();
              final currentIdx = allKeys.indexOf(selected!);
              final nextKey = allKeys[(currentIdx + 1) % allKeys.length];
              setState(() {
                selected = nextKey;
              });
            },
            tooltip: 'Next Plot',
          ),
          IconButton(icon: Icon(Icons.info_outline), onPressed: () => _showInfoDialog(), tooltip: 'About'),
        ],
      ),
      body: InteractiveSvgChart(plotData: allPlotData[selected!]!),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About This Demo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SVG + JSON Metadata Approach', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            Text('✅ No WebView required'),
            Text('✅ Works on Linux, macOS, Windows'),
            Text('✅ Native Flutter performance'),
            Text('✅ Full interactivity (hover, zoom, pan)'),
            Text('✅ Generated from Python'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                'This demonstrates how Python can generate SVG + metadata that Flutter renders interactively without any web dependencies!',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Got it!'))],
      ),
    );
  }
}

class MockDataGenerator {
  static Map<String, dynamic> sequenceHighlight() {
    return {
      "svg":
      "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"800\" height=\"320\">\n  <style>\n    .residue { font-family: monospace; font-size: 14px; }\n    .title { font-family: sans-serif; font-size: 16px; font-weight: bold; }\n    .legend { font-family: sans-serif; font-size: 12px; }\n  </style>\n  <rect width=\"100%\" height=\"100%\" fill=\"white\"/>\n  <text x=\"400.0\" y=\"25\" class=\"title\" text-anchor=\"middle\">Sequence Highlight: Secondary Structure</text>\n  <rect x=\"40\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"M\" data-prediction=\"C\" data-index=\"1\"/>\n  <text x=\"46.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">M</text>\n  <rect x=\"40\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"M\" data-prediction=\"C\" data-index=\"1\"/>\n  <text x=\"46.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"52\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"C\" data-index=\"2\"/>\n  <text x=\"58.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">K</text>\n  <rect x=\"52\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"C\" data-index=\"2\"/>\n  <text x=\"58.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"64\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"T\" data-prediction=\"C\" data-index=\"3\"/>\n  <text x=\"70.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">T</text>\n  <rect x=\"64\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"T\" data-prediction=\"C\" data-index=\"3\"/>\n  <text x=\"70.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"76\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"C\" data-index=\"4\"/>\n  <text x=\"82.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">A</text>\n  <rect x=\"76\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"C\" data-index=\"4\"/>\n  <text x=\"82.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"88\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Y\" data-prediction=\"H\" data-index=\"5\"/>\n  <text x=\"94.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">Y</text>\n  <rect x=\"88\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Y\" data-prediction=\"H\" data-index=\"5\"/>\n  <text x=\"94.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"100\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"H\" data-index=\"6\"/>\n  <text x=\"106.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">I</text>\n  <rect x=\"100\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"H\" data-index=\"6\"/>\n  <text x=\"106.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"112\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"H\" data-index=\"7\"/>\n  <text x=\"118.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">A</text>\n  <rect x=\"112\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"H\" data-index=\"7\"/>\n  <text x=\"118.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"124\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"8\"/>\n  <text x=\"130.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">K</text>\n  <rect x=\"124\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"8\"/>\n  <text x=\"130.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"136\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"9\"/>\n  <text x=\"142.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"136\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"9\"/>\n  <text x=\"142.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"148\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"H\" data-index=\"10\"/>\n  <text x=\"154.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">R</text>\n  <rect x=\"148\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"H\" data-index=\"10\"/>\n  <text x=\"154.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"160\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"11\"/>\n  <text x=\"166.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"160\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"11\"/>\n  <text x=\"166.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"172\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"H\" data-index=\"12\"/>\n  <text x=\"178.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">I</text>\n  <rect x=\"172\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"H\" data-index=\"12\"/>\n  <text x=\"178.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"184\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"13\"/>\n  <text x=\"190.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"184\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"13\"/>\n  <text x=\"190.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"196\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"F\" data-prediction=\"H\" data-index=\"14\"/>\n  <text x=\"202.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">F</text>\n  <rect x=\"196\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"F\" data-prediction=\"H\" data-index=\"14\"/>\n  <text x=\"202.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"208\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"H\" data-index=\"15\"/>\n  <text x=\"214.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">V</text>\n  <rect x=\"208\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"H\" data-index=\"15\"/>\n  <text x=\"214.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"220\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"16\"/>\n  <text x=\"226.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">K</text>\n  <rect x=\"220\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"16\"/>\n  <text x=\"226.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"232\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"17\"/>\n  <text x=\"238.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"232\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"17\"/>\n  <text x=\"238.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"244\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"H\" data-prediction=\"C\" data-index=\"18\"/>\n  <text x=\"250.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"244\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"H\" data-prediction=\"C\" data-index=\"18\"/>\n  <text x=\"250.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"256\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"F\" data-prediction=\"C\" data-index=\"19\"/>\n  <text x=\"262.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">F</text>\n  <rect x=\"256\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"F\" data-prediction=\"C\" data-index=\"19\"/>\n  <text x=\"262.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"268\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"C\" data-index=\"20\"/>\n  <text x=\"274.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"268\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"C\" data-index=\"20\"/>\n  <text x=\"274.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"280\" y=\"46\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"E\" data-index=\"21\"/>\n  <text x=\"286.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">R</text>\n  <rect x=\"280\" y=\"76\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"E\" data-index=\"21\"/>\n  <text x=\"286.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"292\" y=\"46\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"E\" data-index=\"22\"/>\n  <text x=\"298.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"292\" y=\"76\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"E\" data-index=\"22\"/>\n  <text x=\"298.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"304\" y=\"46\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"E\" data-index=\"23\"/>\n  <text x=\"310.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"304\" y=\"76\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"E\" data-index=\"23\"/>\n  <text x=\"310.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"316\" y=\"46\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"E\" data-index=\"24\"/>\n  <text x=\"322.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"316\" y=\"76\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"E\" data-index=\"24\"/>\n  <text x=\"322.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"328\" y=\"46\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"E\" data-index=\"25\"/>\n  <text x=\"334.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"328\" y=\"76\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"E\" data-index=\"25\"/>\n  <text x=\"334.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"340\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"C\" data-index=\"26\"/>\n  <text x=\"346.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">R</text>\n  <rect x=\"340\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"C\" data-index=\"26\"/>\n  <text x=\"346.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"352\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"27\"/>\n  <text x=\"358.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"352\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"27\"/>\n  <text x=\"358.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"364\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"C\" data-index=\"28\"/>\n  <text x=\"370.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">G</text>\n  <rect x=\"364\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"C\" data-index=\"28\"/>\n  <text x=\"370.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"376\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"29\"/>\n  <text x=\"382.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"376\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"29\"/>\n  <text x=\"382.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"388\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"C\" data-index=\"30\"/>\n  <text x=\"394.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">I</text>\n  <rect x=\"388\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"C\" data-index=\"30\"/>\n  <text x=\"394.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"400\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"C\" data-index=\"31\"/>\n  <text x=\"406.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"400\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"C\" data-index=\"31\"/>\n  <text x=\"406.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"412\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"C\" data-index=\"32\"/>\n  <text x=\"418.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">V</text>\n  <rect x=\"412\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"C\" data-index=\"32\"/>\n  <text x=\"418.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"424\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"C\" data-index=\"33\"/>\n  <text x=\"430.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"424\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"C\" data-index=\"33\"/>\n  <text x=\"430.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"436\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"C\" data-index=\"34\"/>\n  <text x=\"442.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">A</text>\n  <rect x=\"436\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"C\" data-index=\"34\"/>\n  <text x=\"442.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"448\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"P\" data-prediction=\"C\" data-index=\"35\"/>\n  <text x=\"454.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">P</text>\n  <rect x=\"448\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"P\" data-prediction=\"C\" data-index=\"35\"/>\n  <text x=\"454.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"460\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"C\" data-index=\"36\"/>\n  <text x=\"466.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">I</text>\n  <rect x=\"460\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"C\" data-index=\"36\"/>\n  <text x=\"466.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"472\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"37\"/>\n  <text x=\"478.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"472\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"37\"/>\n  <text x=\"478.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"484\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"C\" data-index=\"38\"/>\n  <text x=\"490.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"484\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"C\" data-index=\"38\"/>\n  <text x=\"490.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"496\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"C\" data-index=\"39\"/>\n  <text x=\"502.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">R</text>\n  <rect x=\"496\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"C\" data-index=\"39\"/>\n  <text x=\"502.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"508\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"C\" data-index=\"40\"/>\n  <text x=\"514.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">V</text>\n  <rect x=\"508\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"C\" data-index=\"40\"/>\n  <text x=\"514.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"520\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"C\" data-index=\"41\"/>\n  <text x=\"526.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">G</text>\n  <rect x=\"520\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"C\" data-index=\"41\"/>\n  <text x=\"526.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"532\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"D\" data-prediction=\"H\" data-index=\"42\"/>\n  <text x=\"538.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">D</text>\n  <rect x=\"532\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"D\" data-prediction=\"H\" data-index=\"42\"/>\n  <text x=\"538.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"544\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"H\" data-index=\"43\"/>\n  <text x=\"550.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">G</text>\n  <rect x=\"544\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"H\" data-index=\"43\"/>\n  <text x=\"550.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"556\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"T\" data-prediction=\"H\" data-index=\"44\"/>\n  <text x=\"562.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">T</text>\n  <rect x=\"556\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"T\" data-prediction=\"H\" data-index=\"44\"/>\n  <text x=\"562.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"568\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"45\"/>\n  <text x=\"574.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"568\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"45\"/>\n  <text x=\"574.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"580\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"D\" data-prediction=\"H\" data-index=\"46\"/>\n  <text x=\"586.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">D</text>\n  <rect x=\"580\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"D\" data-prediction=\"H\" data-index=\"46\"/>\n  <text x=\"586.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"592\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"N\" data-prediction=\"H\" data-index=\"47\"/>\n  <text x=\"598.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">N</text>\n  <rect x=\"592\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"N\" data-prediction=\"H\" data-index=\"47\"/>\n  <text x=\"598.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"604\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"H\" data-index=\"48\"/>\n  <text x=\"610.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"604\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"H\" data-index=\"48\"/>\n  <text x=\"610.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"616\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"49\"/>\n  <text x=\"622.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"616\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"49\"/>\n  <text x=\"622.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"628\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"H\" data-index=\"50\"/>\n  <text x=\"634.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">G</text>\n  <rect x=\"628\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"H\" data-index=\"50\"/>\n  <text x=\"634.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"640\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"H\" data-index=\"51\"/>\n  <text x=\"646.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">A</text>\n  <rect x=\"640\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"H\" data-index=\"51\"/>\n  <text x=\"646.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"652\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"H\" data-index=\"52\"/>\n  <text x=\"658.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"652\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"H\" data-index=\"52\"/>\n  <text x=\"658.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"664\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"53\"/>\n  <text x=\"670.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">K</text>\n  <rect x=\"664\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"53\"/>\n  <text x=\"670.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"676\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"M\" data-prediction=\"C\" data-index=\"54\"/>\n  <text x=\"682.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">M</text>\n  <rect x=\"676\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"M\" data-prediction=\"C\" data-index=\"54\"/>\n  <text x=\"682.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"688\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"C\" data-index=\"55\"/>\n  <text x=\"694.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">K</text>\n  <rect x=\"688\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"C\" data-index=\"55\"/>\n  <text x=\"694.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"700\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"T\" data-prediction=\"C\" data-index=\"56\"/>\n  <text x=\"706.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">T</text>\n  <rect x=\"700\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"T\" data-prediction=\"C\" data-index=\"56\"/>\n  <text x=\"706.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"712\" y=\"46\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"C\" data-index=\"57\"/>\n  <text x=\"718.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">A</text>\n  <rect x=\"712\" y=\"76\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"C\" data-index=\"57\"/>\n  <text x=\"718.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"724\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Y\" data-prediction=\"H\" data-index=\"58\"/>\n  <text x=\"730.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">Y</text>\n  <rect x=\"724\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Y\" data-prediction=\"H\" data-index=\"58\"/>\n  <text x=\"730.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"736\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"H\" data-index=\"59\"/>\n  <text x=\"742.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">I</text>\n  <rect x=\"736\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"H\" data-index=\"59\"/>\n  <text x=\"742.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"748\" y=\"46\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"H\" data-index=\"60\"/>\n  <text x=\"754.0\" y=\"60\" class=\"residue\" text-anchor=\"middle\">A</text>\n  <rect x=\"748\" y=\"76\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"H\" data-index=\"60\"/>\n  <text x=\"754.0\" y=\"90\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"40\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"61\"/>\n  <text x=\"46.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">K</text>\n  <rect x=\"40\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"61\"/>\n  <text x=\"46.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"52\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"62\"/>\n  <text x=\"58.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"52\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"62\"/>\n  <text x=\"58.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"64\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"H\" data-index=\"63\"/>\n  <text x=\"70.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">R</text>\n  <rect x=\"64\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"H\" data-index=\"63\"/>\n  <text x=\"70.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"76\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"64\"/>\n  <text x=\"82.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"76\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"64\"/>\n  <text x=\"82.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"88\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"H\" data-index=\"65\"/>\n  <text x=\"94.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">I</text>\n  <rect x=\"88\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"H\" data-index=\"65\"/>\n  <text x=\"94.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"100\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"66\"/>\n  <text x=\"106.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"100\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"66\"/>\n  <text x=\"106.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"112\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"F\" data-prediction=\"H\" data-index=\"67\"/>\n  <text x=\"118.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">F</text>\n  <rect x=\"112\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"F\" data-prediction=\"H\" data-index=\"67\"/>\n  <text x=\"118.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"124\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"H\" data-index=\"68\"/>\n  <text x=\"130.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">V</text>\n  <rect x=\"124\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"H\" data-index=\"68\"/>\n  <text x=\"130.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"136\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"69\"/>\n  <text x=\"142.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">K</text>\n  <rect x=\"136\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"69\"/>\n  <text x=\"142.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"148\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"70\"/>\n  <text x=\"154.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"148\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"70\"/>\n  <text x=\"154.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"160\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"H\" data-prediction=\"C\" data-index=\"71\"/>\n  <text x=\"166.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"160\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"H\" data-prediction=\"C\" data-index=\"71\"/>\n  <text x=\"166.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"172\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"F\" data-prediction=\"C\" data-index=\"72\"/>\n  <text x=\"178.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">F</text>\n  <rect x=\"172\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"F\" data-prediction=\"C\" data-index=\"72\"/>\n  <text x=\"178.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"184\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"C\" data-index=\"73\"/>\n  <text x=\"190.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"184\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"C\" data-index=\"73\"/>\n  <text x=\"190.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"196\" y=\"106\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"E\" data-index=\"74\"/>\n  <text x=\"202.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">R</text>\n  <rect x=\"196\" y=\"136\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"E\" data-index=\"74\"/>\n  <text x=\"202.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"208\" y=\"106\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"E\" data-index=\"75\"/>\n  <text x=\"214.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"208\" y=\"136\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"E\" data-index=\"75\"/>\n  <text x=\"214.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"220\" y=\"106\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"E\" data-index=\"76\"/>\n  <text x=\"226.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"220\" y=\"136\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"E\" data-index=\"76\"/>\n  <text x=\"226.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"232\" y=\"106\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"E\" data-index=\"77\"/>\n  <text x=\"238.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"232\" y=\"136\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"E\" data-index=\"77\"/>\n  <text x=\"238.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"244\" y=\"106\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"E\" data-index=\"78\"/>\n  <text x=\"250.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"244\" y=\"136\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"E\" data-index=\"78\"/>\n  <text x=\"250.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"256\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"C\" data-index=\"79\"/>\n  <text x=\"262.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">R</text>\n  <rect x=\"256\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"C\" data-index=\"79\"/>\n  <text x=\"262.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"268\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"80\"/>\n  <text x=\"274.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"268\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"80\"/>\n  <text x=\"274.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"280\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"C\" data-index=\"81\"/>\n  <text x=\"286.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">G</text>\n  <rect x=\"280\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"C\" data-index=\"81\"/>\n  <text x=\"286.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"292\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"82\"/>\n  <text x=\"298.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"292\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"82\"/>\n  <text x=\"298.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"304\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"C\" data-index=\"83\"/>\n  <text x=\"310.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">I</text>\n  <rect x=\"304\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"C\" data-index=\"83\"/>\n  <text x=\"310.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"316\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"C\" data-index=\"84\"/>\n  <text x=\"322.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"316\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"C\" data-index=\"84\"/>\n  <text x=\"322.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"328\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"C\" data-index=\"85\"/>\n  <text x=\"334.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">V</text>\n  <rect x=\"328\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"C\" data-index=\"85\"/>\n  <text x=\"334.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"340\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"C\" data-index=\"86\"/>\n  <text x=\"346.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"340\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"C\" data-index=\"86\"/>\n  <text x=\"346.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"352\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"C\" data-index=\"87\"/>\n  <text x=\"358.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">A</text>\n  <rect x=\"352\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"C\" data-index=\"87\"/>\n  <text x=\"358.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"364\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"P\" data-prediction=\"C\" data-index=\"88\"/>\n  <text x=\"370.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">P</text>\n  <rect x=\"364\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"P\" data-prediction=\"C\" data-index=\"88\"/>\n  <text x=\"370.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"376\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"C\" data-index=\"89\"/>\n  <text x=\"382.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">I</text>\n  <rect x=\"376\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"C\" data-index=\"89\"/>\n  <text x=\"382.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"388\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"90\"/>\n  <text x=\"394.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"388\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"90\"/>\n  <text x=\"394.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"400\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"C\" data-index=\"91\"/>\n  <text x=\"406.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"400\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"C\" data-index=\"91\"/>\n  <text x=\"406.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"412\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"C\" data-index=\"92\"/>\n  <text x=\"418.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">R</text>\n  <rect x=\"412\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"C\" data-index=\"92\"/>\n  <text x=\"418.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"424\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"C\" data-index=\"93\"/>\n  <text x=\"430.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">V</text>\n  <rect x=\"424\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"C\" data-index=\"93\"/>\n  <text x=\"430.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"436\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"C\" data-index=\"94\"/>\n  <text x=\"442.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">G</text>\n  <rect x=\"436\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"C\" data-index=\"94\"/>\n  <text x=\"442.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"448\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"D\" data-prediction=\"H\" data-index=\"95\"/>\n  <text x=\"454.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">D</text>\n  <rect x=\"448\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"D\" data-prediction=\"H\" data-index=\"95\"/>\n  <text x=\"454.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"460\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"H\" data-index=\"96\"/>\n  <text x=\"466.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">G</text>\n  <rect x=\"460\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"H\" data-index=\"96\"/>\n  <text x=\"466.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"472\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"T\" data-prediction=\"H\" data-index=\"97\"/>\n  <text x=\"478.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">T</text>\n  <rect x=\"472\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"T\" data-prediction=\"H\" data-index=\"97\"/>\n  <text x=\"478.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"484\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"98\"/>\n  <text x=\"490.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"484\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"98\"/>\n  <text x=\"490.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"496\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"D\" data-prediction=\"H\" data-index=\"99\"/>\n  <text x=\"502.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">D</text>\n  <rect x=\"496\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"D\" data-prediction=\"H\" data-index=\"99\"/>\n  <text x=\"502.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"508\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"N\" data-prediction=\"H\" data-index=\"100\"/>\n  <text x=\"514.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">N</text>\n  <rect x=\"508\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"N\" data-prediction=\"H\" data-index=\"100\"/>\n  <text x=\"514.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"520\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"H\" data-index=\"101\"/>\n  <text x=\"526.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"520\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"H\" data-index=\"101\"/>\n  <text x=\"526.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"532\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"102\"/>\n  <text x=\"538.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"532\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"102\"/>\n  <text x=\"538.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"544\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"H\" data-index=\"103\"/>\n  <text x=\"550.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">G</text>\n  <rect x=\"544\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"H\" data-index=\"103\"/>\n  <text x=\"550.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"556\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"H\" data-index=\"104\"/>\n  <text x=\"562.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">A</text>\n  <rect x=\"556\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"H\" data-index=\"104\"/>\n  <text x=\"562.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"568\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"H\" data-index=\"105\"/>\n  <text x=\"574.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"568\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"H\" data-index=\"105\"/>\n  <text x=\"574.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"580\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"106\"/>\n  <text x=\"586.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">K</text>\n  <rect x=\"580\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"106\"/>\n  <text x=\"586.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"592\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"M\" data-prediction=\"C\" data-index=\"107\"/>\n  <text x=\"598.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">M</text>\n  <rect x=\"592\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"M\" data-prediction=\"C\" data-index=\"107\"/>\n  <text x=\"598.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"604\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"C\" data-index=\"108\"/>\n  <text x=\"610.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">K</text>\n  <rect x=\"604\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"C\" data-index=\"108\"/>\n  <text x=\"610.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"616\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"T\" data-prediction=\"C\" data-index=\"109\"/>\n  <text x=\"622.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">T</text>\n  <rect x=\"616\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"T\" data-prediction=\"C\" data-index=\"109\"/>\n  <text x=\"622.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"628\" y=\"106\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"C\" data-index=\"110\"/>\n  <text x=\"634.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">A</text>\n  <rect x=\"628\" y=\"136\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"C\" data-index=\"110\"/>\n  <text x=\"634.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"640\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Y\" data-prediction=\"H\" data-index=\"111\"/>\n  <text x=\"646.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">Y</text>\n  <rect x=\"640\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Y\" data-prediction=\"H\" data-index=\"111\"/>\n  <text x=\"646.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"652\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"H\" data-index=\"112\"/>\n  <text x=\"658.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">I</text>\n  <rect x=\"652\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"H\" data-index=\"112\"/>\n  <text x=\"658.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"664\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"H\" data-index=\"113\"/>\n  <text x=\"670.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">A</text>\n  <rect x=\"664\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"H\" data-index=\"113\"/>\n  <text x=\"670.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"676\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"114\"/>\n  <text x=\"682.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">K</text>\n  <rect x=\"676\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"114\"/>\n  <text x=\"682.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"688\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"115\"/>\n  <text x=\"694.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"688\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"115\"/>\n  <text x=\"694.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"700\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"H\" data-index=\"116\"/>\n  <text x=\"706.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">R</text>\n  <rect x=\"700\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"H\" data-index=\"116\"/>\n  <text x=\"706.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"712\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"117\"/>\n  <text x=\"718.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"712\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"117\"/>\n  <text x=\"718.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"724\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"H\" data-index=\"118\"/>\n  <text x=\"730.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">I</text>\n  <rect x=\"724\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"H\" data-index=\"118\"/>\n  <text x=\"730.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"736\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"119\"/>\n  <text x=\"742.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"736\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"119\"/>\n  <text x=\"742.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"748\" y=\"106\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"F\" data-prediction=\"H\" data-index=\"120\"/>\n  <text x=\"754.0\" y=\"120\" class=\"residue\" text-anchor=\"middle\">F</text>\n  <rect x=\"748\" y=\"136\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"F\" data-prediction=\"H\" data-index=\"120\"/>\n  <text x=\"754.0\" y=\"150\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"40\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"H\" data-index=\"121\"/>\n  <text x=\"46.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">V</text>\n  <rect x=\"40\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"H\" data-index=\"121\"/>\n  <text x=\"46.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"52\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"122\"/>\n  <text x=\"58.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">K</text>\n  <rect x=\"52\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"122\"/>\n  <text x=\"58.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"64\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"123\"/>\n  <text x=\"70.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"64\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"123\"/>\n  <text x=\"70.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"76\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"H\" data-prediction=\"C\" data-index=\"124\"/>\n  <text x=\"82.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"76\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"H\" data-prediction=\"C\" data-index=\"124\"/>\n  <text x=\"82.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"88\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"F\" data-prediction=\"C\" data-index=\"125\"/>\n  <text x=\"94.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">F</text>\n  <rect x=\"88\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"F\" data-prediction=\"C\" data-index=\"125\"/>\n  <text x=\"94.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"100\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"C\" data-index=\"126\"/>\n  <text x=\"106.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"100\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"C\" data-index=\"126\"/>\n  <text x=\"106.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"112\" y=\"166\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"E\" data-index=\"127\"/>\n  <text x=\"118.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">R</text>\n  <rect x=\"112\" y=\"196\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"E\" data-index=\"127\"/>\n  <text x=\"118.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"124\" y=\"166\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"E\" data-index=\"128\"/>\n  <text x=\"130.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"124\" y=\"196\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"E\" data-index=\"128\"/>\n  <text x=\"130.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"136\" y=\"166\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"E\" data-index=\"129\"/>\n  <text x=\"142.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"136\" y=\"196\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"E\" data-index=\"129\"/>\n  <text x=\"142.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"148\" y=\"166\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"E\" data-index=\"130\"/>\n  <text x=\"154.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"148\" y=\"196\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"E\" data-index=\"130\"/>\n  <text x=\"154.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"160\" y=\"166\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"E\" data-index=\"131\"/>\n  <text x=\"166.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"160\" y=\"196\" width=\"12\" height=\"20\" fill=\"#4ECDC4\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"E\" data-index=\"131\"/>\n  <text x=\"166.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"172\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"C\" data-index=\"132\"/>\n  <text x=\"178.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">R</text>\n  <rect x=\"172\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"C\" data-index=\"132\"/>\n  <text x=\"178.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"184\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"133\"/>\n  <text x=\"190.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"184\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"133\"/>\n  <text x=\"190.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"196\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"C\" data-index=\"134\"/>\n  <text x=\"202.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">G</text>\n  <rect x=\"196\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"C\" data-index=\"134\"/>\n  <text x=\"202.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"208\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"135\"/>\n  <text x=\"214.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"208\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"135\"/>\n  <text x=\"214.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"220\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"C\" data-index=\"136\"/>\n  <text x=\"226.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">I</text>\n  <rect x=\"220\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"C\" data-index=\"136\"/>\n  <text x=\"226.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"232\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"C\" data-index=\"137\"/>\n  <text x=\"238.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"232\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"C\" data-index=\"137\"/>\n  <text x=\"238.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"244\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"C\" data-index=\"138\"/>\n  <text x=\"250.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">V</text>\n  <rect x=\"244\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"C\" data-index=\"138\"/>\n  <text x=\"250.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"256\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"C\" data-index=\"139\"/>\n  <text x=\"262.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"256\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"C\" data-index=\"139\"/>\n  <text x=\"262.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"268\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"C\" data-index=\"140\"/>\n  <text x=\"274.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">A</text>\n  <rect x=\"268\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"C\" data-index=\"140\"/>\n  <text x=\"274.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"280\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"P\" data-prediction=\"C\" data-index=\"141\"/>\n  <text x=\"286.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">P</text>\n  <rect x=\"280\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"P\" data-prediction=\"C\" data-index=\"141\"/>\n  <text x=\"286.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"292\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"C\" data-index=\"142\"/>\n  <text x=\"298.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">I</text>\n  <rect x=\"292\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"I\" data-prediction=\"C\" data-index=\"142\"/>\n  <text x=\"298.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"304\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"143\"/>\n  <text x=\"310.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"304\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"C\" data-index=\"143\"/>\n  <text x=\"310.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"316\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"C\" data-index=\"144\"/>\n  <text x=\"322.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"316\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"C\" data-index=\"144\"/>\n  <text x=\"322.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"328\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"C\" data-index=\"145\"/>\n  <text x=\"334.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">R</text>\n  <rect x=\"328\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"R\" data-prediction=\"C\" data-index=\"145\"/>\n  <text x=\"334.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"340\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"C\" data-index=\"146\"/>\n  <text x=\"346.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">V</text>\n  <rect x=\"340\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"V\" data-prediction=\"C\" data-index=\"146\"/>\n  <text x=\"346.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"352\" y=\"166\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"C\" data-index=\"147\"/>\n  <text x=\"358.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">G</text>\n  <rect x=\"352\" y=\"196\" width=\"12\" height=\"20\" fill=\"#95E1D3\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"C\" data-index=\"147\"/>\n  <text x=\"358.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">C</text>\n  <rect x=\"364\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"D\" data-prediction=\"H\" data-index=\"148\"/>\n  <text x=\"370.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">D</text>\n  <rect x=\"364\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"D\" data-prediction=\"H\" data-index=\"148\"/>\n  <text x=\"370.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"376\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"H\" data-index=\"149\"/>\n  <text x=\"382.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">G</text>\n  <rect x=\"376\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"H\" data-index=\"149\"/>\n  <text x=\"382.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"388\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"T\" data-prediction=\"H\" data-index=\"150\"/>\n  <text x=\"394.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">T</text>\n  <rect x=\"388\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"T\" data-prediction=\"H\" data-index=\"150\"/>\n  <text x=\"394.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"400\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"151\"/>\n  <text x=\"406.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">Q</text>\n  <rect x=\"400\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"Q\" data-prediction=\"H\" data-index=\"151\"/>\n  <text x=\"406.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"412\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"D\" data-prediction=\"H\" data-index=\"152\"/>\n  <text x=\"418.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">D</text>\n  <rect x=\"412\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"D\" data-prediction=\"H\" data-index=\"152\"/>\n  <text x=\"418.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"424\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"N\" data-prediction=\"H\" data-index=\"153\"/>\n  <text x=\"430.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">N</text>\n  <rect x=\"424\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"N\" data-prediction=\"H\" data-index=\"153\"/>\n  <text x=\"430.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"436\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"H\" data-index=\"154\"/>\n  <text x=\"442.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">L</text>\n  <rect x=\"436\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"L\" data-prediction=\"H\" data-index=\"154\"/>\n  <text x=\"442.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"448\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"155\"/>\n  <text x=\"454.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">S</text>\n  <rect x=\"448\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"S\" data-prediction=\"H\" data-index=\"155\"/>\n  <text x=\"454.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"460\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"H\" data-index=\"156\"/>\n  <text x=\"466.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">G</text>\n  <rect x=\"460\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"G\" data-prediction=\"H\" data-index=\"156\"/>\n  <text x=\"466.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"472\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"H\" data-index=\"157\"/>\n  <text x=\"478.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">A</text>\n  <rect x=\"472\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"A\" data-prediction=\"H\" data-index=\"157\"/>\n  <text x=\"478.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"484\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"H\" data-index=\"158\"/>\n  <text x=\"490.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">E</text>\n  <rect x=\"484\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"E\" data-prediction=\"H\" data-index=\"158\"/>\n  <text x=\"490.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <rect x=\"496\" y=\"166\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"159\"/>\n  <text x=\"502.0\" y=\"180\" class=\"residue\" text-anchor=\"middle\">K</text>\n  <rect x=\"496\" y=\"196\" width=\"12\" height=\"20\" fill=\"#FF6B6B\" opacity=\"0.7\" data-residue=\"K\" data-prediction=\"H\" data-index=\"159\"/>\n  <text x=\"502.0\" y=\"210\" class=\"residue\" text-anchor=\"middle\">H</text>\n  <text x=\"40\" y=\"280\" class=\"legend\">Legend:</text>\n  <rect x=\"100\" y=\"270\" width=\"15\" height=\"15\" fill=\"#95E1D3\" opacity=\"0.7\"/>\n  <text x=\"120\" y=\"280\" class=\"legend\">C</text>\n  <rect x=\"180\" y=\"270\" width=\"15\" height=\"15\" fill=\"#4ECDC4\" opacity=\"0.7\"/>\n  <text x=\"200\" y=\"280\" class=\"legend\">E</text>\n  <rect x=\"260\" y=\"270\" width=\"15\" height=\"15\" fill=\"#FF6B6B\" opacity=\"0.7\"/>\n  <text x=\"280\" y=\"280\" class=\"legend\">H</text>\n  <rect x=\"340\" y=\"270\" width=\"15\" height=\"15\" fill=\"#95E1D3\" opacity=\"0.7\"/>\n  <text x=\"360\" y=\"280\" class=\"legend\">L</text>\n</svg>",
      "metadata": {
        "type": "highlight",
        "sequence_length": 159,
        "prediction_label": "Secondary Structure",
        "color_scheme": {"H": "#FF6B6B", "E": "#4ECDC4", "C": "#95E1D3", "L": "#95E1D3"},
        "residues_per_line": 60,
        "prediction_distribution": {"C": 69, "H": 75, "E": 15},
        "points": [
          {
            "x": 46.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "M", "prediction": "C", "index": 1},
          },
          {
            "x": 46.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "M", "prediction": "C", "index": 1},
          },
          {
            "x": 58.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "C", "index": 2},
          },
          {
            "x": 58.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "C", "index": 2},
          },
          {
            "x": 70.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "T", "prediction": "C", "index": 3},
          },
          {
            "x": 70.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "T", "prediction": "C", "index": 3},
          },
          {
            "x": 82.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "C", "index": 4},
          },
          {
            "x": 82.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "C", "index": 4},
          },
          {
            "x": 94.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "Y", "prediction": "H", "index": 5},
          },
          {
            "x": 94.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "Y", "prediction": "H", "index": 5},
          },
          {
            "x": 106.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "H", "index": 6},
          },
          {
            "x": 106.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "H", "index": 6},
          },
          {
            "x": 118.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "H", "index": 7},
          },
          {
            "x": 118.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "H", "index": 7},
          },
          {
            "x": 130.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 8},
          },
          {
            "x": 130.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 8},
          },
          {
            "x": 142.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 9},
          },
          {
            "x": 142.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 9},
          },
          {
            "x": 154.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "H", "index": 10},
          },
          {
            "x": 154.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "H", "index": 10},
          },
          {
            "x": 166.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 11},
          },
          {
            "x": 166.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 11},
          },
          {
            "x": 178.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "H", "index": 12},
          },
          {
            "x": 178.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "H", "index": 12},
          },
          {
            "x": 190.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 13},
          },
          {
            "x": 190.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 13},
          },
          {
            "x": 202.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "F", "prediction": "H", "index": 14},
          },
          {
            "x": 202.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "F", "prediction": "H", "index": 14},
          },
          {
            "x": 214.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "H", "index": 15},
          },
          {
            "x": 214.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "H", "index": 15},
          },
          {
            "x": 226.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 16},
          },
          {
            "x": 226.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 16},
          },
          {
            "x": 238.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 17},
          },
          {
            "x": 238.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 17},
          },
          {
            "x": 250.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "H", "prediction": "C", "index": 18},
          },
          {
            "x": 250.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "H", "prediction": "C", "index": 18},
          },
          {
            "x": 262.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "F", "prediction": "C", "index": 19},
          },
          {
            "x": 262.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "F", "prediction": "C", "index": 19},
          },
          {
            "x": 274.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "C", "index": 20},
          },
          {
            "x": 274.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "C", "index": 20},
          },
          {
            "x": 286.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "E", "index": 21},
          },
          {
            "x": 286.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "E", "index": 21},
          },
          {
            "x": 298.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "E", "index": 22},
          },
          {
            "x": 298.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "E", "index": 22},
          },
          {
            "x": 310.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "E", "index": 23},
          },
          {
            "x": 310.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "E", "index": 23},
          },
          {
            "x": 322.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "E", "index": 24},
          },
          {
            "x": 322.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "E", "index": 24},
          },
          {
            "x": 334.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "E", "index": 25},
          },
          {
            "x": 334.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "E", "index": 25},
          },
          {
            "x": 346.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "C", "index": 26},
          },
          {
            "x": 346.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "C", "index": 26},
          },
          {
            "x": 358.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 27},
          },
          {
            "x": 358.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 27},
          },
          {
            "x": 370.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "C", "index": 28},
          },
          {
            "x": 370.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "C", "index": 28},
          },
          {
            "x": 382.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 29},
          },
          {
            "x": 382.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 29},
          },
          {
            "x": 394.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "C", "index": 30},
          },
          {
            "x": 394.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "C", "index": 30},
          },
          {
            "x": 406.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "C", "index": 31},
          },
          {
            "x": 406.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "C", "index": 31},
          },
          {
            "x": 418.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "C", "index": 32},
          },
          {
            "x": 418.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "C", "index": 32},
          },
          {
            "x": 430.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "C", "index": 33},
          },
          {
            "x": 430.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "C", "index": 33},
          },
          {
            "x": 442.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "C", "index": 34},
          },
          {
            "x": 442.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "C", "index": 34},
          },
          {
            "x": 454.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "P", "prediction": "C", "index": 35},
          },
          {
            "x": 454.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "P", "prediction": "C", "index": 35},
          },
          {
            "x": 466.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "C", "index": 36},
          },
          {
            "x": 466.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "C", "index": 36},
          },
          {
            "x": 478.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 37},
          },
          {
            "x": 478.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 37},
          },
          {
            "x": 490.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "C", "index": 38},
          },
          {
            "x": 490.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "C", "index": 38},
          },
          {
            "x": 502.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "C", "index": 39},
          },
          {
            "x": 502.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "C", "index": 39},
          },
          {
            "x": 514.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "C", "index": 40},
          },
          {
            "x": 514.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "C", "index": 40},
          },
          {
            "x": 526.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "C", "index": 41},
          },
          {
            "x": 526.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "C", "index": 41},
          },
          {
            "x": 538.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "D", "prediction": "H", "index": 42},
          },
          {
            "x": 538.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "D", "prediction": "H", "index": 42},
          },
          {
            "x": 550.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "H", "index": 43},
          },
          {
            "x": 550.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "H", "index": 43},
          },
          {
            "x": 562.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "T", "prediction": "H", "index": 44},
          },
          {
            "x": 562.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "T", "prediction": "H", "index": 44},
          },
          {
            "x": 574.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 45},
          },
          {
            "x": 574.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 45},
          },
          {
            "x": 586.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "D", "prediction": "H", "index": 46},
          },
          {
            "x": 586.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "D", "prediction": "H", "index": 46},
          },
          {
            "x": 598.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "N", "prediction": "H", "index": 47},
          },
          {
            "x": 598.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "N", "prediction": "H", "index": 47},
          },
          {
            "x": 610.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "H", "index": 48},
          },
          {
            "x": 610.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "H", "index": 48},
          },
          {
            "x": 622.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 49},
          },
          {
            "x": 622.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 49},
          },
          {
            "x": 634.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "H", "index": 50},
          },
          {
            "x": 634.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "H", "index": 50},
          },
          {
            "x": 646.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "H", "index": 51},
          },
          {
            "x": 646.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "H", "index": 51},
          },
          {
            "x": 658.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "H", "index": 52},
          },
          {
            "x": 658.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "H", "index": 52},
          },
          {
            "x": 670.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 53},
          },
          {
            "x": 670.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 53},
          },
          {
            "x": 682.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "M", "prediction": "C", "index": 54},
          },
          {
            "x": 682.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "M", "prediction": "C", "index": 54},
          },
          {
            "x": 694.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "C", "index": 55},
          },
          {
            "x": 694.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "C", "index": 55},
          },
          {
            "x": 706.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "T", "prediction": "C", "index": 56},
          },
          {
            "x": 706.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "T", "prediction": "C", "index": 56},
          },
          {
            "x": 718.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "C", "index": 57},
          },
          {
            "x": 718.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "C", "index": 57},
          },
          {
            "x": 730.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "Y", "prediction": "H", "index": 58},
          },
          {
            "x": 730.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "Y", "prediction": "H", "index": 58},
          },
          {
            "x": 742.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "H", "index": 59},
          },
          {
            "x": 742.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "H", "index": 59},
          },
          {
            "x": 754.0,
            "y": 56.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "H", "index": 60},
          },
          {
            "x": 754.0,
            "y": 86.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "H", "index": 60},
          },
          {
            "x": 46.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 61},
          },
          {
            "x": 46.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 61},
          },
          {
            "x": 58.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 62},
          },
          {
            "x": 58.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 62},
          },
          {
            "x": 70.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "H", "index": 63},
          },
          {
            "x": 70.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "H", "index": 63},
          },
          {
            "x": 82.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 64},
          },
          {
            "x": 82.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 64},
          },
          {
            "x": 94.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "H", "index": 65},
          },
          {
            "x": 94.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "H", "index": 65},
          },
          {
            "x": 106.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 66},
          },
          {
            "x": 106.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 66},
          },
          {
            "x": 118.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "F", "prediction": "H", "index": 67},
          },
          {
            "x": 118.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "F", "prediction": "H", "index": 67},
          },
          {
            "x": 130.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "H", "index": 68},
          },
          {
            "x": 130.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "H", "index": 68},
          },
          {
            "x": 142.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 69},
          },
          {
            "x": 142.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 69},
          },
          {
            "x": 154.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 70},
          },
          {
            "x": 154.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 70},
          },
          {
            "x": 166.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "H", "prediction": "C", "index": 71},
          },
          {
            "x": 166.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "H", "prediction": "C", "index": 71},
          },
          {
            "x": 178.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "F", "prediction": "C", "index": 72},
          },
          {
            "x": 178.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "F", "prediction": "C", "index": 72},
          },
          {
            "x": 190.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "C", "index": 73},
          },
          {
            "x": 190.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "C", "index": 73},
          },
          {
            "x": 202.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "E", "index": 74},
          },
          {
            "x": 202.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "E", "index": 74},
          },
          {
            "x": 214.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "E", "index": 75},
          },
          {
            "x": 214.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "E", "index": 75},
          },
          {
            "x": 226.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "E", "index": 76},
          },
          {
            "x": 226.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "E", "index": 76},
          },
          {
            "x": 238.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "E", "index": 77},
          },
          {
            "x": 238.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "E", "index": 77},
          },
          {
            "x": 250.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "E", "index": 78},
          },
          {
            "x": 250.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "E", "index": 78},
          },
          {
            "x": 262.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "C", "index": 79},
          },
          {
            "x": 262.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "C", "index": 79},
          },
          {
            "x": 274.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 80},
          },
          {
            "x": 274.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 80},
          },
          {
            "x": 286.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "C", "index": 81},
          },
          {
            "x": 286.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "C", "index": 81},
          },
          {
            "x": 298.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 82},
          },
          {
            "x": 298.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 82},
          },
          {
            "x": 310.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "C", "index": 83},
          },
          {
            "x": 310.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "C", "index": 83},
          },
          {
            "x": 322.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "C", "index": 84},
          },
          {
            "x": 322.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "C", "index": 84},
          },
          {
            "x": 334.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "C", "index": 85},
          },
          {
            "x": 334.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "C", "index": 85},
          },
          {
            "x": 346.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "C", "index": 86},
          },
          {
            "x": 346.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "C", "index": 86},
          },
          {
            "x": 358.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "C", "index": 87},
          },
          {
            "x": 358.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "C", "index": 87},
          },
          {
            "x": 370.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "P", "prediction": "C", "index": 88},
          },
          {
            "x": 370.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "P", "prediction": "C", "index": 88},
          },
          {
            "x": 382.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "C", "index": 89},
          },
          {
            "x": 382.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "C", "index": 89},
          },
          {
            "x": 394.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 90},
          },
          {
            "x": 394.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 90},
          },
          {
            "x": 406.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "C", "index": 91},
          },
          {
            "x": 406.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "C", "index": 91},
          },
          {
            "x": 418.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "C", "index": 92},
          },
          {
            "x": 418.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "C", "index": 92},
          },
          {
            "x": 430.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "C", "index": 93},
          },
          {
            "x": 430.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "C", "index": 93},
          },
          {
            "x": 442.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "C", "index": 94},
          },
          {
            "x": 442.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "C", "index": 94},
          },
          {
            "x": 454.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "D", "prediction": "H", "index": 95},
          },
          {
            "x": 454.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "D", "prediction": "H", "index": 95},
          },
          {
            "x": 466.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "H", "index": 96},
          },
          {
            "x": 466.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "H", "index": 96},
          },
          {
            "x": 478.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "T", "prediction": "H", "index": 97},
          },
          {
            "x": 478.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "T", "prediction": "H", "index": 97},
          },
          {
            "x": 490.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 98},
          },
          {
            "x": 490.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 98},
          },
          {
            "x": 502.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "D", "prediction": "H", "index": 99},
          },
          {
            "x": 502.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "D", "prediction": "H", "index": 99},
          },
          {
            "x": 514.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "N", "prediction": "H", "index": 100},
          },
          {
            "x": 514.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "N", "prediction": "H", "index": 100},
          },
          {
            "x": 526.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "H", "index": 101},
          },
          {
            "x": 526.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "H", "index": 101},
          },
          {
            "x": 538.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 102},
          },
          {
            "x": 538.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 102},
          },
          {
            "x": 550.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "H", "index": 103},
          },
          {
            "x": 550.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "H", "index": 103},
          },
          {
            "x": 562.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "H", "index": 104},
          },
          {
            "x": 562.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "H", "index": 104},
          },
          {
            "x": 574.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "H", "index": 105},
          },
          {
            "x": 574.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "H", "index": 105},
          },
          {
            "x": 586.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 106},
          },
          {
            "x": 586.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 106},
          },
          {
            "x": 598.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "M", "prediction": "C", "index": 107},
          },
          {
            "x": 598.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "M", "prediction": "C", "index": 107},
          },
          {
            "x": 610.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "C", "index": 108},
          },
          {
            "x": 610.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "C", "index": 108},
          },
          {
            "x": 622.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "T", "prediction": "C", "index": 109},
          },
          {
            "x": 622.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "T", "prediction": "C", "index": 109},
          },
          {
            "x": 634.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "C", "index": 110},
          },
          {
            "x": 634.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "C", "index": 110},
          },
          {
            "x": 646.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "Y", "prediction": "H", "index": 111},
          },
          {
            "x": 646.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "Y", "prediction": "H", "index": 111},
          },
          {
            "x": 658.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "H", "index": 112},
          },
          {
            "x": 658.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "H", "index": 112},
          },
          {
            "x": 670.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "H", "index": 113},
          },
          {
            "x": 670.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "H", "index": 113},
          },
          {
            "x": 682.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 114},
          },
          {
            "x": 682.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 114},
          },
          {
            "x": 694.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 115},
          },
          {
            "x": 694.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 115},
          },
          {
            "x": 706.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "H", "index": 116},
          },
          {
            "x": 706.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "H", "index": 116},
          },
          {
            "x": 718.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 117},
          },
          {
            "x": 718.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 117},
          },
          {
            "x": 730.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "H", "index": 118},
          },
          {
            "x": 730.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "H", "index": 118},
          },
          {
            "x": 742.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 119},
          },
          {
            "x": 742.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 119},
          },
          {
            "x": 754.0,
            "y": 116.0,
            "radius": 5.0,
            "data": {"residue": "F", "prediction": "H", "index": 120},
          },
          {
            "x": 754.0,
            "y": 146.0,
            "radius": 5.0,
            "data": {"residue": "F", "prediction": "H", "index": 120},
          },
          {
            "x": 46.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "H", "index": 121},
          },
          {
            "x": 46.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "H", "index": 121},
          },
          {
            "x": 58.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 122},
          },
          {
            "x": 58.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 122},
          },
          {
            "x": 70.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 123},
          },
          {
            "x": 70.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 123},
          },
          {
            "x": 82.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "H", "prediction": "C", "index": 124},
          },
          {
            "x": 82.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "H", "prediction": "C", "index": 124},
          },
          {
            "x": 94.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "F", "prediction": "C", "index": 125},
          },
          {
            "x": 94.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "F", "prediction": "C", "index": 125},
          },
          {
            "x": 106.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "C", "index": 126},
          },
          {
            "x": 106.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "C", "index": 126},
          },
          {
            "x": 118.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "E", "index": 127},
          },
          {
            "x": 118.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "E", "index": 127},
          },
          {
            "x": 130.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "E", "index": 128},
          },
          {
            "x": 130.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "E", "index": 128},
          },
          {
            "x": 142.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "E", "index": 129},
          },
          {
            "x": 142.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "E", "index": 129},
          },
          {
            "x": 154.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "E", "index": 130},
          },
          {
            "x": 154.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "E", "index": 130},
          },
          {
            "x": 166.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "E", "index": 131},
          },
          {
            "x": 166.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "E", "index": 131},
          },
          {
            "x": 178.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "C", "index": 132},
          },
          {
            "x": 178.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "C", "index": 132},
          },
          {
            "x": 190.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 133},
          },
          {
            "x": 190.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 133},
          },
          {
            "x": 202.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "C", "index": 134},
          },
          {
            "x": 202.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "C", "index": 134},
          },
          {
            "x": 214.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 135},
          },
          {
            "x": 214.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 135},
          },
          {
            "x": 226.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "C", "index": 136},
          },
          {
            "x": 226.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "C", "index": 136},
          },
          {
            "x": 238.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "C", "index": 137},
          },
          {
            "x": 238.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "C", "index": 137},
          },
          {
            "x": 250.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "C", "index": 138},
          },
          {
            "x": 250.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "C", "index": 138},
          },
          {
            "x": 262.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "C", "index": 139},
          },
          {
            "x": 262.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "C", "index": 139},
          },
          {
            "x": 274.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "C", "index": 140},
          },
          {
            "x": 274.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "C", "index": 140},
          },
          {
            "x": 286.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "P", "prediction": "C", "index": 141},
          },
          {
            "x": 286.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "P", "prediction": "C", "index": 141},
          },
          {
            "x": 298.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "C", "index": 142},
          },
          {
            "x": 298.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "I", "prediction": "C", "index": 142},
          },
          {
            "x": 310.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 143},
          },
          {
            "x": 310.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "C", "index": 143},
          },
          {
            "x": 322.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "C", "index": 144},
          },
          {
            "x": 322.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "C", "index": 144},
          },
          {
            "x": 334.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "C", "index": 145},
          },
          {
            "x": 334.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "R", "prediction": "C", "index": 145},
          },
          {
            "x": 346.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "C", "index": 146},
          },
          {
            "x": 346.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "V", "prediction": "C", "index": 146},
          },
          {
            "x": 358.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "C", "index": 147},
          },
          {
            "x": 358.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "C", "index": 147},
          },
          {
            "x": 370.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "D", "prediction": "H", "index": 148},
          },
          {
            "x": 370.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "D", "prediction": "H", "index": 148},
          },
          {
            "x": 382.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "H", "index": 149},
          },
          {
            "x": 382.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "H", "index": 149},
          },
          {
            "x": 394.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "T", "prediction": "H", "index": 150},
          },
          {
            "x": 394.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "T", "prediction": "H", "index": 150},
          },
          {
            "x": 406.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 151},
          },
          {
            "x": 406.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "Q", "prediction": "H", "index": 151},
          },
          {
            "x": 418.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "D", "prediction": "H", "index": 152},
          },
          {
            "x": 418.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "D", "prediction": "H", "index": 152},
          },
          {
            "x": 430.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "N", "prediction": "H", "index": 153},
          },
          {
            "x": 430.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "N", "prediction": "H", "index": 153},
          },
          {
            "x": 442.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "H", "index": 154},
          },
          {
            "x": 442.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "L", "prediction": "H", "index": 154},
          },
          {
            "x": 454.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 155},
          },
          {
            "x": 454.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "S", "prediction": "H", "index": 155},
          },
          {
            "x": 466.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "H", "index": 156},
          },
          {
            "x": 466.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "G", "prediction": "H", "index": 156},
          },
          {
            "x": 478.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "H", "index": 157},
          },
          {
            "x": 478.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "A", "prediction": "H", "index": 157},
          },
          {
            "x": 490.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "H", "index": 158},
          },
          {
            "x": 490.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "E", "prediction": "H", "index": 158},
          },
          {
            "x": 502.0,
            "y": 176.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 159},
          },
          {
            "x": 502.0,
            "y": 206.0,
            "radius": 5.0,
            "data": {"residue": "K", "prediction": "H", "index": 159},
          },
        ],
      },
    };
  }

  static Map<String, dynamic> labelDistribution() {
    return {
      "svg":
      "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" class=\"marks\" width=\"458\" height=\"435\" viewBox=\"0 0 458 435\"><rect width=\"458\" height=\"435\" fill=\"white\"/><g fill=\"none\" stroke-miterlimit=\"10\" transform=\"translate(53,27)\"><g class=\"mark-group role-frame root\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,0)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0.5,0.5h400v300h-400Z\" stroke=\"#ddd\"/><g><g class=\"mark-group role-axis\" aria-hidden=\"true\"><g transform=\"translate(0.5,0.5)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h0v0h0Z\" pointer-events=\"none\"/><g><g class=\"mark-rule role-axis-grid\" pointer-events=\"none\"><line transform=\"translate(0,300)\" x2=\"400\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,257)\" x2=\"400\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,214)\" x2=\"400\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,171)\" x2=\"400\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,129)\" x2=\"400\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,86)\" x2=\"400\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,43)\" x2=\"400\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,0)\" x2=\"400\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g><g class=\"mark-group role-axis\" role=\"graphics-symbol\" aria-roledescription=\"axis\" aria-label=\"X-axis titled 'Class Label' for a discrete scale with 10 values: Cell_membrane, Cytoplasm, Endoplasmic_reticulum, Extracellular, Golgi_apparatus, ending with Plastid\"><g transform=\"translate(0.5,300.5)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h0v0h0Z\" pointer-events=\"none\"/><g><g class=\"mark-rule role-axis-tick\" pointer-events=\"none\"><line transform=\"translate(20,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(60,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(100,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(140,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(180,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(220,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(260,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(300,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(340,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(380,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/></g><g class=\"mark-text role-axis-label\" pointer-events=\"none\"><text text-anchor=\"end\" transform=\"translate(19.5,7) rotate(315) translate(0,8)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">Cell_membrane</text><text text-anchor=\"end\" transform=\"translate(59.5,7) rotate(315) translate(0,8)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">Cytoplasm</text><text text-anchor=\"end\" transform=\"translate(99.5,7) rotate(315) translate(0,8)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">Endoplasmic_reticulum</text><text text-anchor=\"end\" transform=\"translate(139.5,7) rotate(315) translate(0,8)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">Extracellular</text><text text-anchor=\"end\" transform=\"translate(179.5,7) rotate(315) translate(0,8)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">Golgi_apparatus</text><text text-anchor=\"end\" transform=\"translate(219.5,7) rotate(315) translate(0,8)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">Lysosome/Vacuole</text><text text-anchor=\"end\" transform=\"translate(259.5,7) rotate(315) translate(0,8)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">Mitochondrion</text><text text-anchor=\"end\" transform=\"translate(299.5,7) rotate(315) translate(0,8)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">Nucleus</text><text text-anchor=\"end\" transform=\"translate(339.5,7) rotate(315) translate(0,8)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">Peroxisome</text><text text-anchor=\"end\" transform=\"translate(379.5,7) rotate(315) translate(0,8)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">Plastid</text></g><g class=\"mark-rule role-axis-domain\" pointer-events=\"none\"><line transform=\"translate(0,0)\" x2=\"400\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/></g><g class=\"mark-text role-axis-title\" pointer-events=\"none\"><text text-anchor=\"middle\" transform=\"translate(200,100.17099345288885)\" font-family=\"sans-serif\" font-size=\"11px\" font-weight=\"bold\" fill=\"#000\" opacity=\"1\">Class Label</text></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g><g class=\"mark-group role-axis\" role=\"graphics-symbol\" aria-roledescription=\"axis\" aria-label=\"Y-axis titled 'Number of Sequences' for a linear scale with values from 0 to 3,500\"><g transform=\"translate(0.5,0.5)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h0v0h0Z\" pointer-events=\"none\"/><g><g class=\"mark-rule role-axis-tick\" pointer-events=\"none\"><line transform=\"translate(0,300)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,257)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,214)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,171)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,129)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,86)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,43)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,0)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/></g><g class=\"mark-text role-axis-label\" pointer-events=\"none\"><text text-anchor=\"end\" transform=\"translate(-7,303)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">0</text><text text-anchor=\"end\" transform=\"translate(-7,260.14285714285717)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">500</text><text text-anchor=\"end\" transform=\"translate(-7,217.28571428571428)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">1,000</text><text text-anchor=\"end\" transform=\"translate(-7,174.42857142857142)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">1,500</text><text text-anchor=\"end\" transform=\"translate(-7,131.57142857142858)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">2,000</text><text text-anchor=\"end\" transform=\"translate(-7,88.71428571428571)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">2,500</text><text text-anchor=\"end\" transform=\"translate(-7,45.85714285714287)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">3,000</text><text text-anchor=\"end\" transform=\"translate(-7,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">3,500</text></g><g class=\"mark-rule role-axis-domain\" pointer-events=\"none\"><line transform=\"translate(0,300)\" x2=\"0\" y2=\"-300\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/></g><g class=\"mark-text role-axis-title\" pointer-events=\"none\"><text text-anchor=\"middle\" transform=\"translate(-36.0244140625,150) rotate(-90) translate(0,-2)\" font-family=\"sans-serif\" font-size=\"11px\" font-weight=\"bold\" fill=\"#000\" opacity=\"1\">Number of Sequences</text></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g><g class=\"mark-group role-scope\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(2,200.14285714285714)\"><path class=\"background\" aria-hidden=\"true\" d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,95.85714285714286C36,98.06480295511886,34.207660097976,99.85714285714286,32,99.85714285714286L4,99.85714285714286C1.792339902024,99.85714285714286,0,98.06480295511886,0,95.85714285714286L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/><g clip-path=\"url(#clip11)\"><g class=\"mark-group role-scope\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,-200.14285714285714)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h36v0h-36Z\"/><g><g class=\"mark-rect role-mark marks\" role=\"graphics-object\" aria-roledescription=\"rect mark container\"><path aria-label=\"Class Label: Cell_membrane; Number of Sequences: 1165; label: Cell_membrane; Label: Cell_membrane; Count: 1165; Percentage: 10.0\" role=\"graphics-symbol\" aria-roledescription=\"bar\" d=\"M0,200.14285714285714h36v99.85714285714286h-36Z\" fill=\"#4c78a8\" opacity=\"0.8\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g><g transform=\"translate(42,104.74285714285713)\"><path class=\"background\" aria-hidden=\"true\" d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,191.25714285714287C36,193.46480295511887,34.207660097976,195.25714285714287,32,195.25714285714287L4,195.25714285714287C1.792339902024,195.25714285714287,0,193.46480295511887,0,191.25714285714287L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/><g clip-path=\"url(#clip12)\"><g class=\"mark-group role-scope\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,-104.74285714285713)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h36v0h-36Z\"/><g><g class=\"mark-rect role-mark marks\" role=\"graphics-object\" aria-roledescription=\"rect mark container\"><path aria-label=\"Class Label: Cytoplasm; Number of Sequences: 2278; label: Cytoplasm; Label: Cytoplasm; Count: 2278; Percentage: 19.5\" role=\"graphics-symbol\" aria-roledescription=\"bar\" d=\"M0,104.74285714285713h36v195.25714285714287h-36Z\" fill=\"#f58518\" opacity=\"0.8\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g><g transform=\"translate(82,238.0285714285714)\"><path class=\"background\" aria-hidden=\"true\" d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,57.97142857142859C36,60.17908866940459,34.207660097976,61.97142857142859,32,61.97142857142859L4,61.97142857142859C1.792339902024,61.97142857142859,0,60.17908866940459,0,57.97142857142859L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/><g clip-path=\"url(#clip13)\"><g class=\"mark-group role-scope\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,-238.0285714285714)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h36v0h-36Z\"/><g><g class=\"mark-rect role-mark marks\" role=\"graphics-object\" aria-roledescription=\"rect mark container\"><path aria-label=\"Class Label: Endoplasmic_reticulum; Number of Sequences: 723; label: Endoplasmic_reticulum; Label: Endoplasmic_reticulum; Count: 723; Percentage: 6.2\" role=\"graphics-symbol\" aria-roledescription=\"bar\" d=\"M0,238.0285714285714h36v61.97142857142859h-36Z\" fill=\"#e45756\" opacity=\"0.8\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g><g transform=\"translate(162,274.37142857142857)\"><path class=\"background\" aria-hidden=\"true\" d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,21.628571428571433C36,23.836231526547433,34.207660097976,25.628571428571433,32,25.628571428571433L4,25.628571428571433C1.792339902024,25.628571428571433,0,23.836231526547433,0,21.628571428571433L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/><g clip-path=\"url(#clip14)\"><g class=\"mark-group role-scope\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,-274.37142857142857)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h36v0h-36Z\"/><g><g class=\"mark-rect role-mark marks\" role=\"graphics-object\" aria-roledescription=\"rect mark container\"><path aria-label=\"Class Label: Golgi_apparatus; Number of Sequences: 299; label: Golgi_apparatus; Label: Golgi_apparatus; Count: 299; Percentage: 2.6\" role=\"graphics-symbol\" aria-roledescription=\"bar\" d=\"M0,274.37142857142857h36v25.628571428571433h-36Z\" fill=\"#54a24b\" opacity=\"0.8\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g><g transform=\"translate(202,276.9428571428571)\"><path class=\"background\" aria-hidden=\"true\" d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,19.05714285714288C36,21.264802955118878,34.207660097976,23.05714285714288,32,23.05714285714288L4,23.05714285714288C1.792339902024,23.05714285714288,0,21.264802955118878,0,19.05714285714288L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/><g clip-path=\"url(#clip15)\"><g class=\"mark-group role-scope\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,-276.9428571428571)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h36v0h-36Z\"/><g><g class=\"mark-rect role-mark marks\" role=\"graphics-object\" aria-roledescription=\"rect mark container\"><path aria-label=\"Class Label: Lysosome/Vacuole; Number of Sequences: 269; label: Lysosome/Vacuole; Label: Lysosome/Vacuole; Count: 269; Percentage: 2.3\" role=\"graphics-symbol\" aria-roledescription=\"bar\" d=\"M0,276.9428571428571h36v23.05714285714288h-36Z\" fill=\"#eeca3b\" opacity=\"0.8\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g><g transform=\"translate(242,196.02857142857144)\"><path class=\"background\" aria-hidden=\"true\" d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,99.97142857142856C36,102.17908866940456,34.207660097976,103.97142857142856,32,103.97142857142856L4,103.97142857142856C1.792339902024,103.97142857142856,0,102.17908866940456,0,99.97142857142856L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/><g clip-path=\"url(#clip16)\"><g class=\"mark-group role-scope\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,-196.02857142857144)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h36v0h-36Z\"/><g><g class=\"mark-rect role-mark marks\" role=\"graphics-object\" aria-roledescription=\"rect mark container\"><path aria-label=\"Class Label: Mitochondrion; Number of Sequences: 1213; label: Mitochondrion; Label: Mitochondrion; Count: 1213; Percentage: 10.4\" role=\"graphics-symbol\" aria-roledescription=\"bar\" d=\"M0,196.02857142857144h36v103.97142857142856h-36Z\" fill=\"#b279a2\" opacity=\"0.8\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g><g transform=\"translate(282,14.828571428571413)\"><path class=\"background\" aria-hidden=\"true\" d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,281.1714285714286C36,283.37908866940455,34.207660097976,285.1714285714286,32,285.1714285714286L4,285.1714285714286C1.792339902024,285.1714285714286,0,283.37908866940455,0,281.1714285714286L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/><g clip-path=\"url(#clip17)\"><g class=\"mark-group role-scope\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,-14.828571428571413)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h36v0h-36Z\"/><g><g class=\"mark-rect role-mark marks\" role=\"graphics-object\" aria-roledescription=\"rect mark container\"><path aria-label=\"Class Label: Nucleus; Number of Sequences: 3327; label: Nucleus; Label: Nucleus; Count: 3327; Percentage: 28.5\" role=\"graphics-symbol\" aria-roledescription=\"bar\" d=\"M0,14.828571428571413h36v285.1714285714286h-36Z\" fill=\"#ff9da6\" opacity=\"0.8\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g><g transform=\"translate(322,289.1142857142857)\"><path class=\"background\" aria-hidden=\"true\" d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,6.8857142857143C36,9.0933743836903,34.207660097976,10.8857142857143,32,10.8857142857143L4,10.8857142857143C1.792339902024,10.8857142857143,0,9.0933743836903,0,6.8857142857143L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/><g clip-path=\"url(#clip18)\"><g class=\"mark-group role-scope\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,-289.1142857142857)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h36v0h-36Z\"/><g><g class=\"mark-rect role-mark marks\" role=\"graphics-object\" aria-roledescription=\"rect mark container\"><path aria-label=\"Class Label: Peroxisome; Number of Sequences: 127; label: Peroxisome; Label: Peroxisome; Count: 127; Percentage: 1.1\" role=\"graphics-symbol\" aria-roledescription=\"bar\" d=\"M0,289.1142857142857h36v10.8857142857143h-36Z\" fill=\"#9d755d\" opacity=\"0.8\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g><g transform=\"translate(362,247.45714285714286)\"><path class=\"background\" aria-hidden=\"true\" d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,48.542857142857144C36,50.75051724083315,34.207660097976,52.542857142857144,32,52.542857142857144L4,52.542857142857144C1.792339902024,52.542857142857144,0,50.75051724083315,0,48.542857142857144L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/><g clip-path=\"url(#clip19)\"><g class=\"mark-group role-scope\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,-247.45714285714286)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h36v0h-36Z\"/><g><g class=\"mark-rect role-mark marks\" role=\"graphics-object\" aria-roledescription=\"rect mark container\"><path aria-label=\"Class Label: Plastid; Number of Sequences: 613; label: Plastid; Label: Plastid; Count: 613; Percentage: 5.3\" role=\"graphics-symbol\" aria-roledescription=\"bar\" d=\"M0,247.45714285714286h36v52.542857142857144h-36Z\" fill=\"#bab0ac\" opacity=\"0.8\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g><g transform=\"translate(122,157.97142857142856)\"><path class=\"background\" aria-hidden=\"true\" d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,138.02857142857144C36,140.23623152654744,34.207660097976,142.02857142857144,32,142.02857142857144L4,142.02857142857144C1.792339902024,142.02857142857144,0,140.23623152654744,0,138.02857142857144L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/><g clip-path=\"url(#clip20)\"><g class=\"mark-group role-scope\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,-157.97142857142856)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h36v0h-36Z\"/><g><g class=\"mark-rect role-mark marks\" role=\"graphics-object\" aria-roledescription=\"rect mark container\"><path aria-label=\"Class Label: Extracellular; Number of Sequences: 1657; label: Extracellular; Label: Extracellular; Count: 1657; Percentage: 14.2\" role=\"graphics-symbol\" aria-roledescription=\"bar\" d=\"M0,157.97142857142856h36v142.02857142857144h-36Z\" fill=\"#72b7b2\" opacity=\"0.8\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g><g class=\"mark-group role-title\"><g transform=\"translate(200,-22)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h0v0h0Z\" pointer-events=\"none\"/><g><g class=\"mark-text role-title-text\" role=\"graphics-symbol\" aria-roledescription=\"title\" aria-label=\"Title text 'Label Distribution'\" pointer-events=\"none\"><text text-anchor=\"middle\" transform=\"translate(0,10)\" font-family=\"sans-serif\" font-size=\"13px\" font-weight=\"bold\" fill=\"#000\" opacity=\"1\">Label Distribution</text></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g></g><defs><clipPath id=\"clip11\"><path d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,95.85714285714286C36,98.06480295511886,34.207660097976,99.85714285714286,32,99.85714285714286L4,99.85714285714286C1.792339902024,99.85714285714286,0,98.06480295511886,0,95.85714285714286L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/></clipPath><clipPath id=\"clip12\"><path d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,191.25714285714287C36,193.46480295511887,34.207660097976,195.25714285714287,32,195.25714285714287L4,195.25714285714287C1.792339902024,195.25714285714287,0,193.46480295511887,0,191.25714285714287L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/></clipPath><clipPath id=\"clip13\"><path d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,57.97142857142859C36,60.17908866940459,34.207660097976,61.97142857142859,32,61.97142857142859L4,61.97142857142859C1.792339902024,61.97142857142859,0,60.17908866940459,0,57.97142857142859L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/></clipPath><clipPath id=\"clip14\"><path d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,21.628571428571433C36,23.836231526547433,34.207660097976,25.628571428571433,32,25.628571428571433L4,25.628571428571433C1.792339902024,25.628571428571433,0,23.836231526547433,0,21.628571428571433L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/></clipPath><clipPath id=\"clip15\"><path d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,19.05714285714288C36,21.264802955118878,34.207660097976,23.05714285714288,32,23.05714285714288L4,23.05714285714288C1.792339902024,23.05714285714288,0,21.264802955118878,0,19.05714285714288L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/></clipPath><clipPath id=\"clip16\"><path d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,99.97142857142856C36,102.17908866940456,34.207660097976,103.97142857142856,32,103.97142857142856L4,103.97142857142856C1.792339902024,103.97142857142856,0,102.17908866940456,0,99.97142857142856L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/></clipPath><clipPath id=\"clip17\"><path d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,281.1714285714286C36,283.37908866940455,34.207660097976,285.1714285714286,32,285.1714285714286L4,285.1714285714286C1.792339902024,285.1714285714286,0,283.37908866940455,0,281.1714285714286L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/></clipPath><clipPath id=\"clip18\"><path d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,6.8857142857143C36,9.0933743836903,34.207660097976,10.8857142857143,32,10.8857142857143L4,10.8857142857143C1.792339902024,10.8857142857143,0,9.0933743836903,0,6.8857142857143L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/></clipPath><clipPath id=\"clip19\"><path d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,48.542857142857144C36,50.75051724083315,34.207660097976,52.542857142857144,32,52.542857142857144L4,52.542857142857144C1.792339902024,52.542857142857144,0,50.75051724083315,0,48.542857142857144L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/></clipPath><clipPath id=\"clip20\"><path d=\"M4,0L32,0C34.207660097976,0,36,1.792339902024,36,4L36,138.02857142857144C36,140.23623152654744,34.207660097976,142.02857142857144,32,142.02857142857144L4,142.02857142857144C1.792339902024,142.02857142857144,0,140.23623152654744,0,138.02857142857144L0,4C0,1.792339902024,1.792339902024,0,4,0Z\"/></clipPath></defs></svg>",
      "metadata": {
        "dataset_len": 11671,
        "title": "Label Distribution",
        "x_label": "Class Label",
        "y_label": "Number of Sequences",
        "chart_type": "bar",
        "dimensions": {"width": 400.0, "height": 300.0, "margin_left": 60.0, "margin_top": 40.0},
        "points": [
          {
            "x": 18.0,
            "y": 250.07142857142856,
            "radius": 5.0,
            "data": {
              "Class Label": "Cell_membrane",
              "Number of Sequences": 1165,
              "label": "Cell_membrane",
              "Label": "Cell_membrane",
              "Count": 1165,
              "Percentage": 10.0,
            },
          },
          {
            "x": 18.0,
            "y": 202.37142857142857,
            "radius": 5.0,
            "data": {
              "Class Label": "Cytoplasm",
              "Number of Sequences": 2278,
              "label": "Cytoplasm",
              "Label": "Cytoplasm",
              "Count": 2278,
              "Percentage": 19.5,
            },
          },
          {
            "x": 18.0,
            "y": 269.01428571428573,
            "radius": 5.0,
            "data": {
              "Class Label": "Endoplasmic_reticulum",
              "Number of Sequences": 723,
              "label": "Endoplasmic_reticulum",
              "Label": "Endoplasmic_reticulum",
              "Count": 723,
              "Percentage": 6.2,
            },
          },
          {
            "x": 18.0,
            "y": 287.1857142857143,
            "radius": 5.0,
            "data": {
              "Class Label": "Golgi_apparatus",
              "Number of Sequences": 299,
              "label": "Golgi_apparatus",
              "Label": "Golgi_apparatus",
              "Count": 299,
              "Percentage": 2.6,
            },
          },
          {
            "x": 18.0,
            "y": 288.47142857142853,
            "radius": 5.0,
            "data": {
              "Class Label": "Lysosome/Vacuole",
              "Number of Sequences": 269,
              "label": "Lysosome/Vacuole",
              "Label": "Lysosome/Vacuole",
              "Count": 269,
              "Percentage": 2.3,
            },
          },
          {
            "x": 18.0,
            "y": 248.01428571428573,
            "radius": 5.0,
            "data": {
              "Class Label": "Mitochondrion",
              "Number of Sequences": 1213,
              "label": "Mitochondrion",
              "Label": "Mitochondrion",
              "Count": 1213,
              "Percentage": 10.4,
            },
          },
          {
            "x": 18.0,
            "y": 157.4142857142857,
            "radius": 5.0,
            "data": {
              "Class Label": "Nucleus",
              "Number of Sequences": 3327,
              "label": "Nucleus",
              "Label": "Nucleus",
              "Count": 3327,
              "Percentage": 28.5,
            },
          },
          {
            "x": 18.0,
            "y": 294.5571428571428,
            "radius": 5.0,
            "data": {
              "Class Label": "Peroxisome",
              "Number of Sequences": 127,
              "label": "Peroxisome",
              "Label": "Peroxisome",
              "Count": 127,
              "Percentage": 1.1,
            },
          },
          {
            "x": 18.0,
            "y": 273.7285714285714,
            "radius": 5.0,
            "data": {
              "Class Label": "Plastid",
              "Number of Sequences": 613,
              "label": "Plastid",
              "Label": "Plastid",
              "Count": 613,
              "Percentage": 5.3,
            },
          },
          {
            "x": 18.0,
            "y": 228.98571428571427,
            "radius": 5.0,
            "data": {
              "Class Label": "Extracellular",
              "Number of Sequences": 1657,
              "label": "Extracellular",
              "Label": "Extracellular",
              "Count": 1657,
              "Percentage": 14.2,
            },
          },
        ],
      },
    };
  }

  static Map<String, dynamic> lossCurves() {
    return {
      "svg":
      "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" class=\"marks\" width=\"1124\" height=\"344\" viewBox=\"0 0 1124 344\"><rect width=\"1124\" height=\"344\" fill=\"white\"/><g fill=\"none\" stroke-miterlimit=\"10\" transform=\"translate(41,5)\"><g class=\"mark-group role-frame root\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,0)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0.5,0.5h1000v300h-1000Z\" stroke=\"#ddd\"/><g><g class=\"mark-group role-axis\" aria-hidden=\"true\"><g transform=\"translate(0.5,0.5)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h0v0h0Z\" pointer-events=\"none\"/><g><g class=\"mark-rule role-axis-grid\" pointer-events=\"none\"><line transform=\"translate(0,300)\" x2=\"1000\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,242)\" x2=\"1000\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,185)\" x2=\"1000\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,127)\" x2=\"1000\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,69)\" x2=\"1000\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,12)\" x2=\"1000\" y2=\"0\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g><g class=\"mark-group role-axis\" role=\"graphics-symbol\" aria-roledescription=\"axis\" aria-label=\"X-axis titled 'Epoch' for a discrete scale with 50 values: 0, 1, 2, 3, 4, ending with 49\"><g transform=\"translate(0.5,300.5)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h0v0h0Z\" pointer-events=\"none\"/><g><g class=\"mark-rule role-axis-tick\" pointer-events=\"none\"><line transform=\"translate(10,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(30,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(50,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(70,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(90,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(110,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(130,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(150,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(170,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(190,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(210,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(230,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(250,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(270,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(290,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(310,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(330,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(350,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(370,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(390,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(410,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(430,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(450,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(470,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(490,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(510,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(530,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(550,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(570,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(590,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(610,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(630,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(650,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(670,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(690,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(710,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(730,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(750,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(770,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(790,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(810,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(830,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(850,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(870,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(890,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(910,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(930,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(950,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(970,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(990,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/></g><g class=\"mark-text role-axis-label\" pointer-events=\"none\"><text text-anchor=\"end\" transform=\"translate(10,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">0</text><text text-anchor=\"end\" transform=\"translate(30,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">1</text><text text-anchor=\"end\" transform=\"translate(50,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">2</text><text text-anchor=\"end\" transform=\"translate(70,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">3</text><text text-anchor=\"end\" transform=\"translate(90,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">4</text><text text-anchor=\"end\" transform=\"translate(110,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">5</text><text text-anchor=\"end\" transform=\"translate(130,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">6</text><text text-anchor=\"end\" transform=\"translate(150,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">7</text><text text-anchor=\"end\" transform=\"translate(170,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">8</text><text text-anchor=\"end\" transform=\"translate(190,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">9</text><text text-anchor=\"end\" transform=\"translate(210,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">10</text><text text-anchor=\"end\" transform=\"translate(230,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">11</text><text text-anchor=\"end\" transform=\"translate(250,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">12</text><text text-anchor=\"end\" transform=\"translate(270,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">13</text><text text-anchor=\"end\" transform=\"translate(290,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">14</text><text text-anchor=\"end\" transform=\"translate(310,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">15</text><text text-anchor=\"end\" transform=\"translate(330,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">16</text><text text-anchor=\"end\" transform=\"translate(350,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">17</text><text text-anchor=\"end\" transform=\"translate(370,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">18</text><text text-anchor=\"end\" transform=\"translate(390,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">19</text><text text-anchor=\"end\" transform=\"translate(410,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">20</text><text text-anchor=\"end\" transform=\"translate(430,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">21</text><text text-anchor=\"end\" transform=\"translate(450,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">22</text><text text-anchor=\"end\" transform=\"translate(470,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">23</text><text text-anchor=\"end\" transform=\"translate(490,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">24</text><text text-anchor=\"end\" transform=\"translate(510,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">25</text><text text-anchor=\"end\" transform=\"translate(530,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">26</text><text text-anchor=\"end\" transform=\"translate(550,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">27</text><text text-anchor=\"end\" transform=\"translate(570,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">28</text><text text-anchor=\"end\" transform=\"translate(590,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">29</text><text text-anchor=\"end\" transform=\"translate(610,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">30</text><text text-anchor=\"end\" transform=\"translate(630,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">31</text><text text-anchor=\"end\" transform=\"translate(650,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">32</text><text text-anchor=\"end\" transform=\"translate(670,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">33</text><text text-anchor=\"end\" transform=\"translate(690,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">34</text><text text-anchor=\"end\" transform=\"translate(710,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">35</text><text text-anchor=\"end\" transform=\"translate(730,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">36</text><text text-anchor=\"end\" transform=\"translate(750,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">37</text><text text-anchor=\"end\" transform=\"translate(770,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">38</text><text text-anchor=\"end\" transform=\"translate(790,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">39</text><text text-anchor=\"end\" transform=\"translate(810,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">40</text><text text-anchor=\"end\" transform=\"translate(830,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">41</text><text text-anchor=\"end\" transform=\"translate(850,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">42</text><text text-anchor=\"end\" transform=\"translate(870,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">43</text><text text-anchor=\"end\" transform=\"translate(890,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">44</text><text text-anchor=\"end\" transform=\"translate(910,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">45</text><text text-anchor=\"end\" transform=\"translate(930,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">46</text><text text-anchor=\"end\" transform=\"translate(950,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">47</text><text text-anchor=\"end\" transform=\"translate(970,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">48</text><text text-anchor=\"end\" transform=\"translate(990,7) rotate(270) translate(0,3)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">49</text></g><g class=\"mark-rule role-axis-domain\" pointer-events=\"none\"><line transform=\"translate(0,0)\" x2=\"1000\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/></g><g class=\"mark-text role-axis-title\" pointer-events=\"none\"><text text-anchor=\"middle\" transform=\"translate(500,31.123046875)\" font-family=\"sans-serif\" font-size=\"11px\" font-weight=\"bold\" fill=\"#000\" opacity=\"1\">Epoch</text></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g><g class=\"mark-group role-axis\" role=\"graphics-symbol\" aria-roledescription=\"axis\" aria-label=\"Y-axis titled 'Loss' for a linear scale with values from 0.0 to 2.6\"><g transform=\"translate(0.5,0.5)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h0v0h0Z\" pointer-events=\"none\"/><g><g class=\"mark-rule role-axis-tick\" pointer-events=\"none\"><line transform=\"translate(0,300)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,242)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,185)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,127)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,69)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(0,12)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/></g><g class=\"mark-text role-axis-label\" pointer-events=\"none\"><text text-anchor=\"end\" transform=\"translate(-7,303)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">0.0</text><text text-anchor=\"end\" transform=\"translate(-7,245.30769230769232)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">0.5</text><text text-anchor=\"end\" transform=\"translate(-7,187.6153846153846)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">1.0</text><text text-anchor=\"end\" transform=\"translate(-7,129.92307692307693)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">1.5</text><text text-anchor=\"end\" transform=\"translate(-7,72.23076923076925)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">2.0</text><text text-anchor=\"end\" transform=\"translate(-7,14.538461538461565)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">2.5</text></g><g class=\"mark-rule role-axis-domain\" pointer-events=\"none\"><line transform=\"translate(0,300)\" x2=\"0\" y2=\"-300\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/></g><g class=\"mark-text role-axis-title\" pointer-events=\"none\"><text text-anchor=\"middle\" transform=\"translate(-24.9013671875,150) rotate(-90) translate(0,-2)\" font-family=\"sans-serif\" font-size=\"11px\" font-weight=\"bold\" fill=\"#000\" opacity=\"1\">Loss</text></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g><g class=\"mark-group role-scope pathgroup\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,0)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h1000v300h-1000Z\"/><g><g class=\"mark-line role-mark marks\" role=\"graphics-object\" aria-roledescription=\"line mark container\"><path aria-label=\"Epoch: 0; Loss: 2.16490689754; Loss Type: Training; Type: Training\" role=\"graphics-symbol\" aria-roledescription=\"line mark\" d=\"M10,50.203L30,91.387L50,109.307L70,116.205L90,119.179L110,122.344L130,124.337L150,126.377L170,127.796L190,128.481L210,130.131L230,130.305L250,131.657L270,132.162L290,131.523L310,131.888L330,132.81L350,133.415L370,134.049L390,133.369L410,133.863L430,133.631L450,135.018L470,134.714L490,134.604L510,135.395L530,135.24L550,135.835L570,135.755L590,136.229L610,136.053L630,136.438L650,137.031L670,136.019L690,135.471L710,136.387L730,137.566L750,136.718L770,136.701L790,136.743L810,136.849L830,136.798L850,137.133L870,137.838L890,137.714L910,138.057L930,138.247L950,138.677L970,138.208L990,138.031\" stroke=\"#4c78a8\" stroke-width=\"2\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g><g transform=\"translate(0,0)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h1000v300h-1000Z\"/><g><g class=\"mark-line role-mark marks\" role=\"graphics-object\" aria-roledescription=\"line mark container\"><path aria-label=\"Epoch: 0; Loss: 2.41470202378; Loss Type: Validation; Type: Validation\" role=\"graphics-symbol\" aria-roledescription=\"line mark\" d=\"M10,21.381L30,73.307L50,99.147L70,105.781L90,111.989L110,116.704L130,117.277L150,117.348L170,120.658L190,120.467L210,125.363L230,120.926L250,122.441L270,122.304L290,121.462L310,125.284L330,128.398L350,125.667L370,122.7L390,126.497L410,125.457L430,128.628L450,131.544L470,129.935L490,131.3L510,129.989L530,132.29L550,129.923L570,132.409L590,129.965L610,128.524L630,129.881L650,125.787L670,128.001L690,129.889L710,127.689L730,132.854L750,129.297L770,130.692L790,125.413L810,132.674L830,132.314L850,131.822L870,131.145L890,131.047L910,133.624L930,133.652L950,130.238L970,128.978L990,138.229\" stroke=\"#f58518\" stroke-width=\"2\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g><g class=\"mark-group role-legend\" role=\"graphics-symbol\" aria-roledescription=\"legend\" aria-label=\"Symbol legend titled 'Loss Type' for stroke color with 2 values: Training, Validation\"><g transform=\"translate(1018,0)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h60v40h-60Z\" pointer-events=\"none\"/><g><g class=\"mark-group role-legend-entry\"><g transform=\"translate(0,16)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h0v0h0Z\" pointer-events=\"none\"/><g><g class=\"mark-group role-scope\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,0)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h59.1787109375v11h-59.1787109375Z\" pointer-events=\"none\" opacity=\"1\"/><g><g class=\"mark-symbol role-legend-symbol\" pointer-events=\"none\"><path transform=\"translate(6,6)\" d=\"M-5,0L5,0\" stroke=\"#4c78a8\" stroke-width=\"1.5\" opacity=\"1\"/></g><g class=\"mark-text role-legend-label\" pointer-events=\"none\"><text text-anchor=\"start\" transform=\"translate(16,9)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">Training</text></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g><g transform=\"translate(0,13)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h59.1787109375v11h-59.1787109375Z\" pointer-events=\"none\" opacity=\"1\"/><g><g class=\"mark-symbol role-legend-symbol\" pointer-events=\"none\"><path transform=\"translate(6,6)\" d=\"M-5,0L5,0\" stroke=\"#f58518\" stroke-width=\"1.5\" opacity=\"1\"/></g><g class=\"mark-text role-legend-label\" pointer-events=\"none\"><text text-anchor=\"start\" transform=\"translate(16,9)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">Validation</text></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g><g class=\"mark-text role-legend-title\" pointer-events=\"none\"><text text-anchor=\"start\" transform=\"translate(0,9)\" font-family=\"sans-serif\" font-size=\"11px\" font-weight=\"bold\" fill=\"#000\" opacity=\"1\">Loss Type</text></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g></g></svg>",
      "metadata": {
        "cv_split": "hold_out",
        "title": "Chart",
        "x_label": "Epoch",
        "y_label": "Loss",
        "chart_type": "line",
        "dimensions": {"width": 400.0, "height": 300.0, "margin_left": 60.0, "margin_top": 40.0},
        "points": [
          {
            "x": 10.0,
            "y": 50.203,
            "radius": 5.0,
            "data": {"Epoch": 0, "Loss": 2.16490689754, "Loss Type": "Training", "Type": "Training"},
          },
          {
            "x": 10.0,
            "y": 21.381,
            "radius": 5.0,
            "data": {"Epoch": 0, "Loss": 2.41470202378, "Loss Type": "Validation", "Type": "Validation"},
          },
        ],
      },
    };
  }

  static Map<String, dynamic> testSetPerformance() {
    return {
      "svg": "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" class=\"marks\" width=\"350\" height=\"90\" viewBox=\"0 0 350 90\"><rect width=\"350\" height=\"90\" fill=\"white\"/><g fill=\"none\" stroke-miterlimit=\"10\" transform=\"translate(44,33)\"><g class=\"mark-group role-frame root\" role=\"graphics-object\" aria-roledescription=\"group mark container\"><g transform=\"translate(0,0)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0.5,0.5h300v20h-300Z\" stroke=\"#ddd\"/><g><g class=\"mark-group role-axis\" aria-hidden=\"true\"><g transform=\"translate(0.5,20.5)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h0v0h0Z\" pointer-events=\"none\"/><g><g class=\"mark-rule role-axis-grid\" pointer-events=\"none\"><line transform=\"translate(0,0)\" x2=\"0\" y2=\"-20\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(38,0)\" x2=\"0\" y2=\"-20\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(75,0)\" x2=\"0\" y2=\"-20\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(112,0)\" x2=\"0\" y2=\"-20\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(150,0)\" x2=\"0\" y2=\"-20\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(188,0)\" x2=\"0\" y2=\"-20\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(225,0)\" x2=\"0\" y2=\"-20\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(262,0)\" x2=\"0\" y2=\"-20\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(300,0)\" x2=\"0\" y2=\"-20\" stroke=\"#ddd\" stroke-width=\"1\" opacity=\"1\"/></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g><g class=\"mark-group role-axis\" role=\"graphics-symbol\" aria-roledescription=\"axis\" aria-label=\"X-axis titled 'Mean accuracy' for a linear scale with values from 0.0 to 0.4\"><g transform=\"translate(0.5,20.5)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h0v0h0Z\" pointer-events=\"none\"/><g><g class=\"mark-rule role-axis-tick\" pointer-events=\"none\"><line transform=\"translate(0,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(38,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(75,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(112,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(150,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(188,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(225,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(262,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/><line transform=\"translate(300,0)\" x2=\"0\" y2=\"5\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/></g><g class=\"mark-text role-axis-label\" pointer-events=\"none\"><text text-anchor=\"start\" transform=\"translate(0,15)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">0.00</text><text text-anchor=\"middle\" transform=\"translate(37.5,15)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">0.05</text><text text-anchor=\"middle\" transform=\"translate(75,15)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">0.10</text><text text-anchor=\"middle\" transform=\"translate(112.49999999999999,15)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">0.15</text><text text-anchor=\"middle\" transform=\"translate(150,15)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">0.20</text><text text-anchor=\"middle\" transform=\"translate(187.5,15)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">0.25</text><text text-anchor=\"middle\" transform=\"translate(224.99999999999997,15)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">0.30</text><text text-anchor=\"middle\" transform=\"translate(262.49999999999994,15)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">0.35</text><text text-anchor=\"end\" transform=\"translate(300,15)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">0.40</text></g><g class=\"mark-rule role-axis-domain\" pointer-events=\"none\"><line transform=\"translate(0,0)\" x2=\"300\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/></g><g class=\"mark-text role-axis-title\" pointer-events=\"none\"><text text-anchor=\"middle\" transform=\"translate(150,30)\" font-family=\"sans-serif\" font-size=\"11px\" font-weight=\"bold\" fill=\"#000\" opacity=\"1\">Mean accuracy</text></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g><g class=\"mark-group role-axis\" role=\"graphics-symbol\" aria-roledescription=\"axis\" aria-label=\"Y-axis titled 'Test Set' for a discrete scale with 1 value: test\"><g transform=\"translate(0.5,0.5)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h0v0h0Z\" pointer-events=\"none\"/><g><g class=\"mark-rule role-axis-tick\" pointer-events=\"none\"><line transform=\"translate(0,10)\" x2=\"-5\" y2=\"0\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/></g><g class=\"mark-text role-axis-label\" pointer-events=\"none\"><text text-anchor=\"end\" transform=\"translate(-7,12.5)\" font-family=\"sans-serif\" font-size=\"10px\" fill=\"#000\" opacity=\"1\">test</text></g><g class=\"mark-rule role-axis-domain\" pointer-events=\"none\"><line transform=\"translate(0,0)\" x2=\"0\" y2=\"20\" stroke=\"#888\" stroke-width=\"1\" opacity=\"1\"/></g><g class=\"mark-text role-axis-title\" pointer-events=\"none\"><text text-anchor=\"middle\" transform=\"translate(-27.1181640625,10) rotate(-90) translate(0,-2)\" font-family=\"sans-serif\" font-size=\"11px\" font-weight=\"bold\" fill=\"#000\" opacity=\"1\">Test Set</text></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g><g class=\"mark-rect role-mark marks\" role=\"graphics-object\" aria-roledescription=\"rect mark container\"><path aria-label=\"Mean accuracy: 0.351611316204; Test Set: test; test_set_name: test; Metric: accuracy; Mean: 0.3516; Lower CI: 0.3120; Upper CI: 0.3985; Sample Size: 490; Bootstrap Iterations: 30\" role=\"graphics-symbol\" aria-roledescription=\"bar\" d=\"M0,1h263.7084871530533v18h-263.7084871530533Z\" fill=\"#4c78a8\"/></g><g class=\"mark-group role-title\"><g transform=\"translate(150,-27.987548828125)\"><path class=\"background\" aria-hidden=\"true\" d=\"M0,0h0v0h0Z\" pointer-events=\"none\"/><g><g class=\"mark-text role-title-text\" role=\"graphics-symbol\" aria-roledescription=\"title\" aria-label=\"Title text 'Test Set Performance for accuracy'\" pointer-events=\"none\"><text text-anchor=\"middle\" transform=\"translate(0,10)\" font-family=\"sans-serif\" font-size=\"13px\" font-weight=\"bold\" fill=\"#000\" opacity=\"1\">Test Set Performance for accuracy</text></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" pointer-events=\"none\" display=\"none\"/></g></g></g><path class=\"foreground\" aria-hidden=\"true\" d=\"\" display=\"none\"/></g></g></g></svg>",
      "metadata": {
        "metric_name": "accuracy",
        "title": "Test Set Performance for accuracy",
        "x_label": "Mean accuracy",
        "y_label": "Test Set",
        "chart_type": "bar",
        "dimensions": {
          "width": 400.0,
          "height": 300.0,
          "margin_left": 60.0,
          "margin_top": 40.0
        },
        "points": [
          {
            "x": 131.85424357652664,
            "y": 10.0,
            "radius": 5.0,
            "data": {
              "Mean accuracy": 0.351611316204,
              "Test Set": "test",
              "test_set_name": "test",
              "Metric": "accuracy",
              "Mean": 0.3516,
              "Lower CI": 0.312,
              "Upper CI": 0.3985,
              "Sample Size": 490,
              "Bootstrap Iterations": 30
            }
          }
        ]
      }
    };
  }
}
