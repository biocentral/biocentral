import 'dart:math';

import 'package:biocentral/plugins/protein_engineering/domain/campaign_insights.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Axis titles for charts with rounds on the x-axis: whole rounds only, no top or right axis.
FlTitlesData roundAxisTitles(BuildContext context) {
  final labelStyle = TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant);
  return FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 44,
        getTitlesWidget: (value, meta) {
          // fl_chart always labels the axis ends; skip them unless they fall on the regular interval.
          final steps = value / meta.appliedInterval;
          if (!steps.isFinite || (steps - steps.round()).abs() > 1e-6) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            meta: meta,
            child: Text(meta.formattedValue, style: labelStyle),
          );
        },
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: 1,
        reservedSize: 24,
        getTitlesWidget: (value, meta) => value == value.roundToDouble()
            ? SideTitleWidget(
                meta: meta,
                child: Text(value.toInt().toString(), style: labelStyle),
              )
            : const SizedBox.shrink(),
      ),
    ),
  );
}

/// One box per round, e.g. of prediction errors or of measured values.
class RoundBoxPlot extends StatelessWidget {
  final List<(int round, BoxSummary summary)> series;

  /// Emphasizes y = 0 and keeps it in view; meaningful for differences such as prediction errors.
  final bool showZeroLine;

  const RoundBoxPlot({required this.series, this.showZeroLine = false, super.key});

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) return const Center(child: Text('No measured data.'));
    final scheme = Theme.of(context).colorScheme;
    final lows = series.map((entry) => entry.$2.min);
    final highs = series.map((entry) => entry.$2.max);
    final low = showZeroLine ? lows.fold<double>(0, min) : lows.reduce(min);
    final high = showZeroLine ? highs.fold<double>(0, max) : highs.reduce(max);
    final padding = max((high - low) * 0.1, 0.5);

    return CandlestickChart(
      CandlestickChartData(
        minX: series.first.$1 - 0.5,
        maxX: series.last.$1 + 0.5,
        minY: low - padding,
        maxY: high + padding,
        titlesData: roundAxisTitles(context),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => showZeroLine && value == 0
              ? FlLine(color: scheme.onSurfaceVariant, strokeWidth: 1)
              : FlLine(color: scheme.outlineVariant, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        candlestickPainter: _BoxPlotPainter(
          color: scheme.primary,
          medians: [for (final (_, summary) in series) summary.median],
        ),
        candlestickSpots: [
          for (final (round, summary) in series)
            CandlestickSpot(
              x: round.toDouble(),
              open: summary.q1,
              high: summary.max,
              low: summary.min,
              close: summary.q3,
            ),
        ],
        candlestickTouchData: CandlestickTouchData(
          touchTooltipData: CandlestickTouchTooltipData(
            getTooltipItems: (painter, spot, index) {
              final summary = series[index].$2;
              String format(double value) => value.toStringAsFixed(2);
              return CandlestickTooltipItem(
                'Round ${series[index].$1} · ${summary.count} measured\n'
                'median ${format(summary.median)}\n'
                'middle half ${format(summary.q1)} to ${format(summary.q3)}\n'
                'range ${format(summary.min)} to ${format(summary.max)}',
                textStyle: const TextStyle(color: Colors.white, fontSize: 11),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Draws whiskers from min to max, a box from Q1 to Q3, and a line at the median.
class _BoxPlotPainter extends FlCandlestickPainter {
  static const _boxWidth = 18.0;

  final List<double> medians;

  final Color color;
  late final _linePaint = Paint()
    ..color = color
    ..strokeWidth = 1.5;
  late final _fillPaint = Paint()..color = color.withValues(alpha: 0.18);
  late final _strokePaint = Paint()
    ..color = color
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;
  late final _medianPaint = Paint()
    ..color = color
    ..strokeWidth = 2.5;

  _BoxPlotPainter({required this.medians, required this.color});

  @override
  void paint(
    Canvas canvas,
    ValueInCanvasProvider xInCanvasProvider,
    ValueInCanvasProvider yInCanvasProvider,
    CandlestickSpot spot,
    int spotIndex,
  ) {
    final x = xInCanvasProvider(spot.x);
    final left = x - _boxWidth / 2;
    final right = x + _boxWidth / 2;
    final boxTop = yInCanvasProvider(spot.close);
    final boxBottom = yInCanvasProvider(spot.open);
    final whiskerTop = yInCanvasProvider(spot.high);
    final whiskerBottom = yInCanvasProvider(spot.low);
    final median = yInCanvasProvider(medians[spotIndex]);

    canvas
      ..drawLine(Offset(x, whiskerTop), Offset(x, boxTop), _linePaint)
      ..drawLine(Offset(x, boxBottom), Offset(x, whiskerBottom), _linePaint)
      ..drawLine(Offset(x - _boxWidth / 4, whiskerTop), Offset(x + _boxWidth / 4, whiskerTop), _linePaint)
      ..drawLine(Offset(x - _boxWidth / 4, whiskerBottom), Offset(x + _boxWidth / 4, whiskerBottom), _linePaint);

    final box = RRect.fromRectAndRadius(Rect.fromLTRB(left, boxTop, right, boxBottom), const Radius.circular(2));
    canvas
      ..drawRRect(box, _fillPaint)
      ..drawRRect(box, _strokePaint)
      ..drawLine(Offset(left, median), Offset(right, median), _medianPaint);
  }

  @override
  FlCandlestickPainter lerp(FlCandlestickPainter a, FlCandlestickPainter b, double t) => b;

  @override
  Color getMainColor({required CandlestickSpot spot, required int spotIndex}) => color;

  @override
  List<Object?> get props => [medians, color];
}
