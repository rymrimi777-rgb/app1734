import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rabbit_system.dart';

/// Types of companions available in the app.
enum CompanionType { rabbit, deer }

/// Animation states that any companion can be in.
enum CompanionAnimState { idle, walk, jump, celebrate }

/// Manages which companion is currently selected with persistence.
class CompanionManager extends ChangeNotifier {
  static final CompanionManager instance = CompanionManager._internal();
  factory CompanionManager() => instance;
  CompanionManager._internal() {
    _loadSelection();
  }

  CompanionType _selected = CompanionType.rabbit;
  CompanionType get selected => _selected;
  bool get isRabbit => _selected == CompanionType.rabbit;
  bool get isDeer => _selected == CompanionType.deer;

  Future<void> _loadSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('selected_companion') ?? 'rabbit';
      if (saved == 'deer') {
        _selected = CompanionType.deer;
      } else {
        _selected = CompanionType.rabbit;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[CompanionManager] Error loading selection: $e');
    }
  }

  Future<void> setCompanion(CompanionType type) async {
    if (_selected == type) return;
    _selected = type;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'selected_companion',
        type == CompanionType.deer ? 'deer' : 'rabbit',
      );
    } catch (e) {
      debugPrint('[CompanionManager] Error saving selection: $e');
    }
  }
}

/// Data class holding deer animation asset paths.
class DeerAssets {
  static const String idle = 'assets/deer/deer_idle.gif';
  static const String walk = 'assets/deer/deer_walk.gif';
  static const String jump = 'assets/deer/deer_jump.gif';

  static String getAsset(CompanionAnimState state) {
    switch (state) {
      case CompanionAnimState.idle:
        return idle;
      case CompanionAnimState.walk:
        return walk;
      case CompanionAnimState.jump:
      case CompanionAnimState.celebrate:
        return jump;
    }
  }
}

/// Lightweight animated deer widget using GIF assets.
/// Uses RepaintBoundary to isolate from parent rebuilds.
class DeerSprite extends StatelessWidget {
  final CompanionAnimState animState;
  final double scale;
  final bool flipHorizontal;

  const DeerSprite({
    Key? key,
    this.animState = CompanionAnimState.idle,
    this.scale = 2.4,
    this.flipHorizontal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assetPath = DeerAssets.getAsset(animState);

    return RepaintBoundary(
      child: Transform.scale(
        scale: scale,
        child: Transform(
          alignment: Alignment.center,
          transform: flipHorizontal
              ? (Matrix4.identity()..scale(-1.0, 1.0, 1.0))
              : Matrix4.identity(),
          child: Image.asset(
            assetPath,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('[DeerSprite] Error loading $assetPath: $error');
              return const SizedBox(width: 32, height: 32);
            },
          ),
        ),
      ),
    );
  }
}

/// Deer widget with tap interaction — tapping makes it jump.
class InteractiveDeerSprite extends StatefulWidget {
  final double scale;

  const InteractiveDeerSprite({Key? key, this.scale = 2.4}) : super(key: key);

  @override
  State<InteractiveDeerSprite> createState() => _InteractiveDeerSpriteState();
}

class _InteractiveDeerSpriteState extends State<InteractiveDeerSprite> {
  CompanionAnimState _animState = CompanionAnimState.idle;
  Timer? _revertTimer;

  @override
  void dispose() {
    _revertTimer?.cancel();
    super.dispose();
  }

  void _onTap() {
    _revertTimer?.cancel();
    setState(() {
      _animState = CompanionAnimState.jump;
    });
    _revertTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _animState = CompanionAnimState.idle;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: DeerSprite(
        animState: _animState,
        scale: widget.scale,
      ),
    );
  }
}

/// Header companion widget for HomeScreen: shows selected companion (rabbit or deer).
class SelectedCompanionHeaderWidget extends StatelessWidget {
  const SelectedCompanionHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CompanionManager.instance,
      builder: (context, _) {
        if (CompanionManager.instance.isDeer) {
          return const Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: InteractiveDeerSprite(scale: 2.2),
          );
        }

        return AnimatedBuilder(
          animation: RabbitController.instance,
          builder: (context, _) {
            if (RabbitController.instance.state != RabbitState.sleeping) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => RabbitController.instance.onTapRabbit(context),
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IsolatedRabbitSprite(
                  animation: RabbitController.instance.currentAnimation,
                  scale: 2.2,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Note editor companion widget: shows selected companion icon in note header.
class SelectedCompanionNoteWidget extends StatelessWidget {
  final double scale;

  const SelectedCompanionNoteWidget({Key? key, this.scale = 2.2}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CompanionManager.instance,
      builder: (context, _) {
        if (CompanionManager.instance.isDeer) {
          return InteractiveDeerSprite(scale: scale);
        }
        return IsolatedRabbitSprite(
          animation: RabbitAnimation.note19,
          scale: scale,
        );
      },
    );
  }
}

/// Unified Companion Overlay for main navigation shell.
/// Seamlessly delegates to RabbitWidget or DeerWidget depending on active choice.
class UnifiedCompanionOverlay extends StatelessWidget {
  final Widget child;

  const UnifiedCompanionOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CompanionManager.instance,
      builder: (context, _) {
        if (CompanionManager.instance.isDeer) {
          return Stack(
            children: [
              child,
              const Positioned(
                bottom: 80,
                right: 20,
                child: InteractiveDeerSprite(scale: 2.4),
              ),
            ],
          );
        }

        return RabbitOverlay(child: child);
      },
    );
  }
}
