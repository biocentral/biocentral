import 'dart:math' as math;

import 'package:biocentral/sdk/util/constants.dart';
import 'package:flutter/material.dart';

class BiocentralBarPlot extends StatelessWidget {
  final List<(String, double)> data;
  final String xAxisLabel;
  final String yAxisLabel;

  const BiocentralBarPlot({
    required this.data, super.key,
    this.xAxisLabel = '',
    this.yAxisLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _BarPlotPainter(data, xAxisLabel, yAxisLabel),
        );
      },
    );
  }
}

class _BarPlotPainter extends CustomPainter {
  final List<(String, double)> data;
  final String xAxisLabel;
  final String yAxisLabel;
  final TextStyle plotTextStyle = const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);

  _BarPlotPainter(this.data, this.xAxisLabel, this.yAxisLabel);

  @override
  void paint(Canvas canvas, Size size) {
    const double padding = 60;
    final Size plotSize = Size(size.width - padding * 2, size.height - padding * 2);
    final Offset plotOffset = const Offset(padding, padding);

    // Sort data by value in descending order
    data.sort((a, b) => b.$2.compareTo(a.$2));

    // Calculate max Y value
    final double maxY = data.map((item) => item.$2).reduce(math.max);

    // Draw bars
    final double barWidth = plotSize.width / data.length;
    for (int i = 0; i < data.length; i++) {
      final double barHeight = (data[i].$2 / maxY) * plotSize.height;
      final Rect rect = Rect.fromLTWH(
        plotOffset.dx + i * barWidth,
        plotOffset.dy + plotSize.height - barHeight,
        barWidth * 0.8, // Leave some space between bars
        barHeight,
      );
      canvas.drawRect(rect, Paint()..color = Colors.blue);
    }

    // Draw axes
    final Paint axesPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
        Offset(padding, size.height - padding), Offset(size.width - padding, size.height - padding), axesPaint,);
    canvas.drawLine(const Offset(padding, padding), Offset(padding, size.height - padding), axesPaint);

    // Draw x-axis labels
    for (int i = 0; i < data.length; i++) {
      String label = data[i].$1;
      if(label.length > 8) {
        label = '${label.substring(0, 6)}..';
      }
      final textPainter = TextPainter(
        text: TextSpan(
            text: label, style: plotTextStyle,),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      canvas.save();
      // Translate to the position where we want to draw the label
      canvas.translate(plotOffset.dx + (i + 0.5) * barWidth, size.height - padding + 5);
      // Rotate canvas by 45 degrees
      canvas.rotate(math.pi / 4);
      // Draw the text
      textPainter.paint(canvas, const Offset(0, 0));
      canvas.restore();
    }

    // Draw y-axis labels
    final int yTickCount = 5;
    for (int i = 0; i <= yTickCount; i++) {
      final double y = plotOffset.dy + plotSize.height * (1 - i / yTickCount);
      final double labelValue = maxY * (i / yTickCount);
      canvas.drawLine(Offset(padding - 5, y), Offset(padding, y), axesPaint);

      final textPainter = TextPainter(
        text: TextSpan(
            text: labelValue.toStringAsFixed(Constants.maxDoublePrecision),
            style: plotTextStyle,),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(padding - 10 - textPainter.width, y - textPainter.height / 2));
    }

    // Add axis labels
    final xLabelPainter = TextPainter(
      text: TextSpan(text: xAxisLabel, style: plotTextStyle),
      textDirection: TextDirection.ltr,
    );
    xLabelPainter.layout();
    xLabelPainter.paint(canvas, Offset(size.width - padding , size.height - padding));

    final yLabelPainter = TextPainter(
      text: TextSpan(text: yAxisLabel, style: plotTextStyle),
      textDirection: TextDirection.ltr,
    );
    yLabelPainter.layout();
    canvas.save();
    canvas.translate(0, size.height / 2 + yLabelPainter.width / 2);
    canvas.rotate(-math.pi / 2);
    yLabelPainter.paint(canvas, const Offset(0, -padding/4));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
