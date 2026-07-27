import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'plot_data.dart';

class InteractiveSvgChart extends StatefulWidget {
  final PlotData plotData;

  const InteractiveSvgChart({Key? key, required this.plotData})
      : super(key: key);

  @override
  State<InteractiveSvgChart> createState() => _InteractiveSvgChartState();
}

class _InteractiveSvgChartState extends State<InteractiveSvgChart> {
  InteractivePoint? hoveredPoint;
  Offset? tooltipPosition;
  double scale = 1.0;
  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Info panel
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hover or tap on data elements to see more information. Use scroll to zoom, drag to pan.',
                  style: TextStyle(color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),

        // Chart area
        Expanded(
          child: Container(
            color: Colors.grey.shade100,
            padding: EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartWidth = widget.plotData.metadata.dimensions.width;
                final chartHeight = widget.plotData.metadata.dimensions.height;
                
                // Calculate initial scale to fit the whole SVG
                final double scaleX = constraints.maxWidth / chartWidth;
                final double scaleY = constraints.maxHeight / chartHeight;
                final double initialScale = (scaleX < scaleY ? scaleX : scaleY).clamp(0.1, 1.0);

                return InteractiveViewer(
                  boundaryMargin: EdgeInsets.all(100),
                  minScale: 0.1,
                  maxScale: 10.0,
                  constrained: false,
                  onInteractionUpdate: (details) {
                    setState(() {
                      scale = details.scale;
                    });
                  },
                  child: MouseRegion(
                    onHover: (event) => _handleHover(event.localPosition),
                    onExit: (_) => setState(() {
                      hoveredPoint = null;
                      tooltipPosition = null;
                    }),
                    child: GestureDetector(
                      onTapDown: (details) => _handleTap(details.localPosition),
                      child: Container(
                        width: chartWidth,
                        height: chartHeight,
                        child: Stack(
                          children: [
                            // SVG Layer
                            SvgPicture.string(
                              widget.plotData.svg,
                              width: chartWidth,
                              height: chartHeight,
                              fit: BoxFit.contain,
                            ),

                            // Interactive overlay layer
                            ..._buildInteractiveOverlays(),

                            // Tooltip
                            if (hoveredPoint != null && tooltipPosition != null)
                              _buildTooltip(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Stats panel
        _buildStatsPanel(),
      ],
    );
  }

  List<Widget> _buildInteractiveOverlays() {
    return widget.plotData.metadata.points.map((point) {
      final isHovered = hoveredPoint == point;
      final isRect = point.width != null && point.height != null;

      return Positioned(
        left: isRect ? point.x - point.width! / 2 : point.x - point.radius - 5,
        top: isRect ? point.y - point.height! / 2 : point.y - point.radius - 5,
        child: Container(
          width: isRect ? point.width! : (point.radius + 5) * 2,
          height: isRect ? point.height! : (point.radius + 5) * 2,
          decoration: BoxDecoration(
            shape: isRect ? BoxShape.rectangle : BoxShape.circle,
            border: isHovered
                ? Border.all(color: Colors.blue, width: 2)
                : null,
            color: Colors.transparent,
          ),
        ),
      );
    }).toList();
  }

  void _handleHover(Offset position) {
    final point = _findPointAtPosition(position);
    setState(() {
      hoveredPoint = point;
      if (point != null) {
        tooltipPosition = Offset(point.x, point.y);
      } else {
        tooltipPosition = null;
      }
    });
  }

  void _handleTap(Offset position) {
    final point = _findPointAtPosition(position);
    if (point != null) {
      _showDetailDialog(point);
    }
  }

  InteractivePoint? _findPointAtPosition(Offset position) {
    for (var point in widget.plotData.metadata.points) {
      if (point.width != null && point.height != null) {
        // Rectangle hit detection
        final rect = Rect.fromCenter(
          center: Offset(point.x, point.y),
          width: point.width!,
          height: point.height!,
        );
        if (rect.contains(position)) {
          return point;
        }
      } else {
        // Circle hit detection
        final distance = (Offset(point.x, point.y) - position).distance;
        if (distance <= point.radius + 5) {
          return point;
        }
      }
    }
    return null;
  }

  Widget _buildTooltip() {
    final point = hoveredPoint!;
    final pos = tooltipPosition!;

    // Position tooltip to the right and slightly up from the point
    double tooltipLeft = pos.dx + 15;
    double tooltipTop = pos.dy - 30;

    // Adjust if tooltip goes off-screen (based on chart dimensions)
    final chartWidth = widget.plotData.metadata.dimensions.width;
    if (tooltipLeft + 200 > chartWidth) {
      tooltipLeft = pos.dx - 215; // Show on the left
    }

    return Positioned(
      left: tooltipLeft,
      top: tooltipTop,
      child: Container(
        constraints: BoxConstraints(maxWidth: 200),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: point.data.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDetailDialog(InteractivePoint point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Element Details'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...point.data.entries.map((entry) => _buildDetailRow(entry.key, entry.value.toString())).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildStatsPanel() {
    final extra = widget.plotData.metadata.extra;
    final totalCount = widget.plotData.metadata.points.length;
    
    final List<Widget> statItems = [];
    
    // Add default stats if it seems like a point/bar chart
    if (widget.plotData.metadata.xLabel.isNotEmpty || widget.plotData.metadata.yLabel.isNotEmpty) {
      statItems.add(_buildStatItem(
        'Total Elements',
        totalCount.toString(),
        Icons.bubble_chart,
        Colors.blue,
      ));
    }

    // Add optional metadata from extra
    extra.forEach((key, value) {
      if (value is num || (value is String && value.length < 10)) {
        statItems.add(_buildStatItem(
          key.replaceAll('_', ' ').toUpperCase(),
          value.toString(),
          Icons.info_outline,
          Colors.orange,
        ));
      }
    });

    statItems.add(_buildStatItem(
      'Zoom',
      '${(scale * 100).toStringAsFixed(0)}%',
      Icons.zoom_in,
      Colors.green,
    ));

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: statItems.map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: item,
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}