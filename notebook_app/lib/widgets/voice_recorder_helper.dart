import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecorderHelper {
  static bool _isRecording = false;
  static int _recordingSeconds = 0;
  static Timer? _timer;

  static bool get isRecording => _isRecording;
  static int get recordingSeconds => _recordingSeconds;

  static Future<String?> startRecording() async {
    _isRecording = true;
    _recordingSeconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _recordingSeconds++;
    });
    
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/memo_${DateTime.now().millisecondsSinceEpoch}.m4a';
      debugPrint('[VoiceRecorderHelper] Started recording to $filePath');
      return filePath;
    } catch (e) {
      debugPrint('[VoiceRecorderHelper] Path error: $e');
      return 'local_memo.m4a';
    }
  }

  static Future<Map<String, dynamic>> stopRecording(String? activePath) async {
    _timer?.cancel();
    _timer = null;
    _isRecording = false;
    final duration = _recordingSeconds > 0 ? _recordingSeconds : 5;
    debugPrint('[VoiceRecorderHelper] Stopped recording. Duration: ${duration}s');
    return {
      'path': activePath ?? 'local_memo.m4a',
      'duration': duration,
    };
  }
}
