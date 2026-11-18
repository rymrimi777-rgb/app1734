import 'dart:async';
import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';
import 'audio_player_helper.dart';
import 'rabbit_notification_banner.dart';

class PomodoroFocusTimerSheet extends StatefulWidget {
  final Notebook? activeNotebook;

  const PomodoroFocusTimerSheet({Key? key, this.activeNotebook}) : super(key: key);

  @override
  State<PomodoroFocusTimerSheet> createState() => _PomodoroFocusTimerSheetState();
}

class _PomodoroFocusTimerSheetState extends State<PomodoroFocusTimerSheet> {
  static const int workDuration = 25 * 60; // 25 minutes
  static const int breakDuration = 5 * 60;  // 5 minutes

  int _remainingSeconds = workDuration;
  bool _isRunning = false;
  bool _isBreakMode = false;
  Timer? _timer;
  String _selectedSound = 'Rain Ambient';
  bool _isAudioPlaying = false;

  static const List<String> soundscapes = [
    'Rain Ambient',
    'Lo-Fi Study Beats',
    'Cafe Ambience',
    'Ocean Waves',
    'Mute',
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  Future<void> _playPomodoroSound() async {
    try {
      final soundPath = DataRepository().selectedPomodoroSound;
      debugPrint('[Pomodoro] Playing completion sound: $soundPath');
      await AudioPlayerHelper.playSound(soundPath);
    } catch (e) {
      debugPrint('[Pomodoro] Error playing pomodoro sound: $e');
    }
  }

  void _toggleTimer() {
    if (_isRunning) {
      // Pause — cancel timer
      _timer?.cancel();
      _timer = null;
      setState(() {
        _isRunning = false;
      });
    } else {
      // Start — ensure no duplicate timer
      _timer?.cancel();
      _timer = null;

      setState(() {
        _isRunning = true;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
          // Accumulate study time if active notebook present
          if (!_isBreakMode && widget.activeNotebook != null) {
            DataRepository().addStudyTime(widget.activeNotebook!.id, 1);
          }
        } else {
          // Session complete — cancel timer first to prevent duplicate
          timer.cancel();
          _timer = null;

          // Play completion sound
          _playPomodoroSound();

          if (mounted) {
            RabbitNotificationBanner.show(context, type: RabbitBannerType.pomodoro);
          }

          setState(() {
            _isBreakMode = !_isBreakMode;
            _remainingSeconds = _isBreakMode ? breakDuration : workDuration;
            _isRunning = false;
          });
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
      _remainingSeconds = _isBreakMode ? breakDuration : workDuration;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalDuration = _isBreakMode ? breakDuration : workDuration;
    final progress = 1.0 - (_remainingSeconds / totalDuration);

    final textColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final subTextColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey;
    final primaryColor = theme.primaryColor;

    final notebookTitle = widget.activeNotebook != null
        ? 'Notebook: ${widget.activeNotebook!.name}'
        : 'General Study Session';

    final totalStudyMins = widget.activeNotebook != null
        ? (widget.activeNotebook!.studyTimeSeconds ~/ 60)
        : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pomodoro Focus Timer',
                    style: TextStyle(
                      fontFamily: 'Essays1743',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    notebookTitle,
                    style: TextStyle(
                      fontFamily: 'Essays1743',
                      fontSize: 13,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: theme.iconTheme.color ?? textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Timer Circular Progress Ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isBreakMode ? Colors.green : primaryColor,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isBreakMode ? 'BREAK' : 'FOCUS',
                    style: TextStyle(
                      fontFamily: 'Essays1743',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: _isBreakMode ? Colors.green : subTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontFamily: 'Essays1743',
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (widget.activeNotebook != null)
                    Text(
                      'Total: $totalStudyMins mins',
                      style: TextStyle(
                        fontFamily: 'Essays1743',
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _toggleTimer,
                icon: Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                  color: isDark ? Colors.black : Colors.white,
                ),
                label: Text(
                  _isRunning ? 'Pause' : 'Start Focus',
                  style: TextStyle(
                    fontFamily: 'Essays1743',
                    color: isDark ? Colors.black : Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: textColor.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _resetTimer,
                icon: Icon(Icons.refresh, color: textColor),
                label: Text('Reset', style: TextStyle(fontFamily: 'Essays1743', color: textColor)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Lo-Fi Ambient Audio Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _selectedSound == 'Mute' ? Icons.volume_off : Icons.graphic_eq,
                      color: textColor.withOpacity(0.8),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedSound,
                      underline: const SizedBox(),
                      dropdownColor: theme.cardColor,
                      style: TextStyle(fontFamily: 'Essays1743', color: textColor, fontSize: 15),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSound = val;
                            _isAudioPlaying = val != 'Mute';
                          });
                        }
                      },
                      items: soundscapes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    ),
                  ],
                ),
                if (_selectedSound != 'Mute')
                  Icon(
                    _isAudioPlaying ? Icons.surround_sound : Icons.volume_mute,
                    color: textColor,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
