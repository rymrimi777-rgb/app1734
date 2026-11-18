import 'package:flutter/material.dart';
import '../models.dart';
import 'sticker_canvas.dart';

class StrokePainter extends CustomPainter {
  final List<DrawnStroke> strokes;
  final DrawnStroke? currentStroke;

  StrokePainter({required this.strokes, this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in [...strokes, if (currentStroke != null) currentStroke!]) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.type == StrokeType.highlighter
            ? stroke.color.withOpacity(0.45)
            : (stroke.isSelected ? Colors.blue : stroke.color)
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.type == StrokeType.highlighter) {
        paint.blendMode = BlendMode.multiply;
      }

      if (stroke.type == StrokeType.eraser) {
        paint.color = Colors.white;
        paint.strokeWidth = 24.0;
      }

      if (stroke.type == StrokeType.rectangle && stroke.points.length >= 2) {
        final first = stroke.points.first;
        final last = stroke.points.last;
        final rect = Rect.fromPoints(first, last);
        canvas.drawRect(rect, paint);
      } else if (stroke.type == StrokeType.lasso && stroke.points.length >= 2) {
        final path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      } else {
        if (stroke.points.length == 1) {
          canvas.drawCircle(stroke.points.first, stroke.strokeWidth / 2, paint);
        } else {
          final path = Path();
          path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
          for (int i = 1; i < stroke.points.length; i++) {
            path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
          }
          canvas.drawPath(path, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant StrokePainter oldDelegate) => true;
}

class AdvancedNoteCanvas extends StatefulWidget {
  final List<DrawnStroke> strokes;
  final List<TextBoxItem> textBoxes;
  final List<PlacedSticker> stickers;
  final List<String> images;
  final Function(List<DrawnStroke> updatedStrokes) onStrokesChanged;
  final Function(List<TextBoxItem> updatedTextBoxes) onTextBoxesChanged;
  final Function(List<PlacedSticker> updatedStickers) onStickersChanged;
  final Function(List<String> updatedImages) onImagesChanged;
  final Widget child;

  const AdvancedNoteCanvas({
    Key? key,
    required this.strokes,
    required this.textBoxes,
    required this.stickers,
    required this.images,
    required this.onStrokesChanged,
    required this.onTextBoxesChanged,
    required this.onStickersChanged,
    required this.onImagesChanged,
    required this.child,
  }) : super(key: key);

  @override
  State<AdvancedNoteCanvas> createState() => _AdvancedNoteCanvasState();
}

class _AdvancedNoteCanvasState extends State<AdvancedNoteCanvas> {
  StrokeType _selectedTool = StrokeType.pen;
  Color _selectedColor = Colors.black;
  final double _strokeWidth = 3.0;

  late List<DrawnStroke> _strokes;
  late List<TextBoxItem> _textBoxes;
  late List<PlacedSticker> _stickers;

  // Pastel Color Palette
  static const List<Color> pastelColors = [
    Colors.black,
    Color(0xFFFFF59D), // Pastel Yellow
    Color(0xFFF8BBD0), // Pastel Pink
    Color(0xFFC8E6C9), // Pastel Mint
    Color(0xFFE1BEE7), // Pastel Lavender
    Color(0xFFFFE0B2), // Pastel Peach
    Color(0xFFB3E5FC), // Pastel Sky Blue
  ];

  // Undo / Redo Stacks
  final List<List<DrawnStroke>> _undoStack = [];
  final List<List<DrawnStroke>> _redoStack = [];

  DrawnStroke? _currentStroke;

  @override
  void initState() {
    super.initState();
    _strokes = List.from(widget.strokes);
    _textBoxes = List.from(widget.textBoxes);
    _stickers = List.from(widget.stickers);
    _saveUndoState();
  }

  @override
  void didUpdateWidget(covariant AdvancedNoteCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stickers != oldWidget.stickers || widget.stickers.length != _stickers.length) {
      _stickers = List.from(widget.stickers);
    }
    if (widget.textBoxes != oldWidget.textBoxes || widget.textBoxes.length != _textBoxes.length) {
      _textBoxes = List.from(widget.textBoxes);
    }
    if (widget.strokes != oldWidget.strokes || widget.strokes.length != _strokes.length) {
      _strokes = List.from(widget.strokes);
    }
  }

  void _saveUndoState() {
    _undoStack.add(_strokes.map((s) => DrawnStroke.fromMap(s.toMap())).toList());
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.length > 1) {
      _redoStack.add(_undoStack.removeLast());
      final previous = _undoStack.last;
      setState(() {
        _strokes = previous.map((s) => DrawnStroke.fromMap(s.toMap())).toList();
      });
      widget.onStrokesChanged(_strokes);
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      final next = _redoStack.removeLast();
      _undoStack.add(next);
      setState(() {
        _strokes = next.map((s) => DrawnStroke.fromMap(s.toMap())).toList();
      });
      widget.onStrokesChanged(_strokes);
    }
  }

  void _clearCanvas() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Clear Canvas?', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
        content: Text('This will erase all handwritten strokes and text overlays on this page.', style: TextStyle(fontFamily: 'Essays1743', color: theme.textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _strokes.clear();
                _textBoxes.clear();
              });
              _saveUndoState();
              widget.onStrokesChanged(_strokes);
              widget.onTextBoxesChanged(_textBoxes);
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white, fontFamily: 'Essays1743')),
          ),
        ],
      ),
    );
  }

  void _addTextBox(Offset pos) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        final textController = TextEditingController();
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text('Add Floating Text', style: TextStyle(fontFamily: 'Essays1743', color: theme.textTheme.bodyLarge?.color)),
          content: TextField(
            controller: textController,
            autofocus: true,
            style: TextStyle(fontFamily: 'Essays1743', color: theme.textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: 'Enter text...',
              hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  setState(() {
                    _textBoxes.add(TextBoxItem(
                      id: 'tb_${DateTime.now().millisecondsSinceEpoch}',
                      text: textController.text.trim(),
                      x: pos.dx,
                      y: pos.dy,
                      colorValue: _selectedColor.value,
                    ));
                  });
                  widget.onTextBoxesChanged(_textBoxes);
                }
                Navigator.pop(context);
              },
              child: const Text('Add', style: TextStyle(fontFamily: 'Essays1743')),
            ),
          ],
        );
      },
    );
  }

  void _eraseStrokesAt(Offset pos) {
    const eraseRadius = 20.0;
    bool erased = false;
    _strokes.removeWhere((stroke) {
      final isTouched = stroke.points.any((p) => (p - pos).distance <= eraseRadius);
      if (isTouched) erased = true;
      return isTouched;
    });
    if (erased) {
      _saveUndoState();
      widget.onStrokesChanged(_strokes);
    }
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    if (_selectedTool == StrokeType.eraser) {
      _eraseStrokesAt(localPosition);
      return;
    }

    setState(() {
      _currentStroke = DrawnStroke(
        id: 'st_${DateTime.now().millisecondsSinceEpoch}',
        points: [localPosition],
        color: _selectedColor,
        strokeWidth: _selectedTool == StrokeType.highlighter ? 18.0 : _strokeWidth,
        type: _selectedTool,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    if (_selectedTool == StrokeType.eraser) {
      _eraseStrokesAt(localPosition);
      return;
    }

    if (_currentStroke == null) return;
    setState(() {
      _currentStroke!.points.add(localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_selectedTool == StrokeType.eraser || _currentStroke == null) return;

    _strokes.add(_currentStroke!);
    _saveUndoState();
    widget.onStrokesChanged(_strokes);

    setState(() {
      _currentStroke = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final iconDisabledColor = iconColor.withOpacity(0.3);

    return Column(
      children: [
        // Floating Toolbar
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
            boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Select Mode
                IconButton(
                  icon: Icon(Icons.touch_app, color: _selectedTool == StrokeType.none ? iconColor : iconDisabledColor),
                  onPressed: () => setState(() => _selectedTool = StrokeType.none),
                  tooltip: 'Text / Select Mode',
                ),
                // Pen
                IconButton(
                  icon: Icon(Icons.edit, color: _selectedTool == StrokeType.pen ? iconColor : iconDisabledColor),
                  onPressed: () => setState(() => _selectedTool = StrokeType.pen),
                  tooltip: 'Pen Tool',
                ),
                // Pastel Highlighter
                IconButton(
                  icon: Icon(Icons.drive_file_rename_outline,
                      color: _selectedTool == StrokeType.highlighter ? Colors.amber : iconDisabledColor),
                  onPressed: () => setState(() {
                    _selectedTool = StrokeType.highlighter;
                    if (_selectedColor == Colors.black) {
                      _selectedColor = const Color(0xFFFFF59D); // Default pastel yellow
                    }
                  }),
                  tooltip: 'Pastel Highlighter',
                ),
                // Vector Eraser Tool
                IconButton(
                  icon: Icon(Icons.cleaning_services,
                      color: _selectedTool == StrokeType.eraser ? Colors.redAccent : iconDisabledColor),
                  onPressed: () => setState(() => _selectedTool = StrokeType.eraser),
                  tooltip: 'Vector Stroke Eraser',
                ),
                // Text T tool
                IconButton(
                  icon: Icon(Icons.title, color: iconColor),
                  onPressed: () => _addTextBox(const Offset(50, 100)),
                  tooltip: 'Text Tool (T)',
                ),
                const VerticalDivider(width: 14),
                // Color pickers (Pastel palette)
                ...pastelColors.map(
                  (c) => GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == c ? theme.colorScheme.primary : Colors.black26,
                          width: _selectedColor == c ? 2.5 : 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 14),
                // Undo
                IconButton(
                  icon: Icon(Icons.undo, color: _undoStack.length > 1 ? iconColor : iconDisabledColor),
                  onPressed: _undoStack.length > 1 ? _undo : null,
                  tooltip: 'Undo',
                ),
                // Redo
                IconButton(
                  icon: Icon(Icons.redo, color: _redoStack.isNotEmpty ? iconColor : iconDisabledColor),
                  onPressed: _redoStack.isNotEmpty ? _redo : null,
                  tooltip: 'Redo',
                ),
                // Clear Canvas
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                  onPressed: _clearCanvas,
                  tooltip: 'Clear Canvas',
                ),
              ],
            ),
          ),
        ),

        // Scrollable Canvas Overlay Stack
        Expanded(
          child: StickerCanvasOverlay(
            stickers: _stickers,
            onStickersChanged: (updated) {
              setState(() {
                _stickers = updated;
              });
              widget.onStickersChanged(updated);
            },
            child: Stack(
              children: [
                widget.child,
                // Drawing overlay
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: _selectedTool == StrokeType.none,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: CustomPaint(
                        painter: StrokePainter(strokes: _strokes, currentStroke: _currentStroke),
                      ),
                    ),
                  ),
                ),
                // Floating Text Boxes
                ..._textBoxes.map(
                  (tb) => Positioned(
                    left: tb.x,
                    top: tb.y,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          tb.x += details.delta.dx;
                          tb.y += details.delta.dy;
                        });
                        widget.onTextBoxesChanged(_textBoxes);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.cardColor.withOpacity(0.95),
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.12), blurRadius: 2)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tb.text,
                              style: TextStyle(
                                fontFamily: 'Essays1743',
                                fontSize: tb.fontSize,
                                color: Color(tb.colorValue),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() => _textBoxes.remove(tb));
                                widget.onTextBoxesChanged(_textBoxes);
                              },
                              child: Icon(Icons.close, size: 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5) ?? Colors.black45),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

