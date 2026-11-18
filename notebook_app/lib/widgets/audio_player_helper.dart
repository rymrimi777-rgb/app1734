import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

/// Singleton audio player helper for playing sound assets.
/// Manages a single AudioPlayer instance to prevent duplicate playback.
class AudioPlayerHelper {
  static AudioPlayer? _player;
  static double _volume = 1.0;

  /// Initialize or get the shared AudioPlayer instance.
  static AudioPlayer _getPlayer() {
    _player ??= AudioPlayer();
    return _player!;
  }

  /// Set the playback volume (0.0 to 1.0).
  static void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  /// Play a sound from the Flutter assets directory.
  /// [assetPath] should be like 'assets/sounds/alarme1.mp3'
  static Future<void> playSound(String assetPath) async {
    try {
      final player = _getPlayer();
      // Stop any currently playing sound first
      await player.stop();
      await player.setVolume(_volume);

      // audioplayers AssetSource expects path relative to assets/
      // e.g., 'sounds/alarme1.mp3' for 'assets/sounds/alarme1.mp3'
      String sourcePath = assetPath;
      if (sourcePath.startsWith('assets/')) {
        sourcePath = sourcePath.substring(7); // Remove 'assets/' prefix
      }

      debugPrint('[AudioPlayerHelper] Playing sound: $assetPath (source: $sourcePath)');
      await player.play(AssetSource(sourcePath));
    } catch (e, stack) {
      debugPrint('[AudioPlayerHelper] Error playing sound "$assetPath": $e');
      debugPrint('[AudioPlayerHelper] Stack: $stack');
    }
  }

  /// Play the notification sound.
  static Future<void> playNotificationSound() async {
    await playSound('assets/audio/Notification sound.mp3');
  }

  /// Stop any currently playing sound.
  static Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (e) {
      debugPrint('[AudioPlayerHelper] Error stopping sound: $e');
    }
  }

  /// Dispose the audio player. Call when the app is being closed.
  static Future<void> dispose() async {
    try {
      await _player?.dispose();
      _player = null;
    } catch (e) {
      debugPrint('[AudioPlayerHelper] Error disposing player: $e');
    }
  }
}
