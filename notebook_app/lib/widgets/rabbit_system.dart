import 'dart:async';
import 'package:flutter/material.dart';

/// Strict Rabbit States
enum RabbitState {
  sleeping,     // Sleeping state near top of Home screen
  waking,       // Playing wake-up animation_17 ONCE
  walkingDown,  // Walking down toward bottom navigation (animation_03)
  resting,      // Resting/relaxing state (animation_04)
  movingRight,  // Moving toward right target (animation_05)
  movingLeft,   // Moving toward left target / returning home (animation_06)
  noteIdle,     // Stationary eating/nibbling in Note Editor (animation_19)
}

/// Rabbit Animation Identifiers
enum RabbitAnimation {
  sleep13,
  sleep15,
  wake17,
  walkDown03,
  rest04,
  walkRight05,
  walkLeft06,
  note19,
  morning24,
  evening27,
  pomodoro32,
}

class RabbitAnimationDetails {
  final String folder;
  final int frameCount;
  final double fps;

  const RabbitAnimationDetails({
    required this.folder,
    required this.frameCount,
    required this.fps,
  });
}

class RabbitAnimationRegistry {
  static const Map<RabbitAnimation, RabbitAnimationDetails> details = {
    RabbitAnimation.sleep13: RabbitAnimationDetails(folder: 'assets/rabbit/animation_13_frames', frameCount: 2, fps: 4.0),
    RabbitAnimation.sleep15: RabbitAnimationDetails(folder: 'assets/rabbit/animation_15_frames', frameCount: 2, fps: 4.0),
    RabbitAnimation.wake17: RabbitAnimationDetails(folder: 'assets/rabbit/animation_17_frames', frameCount: 9, fps: 9.0),
    RabbitAnimation.walkDown03: RabbitAnimationDetails(folder: 'assets/rabbit/animation_03_frames', frameCount: 6, fps: 9.0),
    RabbitAnimation.rest04: RabbitAnimationDetails(folder: 'assets/rabbit/animation_04_frames', frameCount: 6, fps: 5.0),
    RabbitAnimation.walkRight05: RabbitAnimationDetails(folder: 'assets/rabbit/animation_05_frames', frameCount: 6, fps: 9.0),
    RabbitAnimation.walkLeft06: RabbitAnimationDetails(folder: 'assets/rabbit/animation_06_frames', frameCount: 6, fps: 9.0),
    RabbitAnimation.note19: RabbitAnimationDetails(folder: 'assets/rabbit/animation_19_frames', frameCount: 9, fps: 7.0),
    RabbitAnimation.morning24: RabbitAnimationDetails(folder: 'assets/rabbit/animation_24_frames', frameCount: 9, fps: 8.0),
    RabbitAnimation.evening27: RabbitAnimationDetails(folder: 'assets/rabbit/animation_27_frames', frameCount: 8, fps: 6.0),
    RabbitAnimation.pomodoro32: RabbitAnimationDetails(folder: 'assets/rabbit/animation_32_frames', frameCount: 6, fps: 7.0),
  };
}

/// Lazy precaching manager - loads animation frames into memory only when needed
class RabbitPrecaster {
  static final Set<String> _loadedFolders = {};

  static void precache(BuildContext context) {
    loadForState(context, RabbitState.sleeping);
  }

  static void loadFolder(BuildContext context, String folder, int frameCount) {
    if (_loadedFolders.contains(folder)) return;
    _loadedFolders.add(folder);

    for (int i = 1; i <= frameCount; i++) {
      final frameStr = i.toString().padLeft(2, '0');
      final provider = ResizeImage(
        AssetImage('$folder/frame_$frameStr.png'),
        width: 64,
        height: 64,
      );
      precacheImage(provider, context);
    }
  }

  static void loadForState(BuildContext context, RabbitState state) {
    switch (state) {
      case RabbitState.sleeping:
        loadFolder(context, 'assets/rabbit/animation_13_frames', 2);
        loadFolder(context, 'assets/rabbit/animation_15_frames', 2);
        break;
      case RabbitState.waking:
        loadFolder(context, 'assets/rabbit/animation_17_frames', 9);
        break;
      case RabbitState.walkingDown:
        loadFolder(context, 'assets/rabbit/animation_03_frames', 6);
        loadFolder(context, 'assets/rabbit/animation_04_frames', 6);
        break;
      case RabbitState.resting:
        loadFolder(context, 'assets/rabbit/animation_04_frames', 6);
        break;
      case RabbitState.movingRight:
        loadFolder(context, 'assets/rabbit/animation_05_frames', 6);
        loadFolder(context, 'assets/rabbit/animation_04_frames', 6);
        break;
      case RabbitState.movingLeft:
        loadFolder(context, 'assets/rabbit/animation_06_frames', 6);
        loadFolder(context, 'assets/rabbit/animation_04_frames', 6);
        break;
      case RabbitState.noteIdle:
        loadFolder(context, 'assets/rabbit/animation_19_frames', 9);
        break;
    }
  }
}

/// Root Level Controller maintaining Rabbit State, Position, and Navigation transitions
class RabbitController extends ChangeNotifier {
  static final RabbitController instance = RabbitController._internal();
  factory RabbitController() => instance;

  RabbitController._internal();

  RabbitState _state = RabbitState.sleeping;
  RabbitAnimation _currentAnimation = RabbitAnimation.sleep13;
  Offset _position = const Offset(24, 135); // Initial sleeping resting position near top
  Offset? _targetPosition;
  bool _isMoving = false;
  int _currentTabIndex = 0;
  Duration _moveDuration = const Duration(milliseconds: 400);
  Curve _moveCurve = Curves.easeInOut;

  RabbitState get state => _state;
  RabbitAnimation get currentAnimation => _currentAnimation;
  Offset get position => _position;
  Offset? get targetPosition => _targetPosition;
  bool get isMoving => _isMoving;
  Duration get moveDuration => _moveDuration;
  Curve get moveCurve => _moveCurve;

  /// Triggered on App / Home open
  void initHomeState() {
    _state = RabbitState.sleeping;
    _currentAnimation = RabbitAnimation.sleep13;
    _isMoving = false;
    _position = const Offset(24, 135);
    _targetPosition = null;
    notifyListeners();
  }

  /// Triggered when user taps sleeping rabbit
  void onTapRabbit(BuildContext context) {
    if (_state == RabbitState.sleeping) {
      _state = RabbitState.waking;
      _currentAnimation = RabbitAnimation.wake17;
      _isMoving = false;
      RabbitPrecaster.loadForState(context, RabbitState.waking);
      RabbitPrecaster.loadForState(context, RabbitState.walkingDown);
      notifyListeners();
    }
  }

  /// Called when wake-up (animation_17) completes
  void onWakeUpComplete(double screenWidth, double screenHeight) {
    if (_state != RabbitState.waking) return;
    
    // Start downward movement to bottom home tab
    final targetX = (screenWidth / 5.0) * 0.5 - 25;
    final targetY = screenHeight - 115;
    _targetPosition = Offset(targetX, targetY);
    _moveDuration = const Duration(milliseconds: 600);
    _moveCurve = Curves.bounceOut;

    _state = RabbitState.walkingDown;
    _currentAnimation = RabbitAnimation.walkDown03;
    _isMoving = true;
    notifyListeners();
  }

  /// Triggered when tab navigation happens
  void moveToTab(int tabIndex, double screenWidth, double screenHeight) {
    final oldTabIndex = _currentTabIndex;
    _currentTabIndex = tabIndex;

    // If sleeping at top, wake up first
    if (_state == RabbitState.sleeping) {
      _state = RabbitState.waking;
      _currentAnimation = RabbitAnimation.wake17;
      _isMoving = false;
      notifyListeners();
      return;
    }

    final tabWidth = screenWidth / 5.0;
    final targetX = (tabIndex + 0.5) * tabWidth - 25;
    final targetY = screenHeight - 115;
    final targetOffset = Offset(targetX, targetY);

    if ((targetOffset - _position).distance < 2.0) return;

    if (tabIndex > oldTabIndex) {
      _state = RabbitState.movingRight;
      _currentAnimation = RabbitAnimation.walkRight05;
    } else {
      _state = RabbitState.movingLeft;
      _currentAnimation = RabbitAnimation.walkLeft06;
    }

    _targetPosition = targetOffset;
    final dist = (targetOffset - _position).distance;
    _moveDuration = Duration(milliseconds: ((dist / tabWidth) * 350).clamp(250, 800).toInt());
    _moveCurve = Curves.easeInOut;
    _isMoving = true;
    notifyListeners();
  }

  /// Triggered when reaching destination
  void onTargetReached() {
    _isMoving = false;
    _position = _targetPosition ?? _position;
    _targetPosition = null;

    // STOP walking animation completely -> Transition to resting (animation_04)
    _state = RabbitState.resting;
    _currentAnimation = RabbitAnimation.rest04;
    notifyListeners();
  }

  void walkTo(Offset target, {VoidCallback? onArrived}) {
    if (_state == RabbitState.sleeping) return;

    final isMovingRight = target.dx > _position.dx;
    _state = isMovingRight ? RabbitState.movingRight : RabbitState.movingLeft;
    _currentAnimation = isMovingRight ? RabbitAnimation.walkRight05 : RabbitAnimation.walkLeft06;
    _targetPosition = target;
    final dist = (target - _position).distance;
    _moveDuration = Duration(milliseconds: ((dist / 180.0) * 500).clamp(250, 800).toInt());
    _moveCurve = Curves.easeInOut;
    _isMoving = true;
    notifyListeners();

    if (onArrived != null) {
      Future.delayed(_moveDuration, onArrived);
    }
  }

  /// Triggered when entering Note Editor screen
  void enterNoteEditor(double screenWidth) {
    final targetX = (screenWidth - 70).clamp(20.0, screenWidth - 40);
    const targetY = 70.0;
    _position = Offset(targetX, targetY);
    _targetPosition = null;
    _isMoving = false;
    _state = RabbitState.noteIdle;
    _currentAnimation = RabbitAnimation.note19;
    notifyListeners();
  }

  void enterPageEditor(double screenWidth) => enterNoteEditor(screenWidth);

  /// Triggered when leaving Note Editor screen
  void exitNoteEditor(double screenWidth, double screenHeight) {
    if (_state == RabbitState.noteIdle) {
      moveToTab(_currentTabIndex, screenWidth, screenHeight);
    }
  }

  void exitPageEditor(double screenWidth, double screenHeight) => exitNoteEditor(screenWidth, screenHeight);

  void updatePosition(Offset newPos) {
    _position = newPos;
  }

  void switchSleepAnimation() {
    if (_state == RabbitState.sleeping) {
      _currentAnimation = (_currentAnimation == RabbitAnimation.sleep13)
          ? RabbitAnimation.sleep15
          : RabbitAnimation.sleep13;
      notifyListeners();
    }
  }
}

/// Isolated Frame Animation Widget
/// Rebuilds ONLY its own frame layer when ticks occur, without rebuilding parent screens
class IsolatedRabbitSprite extends StatefulWidget {
  final RabbitAnimation animation;
  final VoidCallback? onComplete;
  final double scale;

  const IsolatedRabbitSprite({
    Key? key,
    required this.animation,
    this.onComplete,
    this.scale = 2.4,
  }) : super(key: key);

  @override
  State<IsolatedRabbitSprite> createState() => _IsolatedRabbitSpriteState();
}

class _IsolatedRabbitSpriteState extends State<IsolatedRabbitSprite> {
  Timer? _frameTimer;
  final ValueNotifier<int> _currentFrameNotifier = ValueNotifier<int>(1);

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(IsolatedRabbitSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _stopAnimation();
      _startAnimation();
    }
  }

  void _stopAnimation() {
    _frameTimer?.cancel();
    _frameTimer = null;
  }

  void _startAnimation() {
    final details = RabbitAnimationRegistry.details[widget.animation] ??
        RabbitAnimationRegistry.details[RabbitAnimation.rest04]!;

    _currentFrameNotifier.value = 1;
    final intervalMs = (1000.0 / details.fps).round();

    _frameTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      int nextFrame = _currentFrameNotifier.value + 1;
      if (nextFrame > details.frameCount) {
        // Handle non-looping wake-up animation
        if (widget.animation == RabbitAnimation.wake17) {
          _stopAnimation();
          if (widget.onComplete != null) widget.onComplete!();
          return;
        }

        // Handle sleeping sequence toggle
        if (widget.animation == RabbitAnimation.sleep13 || widget.animation == RabbitAnimation.sleep15) {
          RabbitController.instance.switchSleepAnimation();
          return;
        }

        nextFrame = 1; // Loop animation
      }
      _currentFrameNotifier.value = nextFrame;
    });
  }

  @override
  void dispose() {
    _stopAnimation();
    _currentFrameNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final details = RabbitAnimationRegistry.details[widget.animation] ??
        RabbitAnimationRegistry.details[RabbitAnimation.rest04]!;

    return RepaintBoundary(
      child: ValueListenableBuilder<int>(
        valueListenable: _currentFrameNotifier,
        builder: (context, frameIndex, child) {
          final frameStr = frameIndex.toString().padLeft(2, '0');
          final assetPath = '${details.folder}/frame_$frameStr.png';

          return Transform.scale(
            scale: widget.scale,
            child: Image.asset(
              assetPath,
              cacheWidth: 64,
              cacheHeight: 64,
              filterQuality: FilterQuality.none,
              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 32, height: 32),
            ),
          );
        },
      ),
    );
  }
}

/// Isolated Position Movement Widget
/// Rebuilds ONLY the position layer during position tweens without triggering parent screen rebuilds
class RabbitWidget extends StatefulWidget {
  final RabbitController controller;

  const RabbitWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<RabbitWidget> createState() => _RabbitWidgetState();
}

class _RabbitWidgetState extends State<RabbitWidget> with SingleTickerProviderStateMixin {
  late AnimationController _moveController;
  Animation<Offset>? _moveAnimation;
  Offset _startPos = const Offset(24, 135);

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      vsync: this,
      duration: widget.controller.moveDuration,
    );

    _moveController.addListener(() {
      if (_moveAnimation != null) {
        widget.controller.updatePosition(_moveAnimation!.value);
      }
    });

    _moveController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _moveAnimation = null;
        widget.controller.onTargetReached();
      }
    });

    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (widget.controller.isMoving && widget.controller.targetPosition != null) {
      _startPos = widget.controller.position;
      final target = widget.controller.targetPosition!;

      _moveAnimation = Tween<Offset>(
        begin: _startPos,
        end: target,
      ).animate(CurvedAnimation(
        parent: _moveController,
        curve: widget.controller.moveCurve,
      ));

      _moveController.stop();
      _moveController.duration = widget.controller.moveDuration;
      _moveController.forward(from: 0.0);
    } else if (!widget.controller.isMoving) {
      if (_moveController.isAnimating) {
        _moveController.stop();
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        // Hide global overlay rabbit if sleeping in Home header or active in Note Editor
        if (widget.controller.state == RabbitState.sleeping || widget.controller.state == RabbitState.noteIdle) {
          return const SizedBox.shrink();
        }

        final pos = widget.controller.position;

        return Positioned(
          left: pos.dx,
          top: pos.dy,
          child: RepaintBoundary(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.controller.onTapRabbit(context),
              child: IsolatedRabbitSprite(
                animation: widget.controller.currentAnimation,
                onComplete: () {
                  final size = MediaQuery.of(context).size;
                  widget.controller.onWakeUpComplete(size.width, size.height);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Root Stack Overlay wrapper for Main Shell Navigation
class RabbitOverlay extends StatelessWidget {
  final Widget child;

  const RabbitOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RabbitPrecaster.loadForState(context, RabbitState.sleeping);

    return Stack(
      children: [
        child,
        RabbitWidget(controller: RabbitController.instance),
      ],
    );
  }
}

