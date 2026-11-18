import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'asset_manifest.dart';
import 'theme.dart';

class DataRepository extends ChangeNotifier {
  static final DataRepository _instance = DataRepository._internal();
  factory DataRepository() => _instance;

  DataRepository._internal() {
    _loadFromDisk();
  }

  List<Notebook> _notebooks = [];
  List<NotebookPage> _pages = [];
  List<AgendaEvent> _agendaEvents = [];
  List<HistoryFolder> _folders = [];

  AppThemeMode _currentThemeMode = AppThemeMode.light;
  bool _isBiometricLockEnabled = false;
  String _paperStyle = 'Grid';
  String _userName = 'User';

  bool _notifyMorningRabbit = true;
  bool _notifyEveningRabbit = true;
  bool _notifyPomodoroRabbit = true;
  bool _notifyNewNote = true;
  bool _notifyReminder = true;
  String _selectedPomodoroSound = 'assets/sounds/alarme1.mp3';

  List<Notebook> get notebooks => _notebooks;
  List<NotebookPage> get pages => _pages;
  List<AgendaEvent> get agendaEvents => _agendaEvents;
  List<HistoryFolder> get folders => _folders;

  AppThemeMode get currentThemeMode => _currentThemeMode;
  bool get isBiometricLockEnabled => _isBiometricLockEnabled;
  String get paperStyle => _paperStyle;
  String get userName => _userName;

  bool get notifyMorningRabbit => _notifyMorningRabbit;
  bool get notifyEveningRabbit => _notifyEveningRabbit;
  bool get notifyPomodoroRabbit => _notifyPomodoroRabbit;
  bool get notifyNewNote => _notifyNewNote;
  bool get notifyReminder => _notifyReminder;
  String get selectedPomodoroSound => _selectedPomodoroSound;

  Future<void> _loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeIdx = prefs.getInt('app_theme_mode') ?? 0;
      if (themeIdx >= 0 && themeIdx < AppThemeMode.values.length) {
        _currentThemeMode = AppThemeMode.values[themeIdx];
      }

      _isBiometricLockEnabled = prefs.getBool('app_biometric_lock') ?? false;
      _paperStyle = prefs.getString('app_paper_style') ?? 'Grid';
      _userName = prefs.getString('app_user_name') ?? 'User';

      _notifyMorningRabbit = prefs.getBool('notify_morning_rabbit') ?? true;
      _notifyEveningRabbit = prefs.getBool('notify_evening_rabbit') ?? true;
      _notifyPomodoroRabbit = prefs.getBool('notify_pomodoro_rabbit') ?? true;
      _notifyNewNote = prefs.getBool('notify_new_note') ?? true;
      _notifyReminder = prefs.getBool('notify_reminder') ?? true;
      _selectedPomodoroSound = prefs.getString('selected_pomodoro_sound') ?? 'assets/sounds/alarme1.mp3';

      final notebooksJson = prefs.getString('saved_notebooks');
      final pagesJson = prefs.getString('saved_pages');
      final agendaJson = prefs.getString('saved_agenda');
      final foldersJson = prefs.getString('saved_folders');

      if (foldersJson != null) {
        final List<dynamic> decoded = jsonDecode(foldersJson);
        _folders = decoded.map((x) => HistoryFolder.fromMap(x)).toList();
      } else {
        _initDefaultFolders();
      }

      if (notebooksJson != null) {
        final List<dynamic> decoded = jsonDecode(notebooksJson);
        _notebooks = decoded.map((x) => Notebook.fromMap(x)).toList();
      } else {
        _initDefaultNotebooks();
      }

      if (pagesJson != null) {
        final List<dynamic> decoded = jsonDecode(pagesJson);
        _pages = decoded.map((x) => NotebookPage.fromMap(x)).toList();
      }

      if (agendaJson != null) {
        final List<dynamic> decoded = jsonDecode(agendaJson);
        _agendaEvents = decoded.map((x) => AgendaEvent.fromMap(x)).toList();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading from disk: $e');
      _initDefaultData();
    }
  }

  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final notebooksJson = jsonEncode(_notebooks.map((n) => n.toMap()).toList());
      final pagesJson = jsonEncode(_pages.map((p) => p.toMap()).toList());
      final agendaJson = jsonEncode(_agendaEvents.map((a) => a.toMap()).toList());
      final foldersJson = jsonEncode(_folders.map((f) => f.toMap()).toList());

      await prefs.setString('saved_notebooks', notebooksJson);
      await prefs.setString('saved_pages', pagesJson);
      await prefs.setString('saved_agenda', agendaJson);
      await prefs.setString('saved_folders', foldersJson);
    } catch (e) {
      debugPrint('Error saving to disk: $e');
    }
  }

  void _initDefaultFolders() {
    _folders = [
      HistoryFolder(id: 'f_school', name: 'School', iconAsset: AppAssets.historyIcons[0]),
      HistoryFolder(id: 'f_projects', name: 'Projects', iconAsset: AppAssets.historyIcons[1]),
      HistoryFolder(id: 'f_personal', name: 'Personal', iconAsset: AppAssets.historyIcons[2]),
      HistoryFolder(id: 'f_ideas', name: 'Ideas', iconAsset: AppAssets.historyIcons[3]),
    ];
  }

  void _initDefaultNotebooks() {
    final now = DateTime.now();
    _notebooks = [
      Notebook(
        id: 'nb_diary',
        name: 'My Diary',
        coverAsset: AppAssets.covers[0],
        folderId: 'f_personal',
        createdAt: now.subtract(const Duration(days: 10)),
        lastModified: now,
      ),
      Notebook(
        id: 'nb_study',
        name: 'Study',
        coverAsset: AppAssets.covers[1 % AppAssets.covers.length],
        folderId: 'f_school',
        createdAt: now.subtract(const Duration(days: 8)),
        lastModified: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }

  void _initDefaultData() {
    _initDefaultFolders();
    _initDefaultNotebooks();
  }

  // Notebook Operations
  void addNotebook(Notebook notebook) {
    _notebooks.add(notebook);
    _saveToDisk();
    notifyListeners();
  }

  void updateNotebook(Notebook notebook) {
    final idx = _notebooks.indexWhere((n) => n.id == notebook.id);
    if (idx != -1) {
      _notebooks[idx] = notebook;
      _saveToDisk();
      notifyListeners();
    }
  }

  void deleteNotebook(String id) {
    _notebooks.removeWhere((n) => n.id == id);
    _pages.removeWhere((p) => p.notebookId == id);
    _saveToDisk();
    notifyListeners();
  }

  // Page Operations
  List<NotebookPage> getPagesForNotebook(String notebookId) {
    return _pages.where((p) => p.notebookId == notebookId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void savePage(NotebookPage page) {
    final idx = _pages.indexWhere((p) => p.id == page.id);
    if (idx != -1) {
      _pages[idx] = page;
    } else {
      _pages.add(page);
    }
    final nIdx = _notebooks.indexWhere((n) => n.id == page.notebookId);
    if (nIdx != -1) {
      _notebooks[nIdx].lastModified = DateTime.now();
    }
    _saveToDisk();
    notifyListeners();
  }

  void deletePage(String pageId) {
    _pages.removeWhere((p) => p.id == pageId);
    _saveToDisk();
    notifyListeners();
  }

  // Agenda Operations
  List<AgendaEvent> getEventsForDate(DateTime date) {
    return _agendaEvents.where((e) =>
        e.date.year == date.year &&
        e.date.month == date.month &&
        e.date.day == date.day).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<AgendaEvent> getEventsForDateRange(DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return _agendaEvents.where((e) {
      final eDay = DateTime(e.date.year, e.date.month, e.date.day);
      return !eDay.isBefore(startDay) && !eDay.isAfter(endDay);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  void saveAgendaEvent(AgendaEvent event) {
    final idx = _agendaEvents.indexWhere((e) => e.id == event.id);
    if (idx != -1) {
      _agendaEvents[idx] = event;
    } else {
      _agendaEvents.add(event);
    }
    _saveToDisk();
    notifyListeners();
  }

  void deleteAgendaEvent(String id) {
    _agendaEvents.removeWhere((e) => e.id == id);
    _saveToDisk();
    notifyListeners();
  }

  void addStudyTime(String notebookId, int seconds) {
    final idx = _notebooks.indexWhere((n) => n.id == notebookId);
    if (idx != -1) {
      _notebooks[idx].studyTimeSeconds += seconds;
      _saveToDisk();
      notifyListeners();
    }
  }

  // Global Search across notebooks, pages, text boxes, and events
  Map<String, dynamic> searchAll(String query) {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) return {'notebooks': [], 'pages': [], 'events': []};

    final matchedNotebooks = _notebooks.where((n) => n.name.toLowerCase().contains(cleanQuery)).toList();
    final matchedPages = _pages.where((p) {
      final inTitle = p.title.toLowerCase().contains(cleanQuery);
      final inContent = p.content.toLowerCase().contains(cleanQuery);
      final inCue = p.cueText.toLowerCase().contains(cleanQuery);
      final inSummary = p.summaryText.toLowerCase().contains(cleanQuery);
      final inTextBoxes = p.textBoxes.any((tb) => tb.text.toLowerCase().contains(cleanQuery));
      return inTitle || inContent || inCue || inSummary || inTextBoxes;
    }).toList();

    final matchedEvents = _agendaEvents.where((e) {
      final inTitle = e.title.toLowerCase().contains(cleanQuery);
      final inNote = e.note != null && e.note!.toLowerCase().contains(cleanQuery);
      return inTitle || inNote;
    }).toList();

    return {
      'notebooks': matchedNotebooks,
      'pages': matchedPages,
      'events': matchedEvents,
    };
  }

  // Export / Import Backup Data
  String exportDataJson() {
    final data = {
      'version': 1,
      'exportDate': DateTime.now().toIso8601String(),
      'notebooks': _notebooks.map((n) => n.toMap()).toList(),
      'pages': _pages.map((p) => p.toMap()).toList(),
      'agendaEvents': _agendaEvents.map((a) => a.toMap()).toList(),
      'folders': _folders.map((f) => f.toMap()).toList(),
    };
    return jsonEncode(data);
  }

  bool importDataJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      if (decoded.containsKey('notebooks')) {
        _notebooks = (decoded['notebooks'] as List).map((x) => Notebook.fromMap(x)).toList();
      }
      if (decoded.containsKey('pages')) {
        _pages = (decoded['pages'] as List).map((x) => NotebookPage.fromMap(x)).toList();
      }
      if (decoded.containsKey('agendaEvents')) {
        _agendaEvents = (decoded['agendaEvents'] as List).map((x) => AgendaEvent.fromMap(x)).toList();
      }
      if (decoded.containsKey('folders')) {
        _folders = (decoded['folders'] as List).map((x) => HistoryFolder.fromMap(x)).toList();
      }
      _saveToDisk();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error importing JSON data: $e');
      return false;
    }
  }

  // Theme & Preferences Operations
  void setThemeMode(AppThemeMode mode) async {
    _currentThemeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('app_theme_mode', mode.index);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  void setBiometricLock(bool enabled) async {
    _isBiometricLockEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('app_biometric_lock', enabled);
    } catch (e) {
      debugPrint('Error saving biometric lock: $e');
    }
  }

  void setPaperStyle(String style) async {
    _paperStyle = style;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_paper_style', style);
    } catch (e) {
      debugPrint('Error saving paper style: $e');
    }
  }

  void setUserName(String name) async {
    _userName = name.trim().isEmpty ? 'User' : name.trim();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_user_name', _userName);
    } catch (e) {
      debugPrint('Error saving user name: $e');
    }
  }

  void setNotificationToggle(String key, bool enabled) async {
    switch (key) {
      case 'morning_rabbit':
        _notifyMorningRabbit = enabled;
        break;
      case 'evening_rabbit':
        _notifyEveningRabbit = enabled;
        break;
      case 'pomodoro_rabbit':
        _notifyPomodoroRabbit = enabled;
        break;
      case 'new_note':
        _notifyNewNote = enabled;
        break;
      case 'reminder':
        _notifyReminder = enabled;
        break;
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notify_$key', enabled);
    } catch (e) {
      debugPrint('Error saving notification toggle $key: $e');
    }
  }

  void setSelectedPomodoroSound(String soundPath) async {
    _selectedPomodoroSound = soundPath;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_pomodoro_sound', soundPath);
    } catch (e) {
      debugPrint('Error saving pomodoro sound: $e');
    }
  }

  // History Folder Operations
  void addFolder(HistoryFolder folder) {
    _folders.add(folder);
    _saveToDisk();
    notifyListeners();
  }

  void moveNotebookToFolder(String notebookId, String? folderId) {
    final idx = _notebooks.indexWhere((n) => n.id == notebookId);
    if (idx != -1) {
      _notebooks[idx].folderId = folderId;
      _saveToDisk();
      notifyListeners();
    }
  }
}
