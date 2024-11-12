import 'dart:math' as math;

import 'package:flutter/material.dart';

class BiocentralHistogramKDEPlot extends StatelessWidget {
  final List<double> data;
  final int bins;
  final double bandwidth;

  const BiocentralHistogramKDEPlot({
    Key? key,
    required this.data,
    this.bins = 20,
    this.bandwidth = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _HistogramKDEPainter(data, bins, bandwidth),
        );
      },
    );
  }
}

class _HistogramKDEPainter extends CustomPainter {
  final List<double> data;
  final int bins;
  final double bandwidth;
  final TextStyle plotTextStyle = TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);

  _HistogramKDEPainter(this.data, this.bins, this.bandwidth);

  @override
  void paint(Canvas canvas, Size size) {
    const double padding = 60;

    final Size plotSize = Size(size.width - padding, size.height - padding);
    final Offset plotOffset = Offset(padding, 0);

    // Calculate metrics
    final double minValue = data.reduce(math.min);
    final double maxValue = data.reduce(math.max);
    final double mean = data.reduce((a, b) => a + b) / data.length;
    final double variance = data.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / (data.length - 1);
    final double stdDev = math.sqrt(variance);

    // Compute histogram
    final double range = maxValue - minValue;
    final double binWidth = range / bins;
    final List<int> histogram = List<int>.filled(bins, 0);
    for (final value in data) {
      final int binIndex = ((value - minValue) / binWidth).floor();
      if (binIndex >= 0 && binIndex < bins) {
        histogram[binIndex]++;
      }
    }

    // Normalize histogram
    final int maxCount = histogram.reduce(math.max);
    final List<double> normalizedHistogram = histogram.map((count) => count / maxCount).toList();

    // Compute KDE
    final List<_Point> kdePoints = [];
    for (int i = 0; i <= 100; i++) {
      final double x = minValue + (i / 100) * range;
      double y = 0;
      for (final value in data) {
        y += math.exp(-math.pow(x - value, 2) / (2 * bandwidth * bandwidth));
      }
      y /= data.length * bandwidth * math.sqrt(2 * math.pi);
      kdePoints.add(_Point(x, y));
    }

    // Normalize KDE
    final double maxKDE = kdePoints.map((p) => p.y).reduce(math.max);
    final List<_Point> normalizedKDE = kdePoints.map((p) => _Point(p.x, p.y / maxKDE)).toList();

    // Draw histogram
    final Paint histogramPaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < bins; i++) {
      final double left = plotOffset.dx + i * plotSize.width / bins;
      final double top = normalizedHistogram[i] * plotSize.height;
      final Rect rect = Rect.fromLTWH(left, plotSize.height - top, plotSize.width / bins, top);
      canvas.drawRect(rect, histogramPaint);
    }

    // Draw KDE
    final Paint kdePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Path kdePath = Path();
    for (int i = 0; i < normalizedKDE.length; i++) {
      final _Point point = normalizedKDE[i];
      final double x = plotOffset.dx + (point.x - minValue) / range * plotSize.width;
      final double y = plotSize.height * (1 - point.y);
      if (i == 0) {
        kdePath.moveTo(x, y);
      } else {
        kdePath.lineTo(x, y);
      }
    }
    canvas.drawPath(kdePath, kdePaint);

    // Draw normal distribution as a reference
    drawNormalDistribution(canvas, plotSize, plotOffset, minValue, maxValue, mean, stdDev, variance);

    // Highlight Mean and Standard Deviation
    highlightMeanAndStdDev(canvas, plotSize, plotOffset, minValue, maxValue, mean, stdDev);

    // Draw legend
    drawLegend(canvas, size);

    // Draw axes
    final Paint axesPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(Offset(padding, plotSize.height), Offset(size.width, plotSize.height), axesPaint);
    canvas.drawLine(Offset(padding, 0), Offset(padding, plotSize.height), axesPaint);

    // Draw x-axis annotations
    final int xTickCount = 5;
    for (int i = 0; i <= xTickCount; i++) {
      final double value = minValue + (i / xTickCount) * range;
      final double x = plotOffset.dx + (i / xTickCount) * plotSize.width;
      canvas.drawLine(Offset(x, plotSize.height), Offset(x, plotSize.height + 5), axesPaint);

      final textPainter = TextPainter(
        text: TextSpan(text: value.toStringAsFixed(1), style: plotTextStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, plotSize.height + 7));
    }

    // Draw y-axis annotations
    final int yTickCount = 5;
    for (int i = 0; i <= yTickCount; i++) {
      final double y = plotSize.height * (1 - i / yTickCount);
      canvas.drawLine(Offset(padding - 5, y), Offset(padding, y), axesPaint);

      final textPainter = TextPainter(
        text: TextSpan(text: (i / yTickCount).toStringAsFixed(1), style: plotTextStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(padding - 10 - textPainter.width, y - textPainter.height / 2));
    }

    // Add labels
    final xLabelPainter = TextPainter(
      text: TextSpan(text: 'Value', style: plotTextStyle),
      textDirection: TextDirection.ltr,
    );
    xLabelPainter.layout();
    xLabelPainter.paint(canvas, Offset(size.width / 2 - xLabelPainter.width / 2, size.height - xLabelPainter.height));

    final yLabelPainter = TextPainter(
      text: TextSpan(text: 'Frequency', style: plotTextStyle),
      textDirection: TextDirection.ltr,
    );
    yLabelPainter.layout();
    canvas.save();
    canvas.translate(0, size.height / 2 + yLabelPainter.width / 2);
    canvas.rotate(-math.pi / 2);
    yLabelPainter.paint(canvas, Offset(0, -padding / 4));
    canvas.restore();
  }

  void drawNormalDistribution(Canvas canvas, Size plotSize, Offset plotOffset, double minValue, double maxValue,
      double mean, double stdDev, double variance) {
    // Create normal distribution points
    List<_Point> normalPoints = [];
    for (int i = 0; i <= 100; i++) {
      double x = minValue + (i / 100) * (maxValue - minValue);
      double y = (1 / (stdDev * math.sqrt(2 * math.pi))) * math.exp(-math.pow(x - mean, 2) / (2 * variance));
      normalPoints.add(_Point(x, y));
    }

    // Normalize the points
    double maxY = normalPoints.map((p) => p.y).reduce(math.max);
    List<_Point> normalizedPoints = normalPoints.map((p) => _Point(p.x, p.y / maxY)).toList();

    // Draw the normal distribution curve
    final Paint normalPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Path normalPath = Path();
    for (int i = 0; i < normalizedPoints.length; i++) {
      final _Point point = normalizedPoints[i];
      final double x = plotOffset.dx + (point.x - minValue) / (maxValue - minValue) * plotSize.width;
      final double y = plotOffset.dy + plotSize.height * (1 - point.y);
      if (i == 0) {
        normalPath.moveTo(x, y);
      } else {
        normalPath.lineTo(x, y);
      }
    }
    canvas.drawPath(normalPath, normalPaint);
  }

  void highlightMeanAndStdDev(
      Canvas canvas, Size plotSize, Offset plotOffset, double minValue, double maxValue, double mean, double stdDev) {
    final Paint meanPaint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double meanX = plotOffset.dx + (mean - minValue) / (maxValue - minValue) * plotSize.width;

    // Draw mean line
    canvas.drawLine(Offset(meanX, plotOffset.dy), Offset(meanX, plotOffset.dy + plotSize.height), meanPaint);

    // Draw standard deviation range
    final double leftStdDevX = plotOffset.dx + (mean - stdDev - minValue) / (maxValue - minValue) * plotSize.width;
    final double rightStdDevX = plotOffset.dx + (mean + stdDev - minValue) / (maxValue - minValue) * plotSize.width;

    canvas.drawLine(Offset(leftStdDevX, plotOffset.dy + plotSize.height),
        Offset(rightStdDevX, plotOffset.dy + plotSize.height), meanPaint);

    // Add labels
    final TextPainter meanPainter = TextPainter(
      text: TextSpan(text: 'Mean', style: plotTextStyle.copyWith(color: Colors.purple)),
      textDirection: TextDirection.ltr,
    );
    meanPainter.layout();
    meanPainter.paint(canvas, Offset(meanX - meanPainter.width / 2, plotOffset.dy - 15));

    final TextPainter stdDevPainter = TextPainter(
      text: TextSpan(text: '±1 StdDev', style: plotTextStyle.copyWith(color: Colors.purple)),
      textDirection: TextDirection.ltr,
    );
    stdDevPainter.layout();
    stdDevPainter.paint(canvas,
        Offset((leftStdDevX + rightStdDevX) / 2 - stdDevPainter.width / 2, plotOffset.dy + plotSize.height - 15));
  }

  void drawLegend(Canvas canvas, Size size) {
    final double legendX = size.width - 100;
    final double legendY = 20;
    final double itemHeight = 20;

    // KDE legend item
    canvas.drawLine(
        Offset(legendX, legendY),
        Offset(legendX + 30, legendY),
        Paint()..color = Colors.red..strokeWidth = 2
    );
    final kdePainter = TextPainter(
      text: TextSpan(text: 'KDE of your data', style: plotTextStyle),
      textDirection: TextDirection.ltr,
    );
    kdePainter.layout();
    kdePainter.paint(canvas, Offset(legendX + 35, legendY - 6));

    // Normal distribution legend item
    canvas.drawLine(
        Offset(legendX, legendY + itemHeight),
        Offset(legendX + 30, legendY + itemHeight),
        Paint()..color = Colors.green..strokeWidth = 2
    );
    final normalPainter = TextPainter(
      text: TextSpan(text: 'Theoretical Normal Distribution', style: plotTextStyle),
      textDirection: TextDirection.ltr,
    );
    normalPainter.layout();
    normalPainter.paint(canvas, Offset(legendX + 35, legendY + itemHeight - 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Point {
  final double x;
  final double y;

  _Point(this.x, this.y);
}
