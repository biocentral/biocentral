import 'dart:convert';

class PlotData {
  final String svg;
  final PlotMetadata metadata;

  PlotData({required this.svg, required this.metadata});

  factory PlotData.fromJson(Map<String, dynamic> json) {
    return PlotData(
      svg: json['svg'],
      metadata: PlotMetadata.fromJson(json['metadata']),
    );
  }
}

class PlotMetadata {
  final List<InteractivePoint> points;
  final PlotDimensions dimensions;
  final String title;
  final String xLabel;
  final String yLabel;
  final Map<String, dynamic> extra;

  PlotMetadata({
    required this.points,
    required this.dimensions,
    required this.title,
    required this.xLabel,
    required this.yLabel,
    this.extra = const {},
  });

  factory PlotMetadata.fromJson(Map<String, dynamic> json) {
    // Collect extra fields (metadata like sequence_length, etc)
    final extra = Map<String, dynamic>.from(json);
    extra.remove('points');
    extra.remove('dimensions');
    extra.remove('title');
    extra.remove('x_label');
    extra.remove('y_label');

    return PlotMetadata(
      points: (json['points'] as List? ?? [])
          .map((p) => InteractivePoint.fromJson(p))
          .toList(),
      dimensions: PlotDimensions.fromJson(json['dimensions'] ?? {}),
      title: json['title'] ?? 'Chart',
      xLabel: json['x_label'] ?? '',
      yLabel: json['y_label'] ?? '',
      extra: extra,
    );
  }
}

class InteractivePoint {
  final double x;
  final double y;
  final double radius;
  final Map<String, dynamic> data;

  InteractivePoint({
    required this.x,
    required this.y,
    required this.radius,
    required this.data,
  });

  factory InteractivePoint.fromJson(Map<String, dynamic> json) {
    return InteractivePoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      radius: (json['radius'] as num? ?? 5.0).toDouble(),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class PlotDimensions {
  final double width;
  final double height;
  final double marginLeft;
  final double marginTop;

  PlotDimensions({
    required this.width,
    required this.height,
    required this.marginLeft,
    required this.marginTop,
  });

  factory PlotDimensions.fromJson(Map<String, dynamic> json) {
    return PlotDimensions(
      width: (json['width'] as num? ?? 400.0).toDouble(),
      height: (json['height'] as num? ?? 300.0).toDouble(),
      marginLeft: (json['margin_left'] as num? ?? 60.0).toDouble(),
      marginTop: (json['margin_top'] as num? ?? 40.0).toDouble(),
    );
  }
}
