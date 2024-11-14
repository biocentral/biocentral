import 'dart:math' as math;

import 'package:flutter/material.dart';

class BiocentralLinePlot extends StatelessWidget {
  final Map<String, Map<int, double>> data;
  final List<Color> colors;

  const BiocentralLinePlot({
    Key? key,
    required this.data,
    this.colors = const [Colors.blue, Colors.orange],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _LinePlotPainter(data, colors),
        );
      },
    );
  }
}

class _LinePlotPainter extends CustomPainter {
  static const double padding = 60;

  final Map<String, Map<int, double>> data;
  final List<Color> colors;
  final TextStyle plotTextStyle = TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);

  _LinePlotPainter(this.data, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final Size plotSize = Size(size.width - padding, size.height - padding);
    final Offset plotOffset = Offset(padding, 0);

    // Calculate metrics
    int maxEpoch = 0;
    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;

    data.forEach((key, values) {
      maxEpoch = math.max(maxEpoch, values.keys.reduce(math.max));
      minValue = math.min(minValue, values.values.reduce(math.min));
      maxValue = math.max(maxValue, values.values.reduce(math.max));
    });

    // Draw lines
    data.forEach((key, values) {
      drawLine(
          canvas, plotSize, plotOffset, values, maxEpoch, minValue, maxValue, colors[data.keys.toList().indexOf(key)]);
    });

    // Draw axes
    drawAxes(canvas, size, plotSize, plotOffset);

    // Draw x-axis annotations
    drawXAxisAnnotations(canvas, plotSize, plotOffset, maxEpoch);

    // Draw y-axis annotations
    drawYAxisAnnotations(canvas, plotSize, plotOffset, minValue, maxValue);

    // Add labels
    addLabels(canvas, size);

    // Draw legend
    drawLegend(canvas, size);
  }

  void drawLine(Canvas canvas, Size plotSize, Offset plotOffset, Map<int, double> values, int maxEpoch, double minValue,
      double maxValue, Color color) {
    final Paint linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Path path = Path();
    bool isFirst = true;

    values.forEach((epoch, value) {
      final double x = plotOffset.dx + (epoch / maxEpoch) * plotSize.width;
      final double y = plotSize.height - ((value - minValue) / (maxValue - minValue)) * plotSize.height;

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    });

    canvas.drawPath(path, linePaint);
  }

  void drawAxes(Canvas canvas, Size size, Size plotSize, Offset plotOffset) {
    final Paint axesPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(Offset(padding, plotSize.height), Offset(size.width, plotSize.height), axesPaint);
    canvas.drawLine(Offset(padding, 0), Offset(padding, plotSize.height), axesPaint);
  }

  void drawXAxisAnnotations(Canvas canvas, Size plotSize, Offset plotOffset, int maxEpoch) {
    final int xTickCount = 5;
    final Paint axesPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= xTickCount; i++) {
      final int epoch = (i / xTickCount * maxEpoch).round();
      final double x = plotOffset.dx + (i / xTickCount) * plotSize.width;
      canvas.drawLine(Offset(x, plotSize.height), Offset(x, plotSize.height + 5), axesPaint);

      final textPainter = TextPainter(
        text: TextSpan(text: epoch.toString(), style: plotTextStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, plotSize.height + 7));
    }
  }

  void drawYAxisAnnotations(Canvas canvas, Size plotSize, Offset plotOffset, double minValue, double maxValue) {
    final int yTickCount = 5;
    final Paint axesPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= yTickCount; i++) {
      final double value = minValue + (i / yTickCount) * (maxValue - minValue);
      final double y = plotSize.height * (1 - i / yTickCount);
      canvas.drawLine(Offset(padding - 5, y), Offset(padding, y), axesPaint);

      final textPainter = TextPainter(
        text: TextSpan(text: value.toStringAsFixed(2), style: plotTextStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(padding - 10 - textPainter.width, y - textPainter.height / 2));
    }
  }

  void addLabels(Canvas canvas, Size size) {
    final xLabelPainter = TextPainter(
      text: TextSpan(text: 'Epoch', style: plotTextStyle),
      textDirection: TextDirection.ltr,
    );
    xLabelPainter.layout();
    xLabelPainter.paint(canvas, Offset(size.width / 2 - xLabelPainter.width / 2, size.height - xLabelPainter.height));

    final yLabelPainter = TextPainter(
      text: TextSpan(text: 'Loss', style: plotTextStyle),
      textDirection: TextDirection.ltr,
    );
    yLabelPainter.layout();
    canvas.save();
    canvas.translate(0, size.height / 2 + yLabelPainter.width / 2);
    canvas.rotate(-math.pi / 2);
    yLabelPainter.paint(canvas, Offset(0, -padding / 4));
    canvas.restore();
  }

  void drawLegend(Canvas canvas, Size size) {
    final double legendX = size.width - 150;
    final double legendY = 20;
    final double itemHeight = 20;

    data.keys.toList().asMap().forEach((index, key) {
      canvas.drawLine(
          Offset(legendX, legendY + index * itemHeight),
          Offset(legendX + 30, legendY + index * itemHeight),
          Paint()
            ..color = colors[index]
            ..strokeWidth = 2);
      final textPainter = TextPainter(
        text: TextSpan(text: key, style: plotTextStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(legendX + 35, legendY + index * itemHeight - 6));
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
