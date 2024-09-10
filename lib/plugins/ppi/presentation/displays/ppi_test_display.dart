import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../model/ppi_database_test.dart';

class PPITestDisplay extends StatefulWidget {
  final PPIDatabaseTest test;

  const PPITestDisplay({super.key, required this.test});

  @override
  State<PPITestDisplay> createState() => _PPITestDisplayState();
}

class _PPITestDisplayState extends State<PPITestDisplay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.test.testResult == null) {
      return Container();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 6.0, right: 6.0, bottom: 6.0),
        child: ExpansionTile(
          leading: buildLeadingIcon(),
          title: Text(widget.test.name),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Type: ${widget.test.type.name}"),
                Text("Requirement(s): ${widget.test.requirements.toString()}")
              ],
            ),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            buildMarkdownFromTestInformation(),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            buildMetricsDisplay(),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            buildTestStatisticDisplay(),
          ],
        ),
      ),
    );
  }

  Widget buildMarkdownFromTestInformation() {
    if (widget.test.testResult == null) {
      return Container();
    }
    List<String> splitsByLinebreak =
        widget.test.testResult!.information.split("\n").where((split) => split != "" && split != "\n").toList();
    return Column(children: splitsByLinebreak.map((split) => MarkdownBody(data: split)).toList());
  }

  Widget buildLeadingIcon() {
    Color color = Theme.of(context).primaryColor;
    IconData iconData = Icons.check_circle;
    if (widget.test.type == PPIDatabaseTestType.binary) {
      if (widget.test.testResult!.success!) {
        color = Colors.green;
      } else {
        color = Colors.red;
        iconData = Icons.not_interested;
      }
    }
    return Icon(iconData, color: color);
  }

  Widget buildTestStatisticDisplay() {
    BiocentralTestResult testResult = widget.test.testResult!;
    if (testResult.testStatistic == null) {
      return Container();
    }
    return Text(testResult.testStatistic.toString());
  }

  Widget buildMetricsDisplay() {
    if (widget.test.type == PPIDatabaseTestType.binary) {
      return Container();
    }
    BiocentralTestResult testResult = widget.test.testResult!;
    if (testResult.testMetrics == null) {
      return Container();
    }
    return Text(testResult.testMetrics.toString());
  }
}
