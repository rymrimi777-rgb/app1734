import 'package:flutter/material.dart';
import '../models.dart';
import '../asset_manifest.dart';

class StickerCanvasOverlay extends StatefulWidget {
  final List<PlacedSticker> stickers;
  final Function(List<PlacedSticker>) onStickersChanged;
  final Widget child;

  const StickerCanvasOverlay({
    Key? key,
    required this.stickers,
    required this.onStickersChanged,
    required this.child,
  }) : super(key: key);

  @override
  State<StickerCanvasOverlay> createState() => _StickerCanvasOverlayState();
}

class _StickerCanvasOverlayState extends State<StickerCanvasOverlay> {
  String? _selectedStickerId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStickerId = null;
        });
      },
      child: Stack(
        children: [
          widget.child,
          ...widget.stickers.map((sticker) {
            final isSelected = sticker.id == _selectedStickerId;
            return Positioned(
              left: sticker.x,
              top: sticker.y,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStickerId = sticker.id;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    sticker.x += details.delta.dx;
                    sticker.y += details.delta.dy;
                  });
                  widget.onStickersChanged(widget.stickers);
                },
                child: Transform.rotate(
                  angle: sticker.rotation,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: isSelected
                        ? BoxDecoration(
                            border: Border.all(color: Colors.black54, width: 1.5),
                            borderRadius: BorderRadius.circular(4),
                          )
                        : null,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset(
                          sticker.assetPath,
                          width: sticker.width,
                          height: sticker.height,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                        if (isSelected) ...[
                          // Lock / Unlock toggle button
                          Positioned(
                            top: -10,
                            left: -10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  sticker.isLocked = !sticker.isLocked;
                                });
                                widget.onStickersChanged(widget.stickers);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: sticker.isLocked ? Colors.amber : Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  sticker.isLocked ? Icons.lock : Icons.lock_open,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          // Remove button
                          if (!sticker.isLocked)
                            Positioned(
                              top: -10,
                              right: -10,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    widget.stickers.removeWhere((s) => s.id == sticker.id);
                                    _selectedStickerId = null;
                                  });
                                  widget.onStickersChanged(widget.stickers);
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          // Rotate handle
                          if (!sticker.isLocked)
                            Positioned(
                              bottom: -10,
                              right: -10,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    sticker.rotation += details.delta.dx * 0.02;
                                  });
                                  widget.onStickersChanged(widget.stickers);
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.rotate_right,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          // Resize handle
                          if (!sticker.isLocked)
                            Positioned(
                              bottom: -10,
                              left: -10,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    final newWidth = (sticker.width + details.delta.dx).clamp(40.0, 300.0);
                                    final newHeight = (sticker.height + details.delta.dy).clamp(40.0, 300.0);
                                    sticker.width = newWidth;
                                    sticker.height = newHeight;
                                  });
                                  widget.onStickersChanged(widget.stickers);
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.aspect_ratio,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),

                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class StickerPickerSheet extends StatelessWidget {
  final Function(String assetPath) onStickerSelected;

  const StickerPickerSheet({
    Key? key,
    required this.onStickerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stickers Library',
                style: TextStyle(
                  fontFamily: 'Essays1743',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: theme.iconTheme.color),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AppAssets.stickers.isEmpty
                ? Center(
                    child: Text(
                      'No stickers available',
                      style: TextStyle(
                        fontFamily: 'Essays1743',
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: AppAssets.stickers.length,
                    itemBuilder: (context, index) {
                      final stickerPath = AppAssets.stickers[index];
                      return GestureDetector(
                        onTap: () {
                          onStickerSelected(stickerPath);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Image.asset(
                            stickerPath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image, color: theme.disabledColor),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
