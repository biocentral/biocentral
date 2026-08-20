import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NestedTooltipWidget extends StatefulWidget {
  final String text;
  final Map<String, NestedTooltipData> tooltipData;
  final TextStyle? textStyle;

  const NestedTooltipWidget({
    required this.text,
    required this.tooltipData,
    super.key,
    this.textStyle,
  });

  @override
  State<NestedTooltipWidget> createState() => _NestedTooltipWidgetState();
}

class NestedTooltipData {
  final String content;
  final Map<String, NestedTooltipData>? nestedTooltips;

  NestedTooltipData({
    required this.content,
    this.nestedTooltips,
  });
}

class _NestedTooltipWidgetState extends State<NestedTooltipWidget> {
  final List<OverlayEntry> _activeTooltips = [];
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _closeAllTooltips();
    super.dispose();
  }

  void _closeAllTooltips() {
    for (var tooltip in _activeTooltips) {
      tooltip.remove();
    }
    _activeTooltips.clear();
  }

  void _showTooltip(
    BuildContext context,
    String key,
    Offset globalPosition,
    Map<String, NestedTooltipData> tooltipData,
  ) {
    final tooltipInfo = tooltipData[key];
    if (tooltipInfo == null) return;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: globalPosition.dx + 10,
        top: globalPosition.dy - 10,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        overlayEntry.remove();
                        _activeTooltips.remove(overlayEntry);
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildNestedTooltipContent(
                  tooltipInfo.content,
                  tooltipInfo.nestedTooltips ?? {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    _activeTooltips.add(overlayEntry);
  }

  Widget _buildNestedTooltipContent(String content, Map<String, NestedTooltipData> nestedData) {
    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(r'\[(\w+)\]');
    int lastIndex = 0;

    for (final match in exp.allMatches(content)) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: content.substring(lastIndex, match.start),
            style: const TextStyle(color: Colors.white),
          ),
        );
      }

      // Add the clickable tooltip text
      final key = match.group(1)!;
      spans.add(
        TextSpan(
          text: key,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              final RenderBox renderBox = context.findRenderObject() as RenderBox;
              final position = renderBox.localToGlobal(Offset.zero);
              _showTooltip(context, key, position, nestedData);
            },
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < content.length) {
      spans.add(
        TextSpan(
          text: content.substring(lastIndex),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildMainContent() {
    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(r'\[(\w+)\]');
    int lastIndex = 0;

    for (final match in exp.allMatches(widget.text)) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: widget.text.substring(lastIndex, match.start),
            style: widget.textStyle,
          ),
        );
      }

      // Add the clickable tooltip text
      final key = match.group(1)!;
      spans.add(
        TextSpan(
          text: key,
          style: (widget.textStyle ?? const TextStyle()).copyWith(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              final RenderBox renderBox = context.findRenderObject() as RenderBox;
              final position = renderBox.localToGlobal(Offset.zero);
              _showTooltip(context, key, position, widget.tooltipData);
            },
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < widget.text.length) {
      spans.add(
        TextSpan(
          text: widget.text.substring(lastIndex),
          style: widget.textStyle,
        ),
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: RichText(
        text: TextSpan(children: spans),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _closeAllTooltips(),
      child: _buildMainContent(),
    );
  }
}
