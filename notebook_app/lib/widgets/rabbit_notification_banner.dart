import 'dart:async';
import 'package:flutter/material.dart';
import '../repository.dart';
import 'rabbit_system.dart';

enum RabbitBannerType { morning, evening, pomodoro }

class RabbitNotificationBanner {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show(BuildContext context, {required RabbitBannerType type, String? customMessage}) {
    final repo = DataRepository();
    final userName = repo.userName;

    // Check user preference toggle
    if (type == RabbitBannerType.morning && !repo.notifyMorningRabbit) return;
    if (type == RabbitBannerType.evening && !repo.notifyEveningRabbit) return;
    if (type == RabbitBannerType.pomodoro && !repo.notifyPomodoroRabbit) return;

    RabbitAnimation animation;
    String message;

    switch (type) {
      case RabbitBannerType.morning:
        animation = RabbitAnimation.morning24;
        message = customMessage ?? "Good morning, $userName. A new page is waiting for you.";
        break;
      case RabbitBannerType.evening:
        animation = RabbitAnimation.evening27;
        message = customMessage ?? "Good evening, $userName. The day is growing quiet.";
        break;
      case RabbitBannerType.pomodoro:
        animation = RabbitAnimation.pomodoro32;
        message = customMessage ?? "Well done, $userName. Your focus session is complete.";
        break;
    }

    dismiss();

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _currentEntry = OverlayEntry(
      builder: (context) => _RabbitNotificationWidget(
        animation: animation,
        message: message,
        onDismiss: dismiss,
      ),
    );

    overlay.insert(_currentEntry!);

    _dismissTimer = Timer(const Duration(seconds: 5), () {
      dismiss();
    });
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _RabbitNotificationWidget extends StatefulWidget {
  final RabbitAnimation animation;
  final String message;
  final VoidCallback onDismiss;

  const _RabbitNotificationWidget({
    Key? key,
    required this.animation,
    required this.message,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_RabbitNotificationWidget> createState() => _RabbitNotificationWidgetState();
}

class _RabbitNotificationWidgetState extends State<_RabbitNotificationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2420) : const Color(0xFFFAF6F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white24 : Colors.black12, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.white70,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: IsolatedRabbitSprite(
                          animation: widget.animation,
                          scale: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          fontFamily: 'Essays1743',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFF4ECD8) : const Color(0xFF2D2319),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
