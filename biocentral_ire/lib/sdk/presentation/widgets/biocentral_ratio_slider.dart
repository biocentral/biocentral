import 'package:flutter/material.dart';

class BiocentralRatioSlider extends StatefulWidget {
  final double ratio1;
  final double? ratio2;
  final List<String> labels;
  final ValueChanged<(double, double, double?)> onChanged;
  final List<Color>? colors;
  final int? totalN;

  const BiocentralRatioSlider({
    required this.ratio1,
    required this.labels,
    required this.onChanged,
    super.key,
    this.ratio2,
    this.colors,
    this.totalN,
  })  : assert(ratio2 != null ? labels.length == 3 : labels.length == 2),
        assert(colors != null ? colors.length == labels.length : true);

  @override
  State<BiocentralRatioSlider> createState() => _BiocentralRatioSliderState();
}

class _BiocentralRatioSliderState extends State<BiocentralRatioSlider> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        if (widget.totalN != null) Text('Total Dataset Length: ${widget.totalN}'),
        const SizedBox(height: 16),
        _buildRatioDisplay(),
        const SizedBox(height: 16),
        _buildSliders(),
        const SizedBox(height: 16),
        _buildRatioBar(),
      ],
    );
  }

  List<double> getRatioList() {
    return widget.ratio2 != null
        ? [widget.ratio1, widget.ratio2!, 1 - (widget.ratio1 + widget.ratio2!)]
        : [widget.ratio1, 1 - widget.ratio1];
  }

  Widget _buildRatioDisplay() {
    final ratioList = getRatioList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(ratioList.length, (index) {
        return Column(
          children: [
            Text(
              widget.labels[index],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${(ratioList[index] * 100).round()}%'),
            if (widget.totalN != null) Text('~${(widget.totalN! * ratioList[index]).round()}'),
          ],
        );
      }),
    );
  }

  Widget _buildSliders() {
    if (widget.ratio2 == null) {
      return Slider(
        value: widget.ratio1,
        min: 0.01,
        max: 0.99,
        divisions: 98,
        onChanged: (value) {
          widget.onChanged((value, 1 - value, null));
        },
      );
    } else {
      final ratio1 = widget.ratio1;
      final ratio2 = widget.ratio2!;
      // Three-way split using RangeSlider
      final double start = ratio1;
      final double end = ratio1 + ratio2;

      return RangeSlider(
        values: RangeValues(start, end),
        min: 0.01,
        max: 0.99,
        divisions: 98,
        onChanged: (values) {
          final double r1 = values.start;
          final double r2 = values.end - values.start;
          final double r3 = 1.0 - (r1 + r2);
          assert(r1 + r2 + r3 == 1.0);
          widget.onChanged((r1, r2, r3));
        },
      );
    }
  }

  Widget _buildRatioBar() {
    final ratioList = getRatioList();
    return Container(
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: List.generate(ratioList.length, (index) {
            return Expanded(
              flex: (ratioList[index] * 1000).toInt(),
              child: Container(
                color: widget.colors?[index] ?? [Colors.blue, Colors.orange, Colors.green][index % 3],
              ),
            );
          }),
        ),
      ),
    );
  }
}
