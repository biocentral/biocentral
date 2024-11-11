import 'dart:math' as math;

import 'package:flutter/material.dart';

class HistogramKDEPlot extends StatelessWidget {
  final List<double> data;
  final int bins;
  final double bandwidth;

  const HistogramKDEPlot({
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

  _HistogramKDEPainter(this.data, this.bins, this.bandwidth);

  @override
  void paint(Canvas canvas, Size size) {
    final double minValue = data.reduce(math.min);
    final double maxValue = data.reduce(math.max);
    final double range = maxValue - minValue;
    final double binWidth = range / bins;

    const double padding = 40;
    final Size plotSize = Size(size.width - padding, size.height - padding);
    final Offset plotOffset = Offset(padding, 0);

    // Compute histogram
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
        text: TextSpan(text: value.toStringAsFixed(1), style: TextStyle(color: Colors.black, fontSize: 10)),
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
        text: TextSpan(text: (i / yTickCount).toStringAsFixed(1), style: TextStyle(color: Colors.black, fontSize: 10)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(padding - 10 - textPainter.width, y - textPainter.height / 2));
    }

    // Add labels
    final xLabelPainter = TextPainter(
      text: TextSpan(text: 'Value', style: TextStyle(color: Colors.black, fontSize: 12)),
      textDirection: TextDirection.ltr,
    );
    xLabelPainter.layout();
    xLabelPainter.paint(canvas, Offset(size.width / 2 - xLabelPainter.width / 2, size.height - xLabelPainter.height));

    final yLabelPainter = TextPainter(
      text: TextSpan(text: 'Frequency', style: TextStyle(color: Colors.black, fontSize: 12)),
      textDirection: TextDirection.ltr,
    );
    yLabelPainter.layout();
    canvas.save();
    canvas.translate(0, size.height / 2 + yLabelPainter.width / 2);
    canvas.rotate(-math.pi / 2);
    yLabelPainter.paint(canvas, Offset(0, 0));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Point {
  final double x;
  final double y;

  _Point(this.x, this.y);
}