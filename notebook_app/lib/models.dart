import 'package:flutter/material.dart';

class PlacedSticker {
  final String id;
  final String assetPath;
  double x;
  double y;
  double width;
  double height;
  double rotation;
  bool isLocked;

  PlacedSticker({
    required this.id,
    required this.assetPath,
    required this.x,
    required this.y,
    this.width = 100.0,
    this.height = 100.0,
    this.rotation = 0.0,
    this.isLocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assetPath': assetPath,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
      'isLocked': isLocked,
    };
  }

  factory PlacedSticker.fromMap(Map<String, dynamic> map) {
    return PlacedSticker(
      id: map['id'] ?? '',
      assetPath: map['assetPath'] ?? '',
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      width: (map['width'] as num?)?.toDouble() ?? 100.0,
      height: (map['height'] as num?)?.toDouble() ?? 100.0,
      rotation: (map['rotation'] as num?)?.toDouble() ?? 0.0,
      isLocked: map['isLocked'] ?? false,
    );
  }
}

class ChecklistItem {
  final String id;
  String text;
  bool isDone;

  ChecklistItem({
    required this.id,
    required this.text,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isDone': isDone,
    };
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      isDone: map['isDone'] ?? false,
    );
  }
}

enum StrokeType { none, pen, highlighter, eraser, rectangle, lasso }

class DrawnStroke {
  final String id;
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final StrokeType type;
  bool isSelected;

  DrawnStroke({
    required this.id,
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.type = StrokeType.pen,
    this.isSelected = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'color': color.value,
      'strokeWidth': strokeWidth,
      'type': type.name,
    };
  }

  factory DrawnStroke.fromMap(Map<String, dynamic> map) {
    final pointsList = (map['points'] as List<dynamic>?)
            ?.map((p) => Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble()))
            .toList() ??
        [];
    final strokeType = StrokeType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => StrokeType.pen,
    );
    return DrawnStroke(
      id: map['id'] ?? '',
      points: pointsList,
      color: Color(map['color'] ?? 0xFF000000),
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 3.0,
      type: strokeType,
    );
  }
}

class TextBoxItem {
  final String id;
  String text;
  double x;
  double y;
  double fontSize;
  int colorValue;

  TextBoxItem({
    required this.id,
    required this.text,
    required this.x,
    required this.y,
    this.fontSize = 18.0,
    this.colorValue = 0xFF000000,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'x': x,
      'y': y,
      'fontSize': fontSize,
      'colorValue': colorValue,
    };
  }

  factory TextBoxItem.fromMap(Map<String, dynamic> map) {
    return TextBoxItem(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 18.0,
      colorValue: map['colorValue'] ?? 0xFF000000,
    );
  }
}

class AudioMemoItem {
  final String id;
  final String title;
  final String audioPath;
  final int durationSeconds;
  final DateTime createdAt;

  AudioMemoItem({
    required this.id,
    required this.title,
    required this.audioPath,
    required this.durationSeconds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'audioPath': audioPath,
      'durationSeconds': durationSeconds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AudioMemoItem.fromMap(Map<String, dynamic> map) {
    return AudioMemoItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      audioPath: map['audioPath'] ?? '',
      durationSeconds: map['durationSeconds'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class TextHighlight {
  final String id;
  int start;
  int end;
  int colorValue;

  TextHighlight({
    required this.id,
    required this.start,
    required this.end,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start': start,
      'end': end,
      'colorValue': colorValue,
    };
  }

  factory TextHighlight.fromMap(Map<String, dynamic> map) {
    return TextHighlight(
      id: map['id'] ?? '',
      start: map['start'] ?? 0,
      end: map['end'] ?? 0,
      colorValue: map['colorValue'] ?? 0xFFFFF59D,
    );
  }
}

enum PageTemplateType { standard, cornell, weeklyPlanner, habitTracker, todoList }

class NotebookPage {
  final String id;
  final String notebookId;
  String title;
  String content;
  DateTime date;
  DateTime lastModified;
  String? paperBackground;
  PageTemplateType templateType;
  String cueText;
  String summaryText;
  String? pdfPath;
  bool isRtl;
  List<TextHighlight> textHighlights;
  List<AudioMemoItem> audioMemos;
  List<ChecklistItem> checklist;
  List<PlacedSticker> stickers;
  List<String> images;
  List<DrawnStroke> strokes;
  List<TextBoxItem> textBoxes;

  NotebookPage({
    required this.id,
    required this.notebookId,
    required this.title,
    required this.content,
    required this.date,
    required this.lastModified,
    this.paperBackground,
    this.templateType = PageTemplateType.standard,
    this.cueText = '',
    this.summaryText = '',
    this.pdfPath,
    this.isRtl = false,
    List<TextHighlight>? textHighlights,
    List<AudioMemoItem>? audioMemos,
    List<ChecklistItem>? checklist,
    List<PlacedSticker>? stickers,
    List<String>? images,
    List<DrawnStroke>? strokes,
    List<TextBoxItem>? textBoxes,
  })  : textHighlights = textHighlights ?? [],
        audioMemos = audioMemos ?? [],
        checklist = checklist ?? [],
        stickers = stickers ?? [],
        images = images ?? [],
        strokes = strokes ?? [],
        textBoxes = textBoxes ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'notebookId': notebookId,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'paperBackground': paperBackground,
      'templateType': templateType.name,
      'cueText': cueText,
      'summaryText': summaryText,
      'pdfPath': pdfPath,
      'isRtl': isRtl,
      'textHighlights': textHighlights.map((x) => x.toMap()).toList(),
      'audioMemos': audioMemos.map((x) => x.toMap()).toList(),
      'checklist': checklist.map((x) => x.toMap()).toList(),
      'stickers': stickers.map((x) => x.toMap()).toList(),
      'images': images,
      'strokes': strokes.map((x) => x.toMap()).toList(),
      'textBoxes': textBoxes.map((x) => x.toMap()).toList(),
    };
  }

  factory NotebookPage.fromMap(Map<String, dynamic> map) {
    final tType = PageTemplateType.values.firstWhere(
      (e) => e.name == map['templateType'],
      orElse: () => PageTemplateType.standard,
    );

    return NotebookPage(
      id: map['id'] ?? '',
      notebookId: map['notebookId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.parse(map['date']),
      lastModified: DateTime.parse(map['lastModified']),
      paperBackground: map['paperBackground'],
      templateType: tType,
      cueText: map['cueText'] ?? '',
      summaryText: map['summaryText'] ?? '',
      pdfPath: map['pdfPath'],
      isRtl: map['isRtl'] ?? false,
      textHighlights: (map['textHighlights'] as List<dynamic>?)
              ?.map((x) => TextHighlight.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      audioMemos: (map['audioMemos'] as List<dynamic>?)
              ?.map((x) => AudioMemoItem.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      checklist: (map['checklist'] as List<dynamic>?)
              ?.map((x) => ChecklistItem.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      stickers: (map['stickers'] as List<dynamic>?)
              ?.map((x) => PlacedSticker.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      images: (map['images'] as List<dynamic>?)?.map((x) => x.toString()).toList() ?? [],
      strokes: (map['strokes'] as List<dynamic>?)
              ?.map((x) => DrawnStroke.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      textBoxes: (map['textBoxes'] as List<dynamic>?)
              ?.map((x) => TextBoxItem.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Notebook {
  final String id;
  String name;
  String coverAsset;
  String? folderId;
  DateTime createdAt;
  DateTime lastModified;
  int studyTimeSeconds;

  Notebook({
    required this.id,
    required this.name,
    required this.coverAsset,
    this.folderId,
    required this.createdAt,
    required this.lastModified,
    this.studyTimeSeconds = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coverAsset': coverAsset,
      'folderId': folderId,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'studyTimeSeconds': studyTimeSeconds,
    };
  }

  factory Notebook.fromMap(Map<String, dynamic> map) {
    return Notebook(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      coverAsset: map['coverAsset'] ?? '',
      folderId: map['folderId'],
      createdAt: DateTime.parse(map['createdAt']),
      lastModified: DateTime.parse(map['lastModified']),
      studyTimeSeconds: map['studyTimeSeconds'] ?? 0,
    );
  }
}

class AgendaEvent {
  final String id;
  String title;
  DateTime date;
  String startTime;
  String endTime;
  String? note;
  int colorValue;
  bool hasReminder;
  int reminderMinutesBefore;
  List<PlacedSticker> stickers;

  AgendaEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.note,
    this.colorValue = 0xFFFFFFFF,
    this.hasReminder = true,
    this.reminderMinutesBefore = 30,
    List<PlacedSticker>? stickers,
  }) : stickers = stickers ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'note': note,
      'colorValue': colorValue,
      'hasReminder': hasReminder,
      'reminderMinutesBefore': reminderMinutesBefore,
      'stickers': stickers.map((x) => x.toMap()).toList(),
    };
  }

  factory AgendaEvent.fromMap(Map<String, dynamic> map) {
    return AgendaEvent(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      date: DateTime.parse(map['date']),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      note: map['note'],
      colorValue: map['colorValue'] ?? 0xFFFFFFFF,
      hasReminder: map['hasReminder'] ?? true,
      reminderMinutesBefore: map['reminderMinutesBefore'] ?? 30,
      stickers: (map['stickers'] as List<dynamic>?)
              ?.map((x) => PlacedSticker.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class HistoryFolder {
  final String id;
  String name;
  String iconAsset;

  HistoryFolder({
    required this.id,
    required this.name,
    required this.iconAsset,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconAsset': iconAsset,
    };
  }

  factory HistoryFolder.fromMap(Map<String, dynamic> map) {
    return HistoryFolder(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      iconAsset: map['iconAsset'] ?? '',
    );
  }
}

