import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';

class AudioMemoPlayerWidget extends StatefulWidget {
  final AudioMemoItem memo;
  final VoidCallback onDelete;

  const AudioMemoPlayerWidget({
    Key? key,
    required this.memo,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<AudioMemoPlayerWidget> createState() => _AudioMemoPlayerWidgetState();
}

class _AudioMemoPlayerWidgetState extends State<AudioMemoPlayerWidget> {
  bool _isPlaying = false;

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateStr = DateFormat('h:mm a').format(widget.memo.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2420) : const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: theme.primaryColor,
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 18,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.memo.title.isEmpty ? 'Voice Memo' : widget.memo.title,
                style: TextStyle(
                  fontFamily: 'Essays1743',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                '${widget.memo.durationSeconds}s • $dateStr',
                style: TextStyle(
                  fontFamily: 'Essays1743',
                  fontSize: 11,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Waveform bars simulation
          Row(
            children: List.generate(8, (i) {
              final heights = [10.0, 18.0, 12.0, 22.0, 16.0, 24.0, 14.0, 8.0];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 3,
                height: _isPlaying ? heights[i] : 8.0,
                decoration: BoxDecoration(
                  color: _isPlaying ? theme.primaryColor : theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
            onPressed: widget.onDelete,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class PdfAnnotationViewer extends StatelessWidget {
  final String pdfPath;
  final VoidCallback onRemove;

  const PdfAnnotationViewer({
    Key? key,
    required this.pdfPath,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFEEEEEE),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pdfPath.split('/').last.split('\\').last,
                    style: const TextStyle(
                      fontFamily: 'Essays1743',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.black54),
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
          // PDF Canvas Slide Representation
          Container(
            height: 280,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: CustomPaint(
              painter: PdfSlidePlaceholderPainter(),
              child: const Center(
                child: Text(
                  '📄 PDF Lecture Slides Loaded\nDraw or highlight directly over this document',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Essays1743',
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PdfSlidePlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 2;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
    for (double y = 40; y < size.height; y += 30) {
      canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HighlightColorPickerModal extends StatelessWidget {
  final Function(int colorValue) onColorSelected;
  final VoidCallback? onRemove;

  static const List<int> pastelSwatches = [
    0xFFFFF59D, // Yellow
    0xFFF8BBD0, // Pink
    0xFFC8E6C9, // Mint
    0xFFE1BEE7, // Lavender
    0xFFFFE0B2, // Peach
    0xFFB3E5FC, // Sky Blue
  ];

  const HighlightColorPickerModal({
    Key? key,
    required this.onColorSelected,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Highlight:',
            style: TextStyle(
              fontFamily: 'Essays1743',
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          ...pastelSwatches.map((colorVal) => GestureDetector(
                onTap: () => onColorSelected(colorVal),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(colorVal),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26),
                  ),
                ),
              )),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cleaning_services_outlined, size: 16, color: Colors.black87),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

List<TextSpan> buildHighlightedTextSpans({
  required String text,
  required List<TextHighlight> highlights,
  required TextStyle baseStyle,
  Function(TextHighlight highlight)? onHighlightTap,
}) {
  if (text.isEmpty) return [TextSpan(text: '', style: baseStyle)];

  final sortedHighlights = List<TextHighlight>.from(highlights)
    ..sort((a, b) => a.start.compareTo(b.start));

  final List<TextSpan> spans = [];
  int currentIndex = 0;

  for (final hl in sortedHighlights) {
    if (hl.start > currentIndex && hl.start <= text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex, hl.start),
        style: baseStyle,
      ));
    }

    final int start = hl.start.clamp(0, text.length);
    final int end = hl.end.clamp(start, text.length);

    if (end > start) {
      spans.add(TextSpan(
        text: text.substring(start, end),
        style: baseStyle.copyWith(
          background: Paint()..color = Color(hl.colorValue),
        ),
      ));
    }

    currentIndex = end;
  }

  if (currentIndex < text.length) {
    spans.add(TextSpan(
      text: text.substring(currentIndex),
      style: baseStyle,
    ));
  }

  return spans;
}

class HighlightTextEditingController extends TextEditingController {
  List<TextHighlight> highlights;
  TextStyle? defaultStyle;

  HighlightTextEditingController({
    String? text,
    required this.highlights,
    this.defaultStyle,
  }) : super(text: text);

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    if (highlights.isEmpty || text.isEmpty) {
      return super.buildTextSpan(context: context, style: style, withComposing: withComposing);
    }

    final effectiveStyle = style ?? defaultStyle ?? const TextStyle();
    final sorted = List<TextHighlight>.from(highlights)..sort((a, b) => a.start.compareTo(b.start));

    final children = <TextSpan>[];
    int current = 0;

    for (final hl in sorted) {
      if (hl.start > current && hl.start < text.length) {
        children.add(TextSpan(
          text: text.substring(current, hl.start),
          style: effectiveStyle,
        ));
      }
      final start = hl.start.clamp(0, text.length);
      final end = hl.end.clamp(0, text.length);
      if (start < end) {
        children.add(TextSpan(
          text: text.substring(start, end),
          style: effectiveStyle.copyWith(
            backgroundColor: Color(hl.colorValue),
          ),
        ));
      }
      current = end;
    }

    if (current < text.length) {
      children.add(TextSpan(
        text: text.substring(current),
        style: effectiveStyle,
      ));
    }

    return TextSpan(style: effectiveStyle, children: children);
  }
}

