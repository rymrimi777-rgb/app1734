import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models.dart';
import '../repository.dart';
import '../asset_manifest.dart';
import '../widgets/sticker_canvas.dart';
import '../widgets/drawing_toolbar_canvas.dart';
import '../widgets/templates.dart';
import '../widgets/annotation_widgets.dart';
import '../widgets/pomodoro_timer.dart';
import '../widgets/voice_recorder_helper.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/rabbit_system.dart';
import '../widgets/companion_system.dart';
import '../widgets/journal_security.dart';

class CoverPickerModal extends StatelessWidget {
  final Function(String coverPath) onCoverSelected;

  const CoverPickerModal({Key? key, required this.onCoverSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.85,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Notebook Cover',
                  style: TextStyle(
                    fontFamily: 'Essays1743',
                    fontSize: 20,
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
            Divider(color: theme.dividerColor),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: AppAssets.covers.length,
                itemBuilder: (context, index) {
                  final coverPath = AppAssets.covers[index];
                  return GestureDetector(
                    onTap: () {
                      onCoverSelected(coverPath);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor, width: 1),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.08),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          coverPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(child: Icon(Icons.book, size: 40, color: theme.disabledColor)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateNotebookDialog extends StatefulWidget {
  const CreateNotebookDialog({Key? key}) : super(key: key);

  @override
  State<CreateNotebookDialog> createState() => _CreateNotebookDialogState();
}

class _CreateNotebookDialogState extends State<CreateNotebookDialog> {
  final _nameController = TextEditingController();
  String _selectedCover = AppAssets.covers.isNotEmpty ? AppAssets.covers[0] : '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: Text(
        'New Notebook',
        style: TextStyle(
          fontFamily: 'Essays1743',
          fontWeight: FontWeight.bold,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(fontFamily: 'Essays1743', color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                labelText: 'Notebook Name',
                labelStyle: TextStyle(fontFamily: 'Essays1743', color: theme.textTheme.bodyMedium?.color),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.primaryColor)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Notebook Cover',
              style: TextStyle(fontFamily: 'Essays1743', fontSize: 15, color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => CoverPickerModal(
                    onCoverSelected: (cover) {
                      setState(() {
                        _selectedCover = cover;
                      });
                    },
                  ),
                );
              },
              child: Container(
                height: 140,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.asset(
                  _selectedCover,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.book, size: 40)),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontFamily: 'Essays1743')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              final now = DateTime.now();
              final newNotebook = Notebook(
                id: 'nb_${now.millisecondsSinceEpoch}',
                name: name,
                coverAsset: _selectedCover,
                createdAt: now,
                lastModified: now,
              );
              DataRepository().addNotebook(newNotebook);
              Navigator.pop(context);
            }
          },
          child: Text(
            'Create',
            style: TextStyle(
              fontFamily: 'Essays1743',
              color: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class NotebookDetailScreen extends StatefulWidget {
  final Notebook notebook;

  const NotebookDetailScreen({Key? key, required this.notebook}) : super(key: key);

  @override
  State<NotebookDetailScreen> createState() => _NotebookDetailScreenState();
}

class _NotebookDetailScreenState extends State<NotebookDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final repository = DataRepository();
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([repository, JournalSecurityService.instance]),
      builder: (context, child) {
        final pages = repository.getPagesForNotebook(widget.notebook.id);
        final studyMins = widget.notebook.studyTimeSeconds ~/ 60;
        final isLockEnabled = JournalSecurityService.instance.isLockEnabled;
        final isUnlocked = JournalSecurityService.instance.isUnlocked;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0.5,
            iconTheme: theme.iconTheme,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.notebook.name,
                  style: TextStyle(
                    fontFamily: 'Essays1743',
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Focused Study: $studyMins mins',
                  style: TextStyle(
                    fontFamily: 'Essays1743',
                    fontSize: 11,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            actions: [
              if (isLockEnabled)
                IconButton(
                  icon: Icon(
                    isUnlocked ? Icons.lock_open : Icons.lock,
                    color: isUnlocked ? Colors.green : Colors.amber.shade700,
                  ),
                  tooltip: isUnlocked ? 'Lock Journal' : 'Unlock Journal',
                  onPressed: () {
                    if (isUnlocked) {
                      JournalSecurityService.instance.lock();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Journal locked.')),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => const JournalUnlockDialog(),
                      );
                    }
                  },
                ),
              IconButton(
                icon: Icon(Icons.timer_outlined, color: theme.iconTheme.color),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => PomodoroFocusTimerSheet(activeNotebook: widget.notebook),
                  );
                },
                tooltip: 'Pomodoro Timer',
              ),
              IconButton(
                icon: Icon(Icons.add, color: theme.iconTheme.color),
                onPressed: () {
                  _openPageEditor(context, null);
                },
              ),
            ],
          ),
          body: pages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'This notebook is empty.',
                        style: TextStyle(
                          fontFamily: 'Essays1743',
                          fontSize: 16,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.primaryColor),
                        ),
                        onPressed: () => _openPageEditor(context, null),
                        child: Text(
                          '+ Add First Page',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontFamily: 'Essays1743',
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    final dateStr = DateFormat('MMM dd, yyyy').format(page.date);

                    String previewText;
                    if (page.content.startsWith('ENC:v1:')) {
                      if (isUnlocked) {
                        final dec = JournalSecurityService.instance.decryptString(page.content);
                        previewText = dec ?? '[Decrypted Note]';
                      } else {
                        previewText = '🔒 [Protected & Encrypted Entry • Tap to Unlock]';
                      }
                    } else if (page.content.isNotEmpty) {
                      previewText = page.content;
                    } else {
                      previewText = page.summaryText.isNotEmpty ? 'Summary: ${page.summaryText}' : 'Custom Canvas Notes';
                    }

                    return Card(
                      color: theme.cardColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      child: InkWell(
                        onTap: () => _openPageEditor(context, page),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          page.title.isEmpty ? 'Untitled Page' : page.title,
                                          style: TextStyle(
                                            fontFamily: 'Essays1743',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: theme.textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        if (page.content.startsWith('ENC:v1:')) ...[
                                          const SizedBox(width: 6),
                                          Icon(
                                            isUnlocked ? Icons.lock_open : Icons.lock,
                                            size: 16,
                                            color: isUnlocked ? Colors.green : Colors.amber.shade700,
                                          ),
                                        ],
                                        if (page.templateType != PageTemplateType.standard) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: theme.dividerColor,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              page.templateType.name.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Essays1743',
                                                color: theme.textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                      fontFamily: 'Essays1743',
                                      fontSize: 12,
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                previewText,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Essays1743',
                                  fontSize: 15,
                                  height: 1.4,
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                  fontStyle: page.content.startsWith('ENC:v1:') && !isUnlocked ? FontStyle.italic : FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _openPageEditor(BuildContext context, NotebookPage? existingPage) async {
    if (JournalSecurityService.instance.isLockEnabled && !JournalSecurityService.instance.isUnlocked) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => const JournalUnlockDialog(),
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageEditorScreen(
          notebookId: widget.notebook.id,
          page: existingPage,
        ),
      ),
    );
  }
}

class PageEditorScreen extends StatefulWidget {
  final String notebookId;
  final NotebookPage? page;

  const PageEditorScreen({Key? key, required this.notebookId, this.page})
      : super(key: key);

  @override
  State<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends State<PageEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _cueController;
  late TextEditingController _summaryController;
  late PageTemplateType _templateType;
  late List<ChecklistItem> _checklist;
  late List<PlacedSticker> _stickers;
  late List<String> _images;
  late List<DrawnStroke> _strokes;
  late List<TextBoxItem> _textBoxes;
  late List<AudioMemoItem> _audioMemos;
  late List<TextHighlight> _textHighlights;
  late bool _isRtl;
  String? _pdfPath;
  late DateTime _pageDate;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.page?.title ?? '');
    _cueController = TextEditingController(text: widget.page?.cueText ?? '');
    _summaryController = TextEditingController(text: widget.page?.summaryText ?? '');
    _templateType = widget.page?.templateType ?? PageTemplateType.standard;
    _pdfPath = widget.page?.pdfPath;
    _isRtl = widget.page?.isRtl ?? false;
    _textHighlights = widget.page != null
        ? widget.page!.textHighlights.map((e) => TextHighlight.fromMap(e.toMap())).toList()
        : [];
    String initialContent = widget.page?.content ?? '';
    if (initialContent.startsWith('ENC:v1:')) {
      final decrypted = JournalSecurityService.instance.decryptString(initialContent);
      if (decrypted != null) {
        initialContent = decrypted;
      }
    }
    _contentController = HighlightTextEditingController(
      text: initialContent,
      highlights: _textHighlights,
    );
    _audioMemos = widget.page != null
        ? widget.page!.audioMemos.map((e) => AudioMemoItem.fromMap(e.toMap())).toList()
        : [];
    _checklist = widget.page != null
        ? widget.page!.checklist.map((e) => ChecklistItem.fromMap(e.toMap())).toList()
        : [];
    _stickers = widget.page != null
        ? widget.page!.stickers.map((e) => PlacedSticker.fromMap(e.toMap())).toList()
        : [];
    _images = widget.page != null ? List<String>.from(widget.page!.images) : [];
    _strokes = widget.page != null
        ? widget.page!.strokes.map((e) => DrawnStroke.fromMap(e.toMap())).toList()
        : [];
    _textBoxes = widget.page != null
        ? widget.page!.textBoxes.map((e) => TextBoxItem.fromMap(e.toMap())).toList()
        : [];
    _pageDate = widget.page?.date ?? DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final size = MediaQuery.of(context).size;
        RabbitController.instance.enterPageEditor(size.width);
      }
    });
  }

  @override
  void dispose() {
    final windowSize = WidgetsBinding.instance.window.physicalSize / WidgetsBinding.instance.window.devicePixelRatio;
    RabbitController.instance.exitPageEditor(windowSize.width, windowSize.height);
    _titleController.dispose();
    _contentController.dispose();
    _cueController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _save() {
    final now = DateTime.now();
    String contentToSave = _contentController.text.trim();
    if (JournalSecurityService.instance.isLockEnabled && JournalSecurityService.instance.isUnlocked) {
      final enc = JournalSecurityService.instance.encryptString(contentToSave);
      if (enc != null) {
        contentToSave = enc;
      }
    }

    final page = NotebookPage(
      id: widget.page?.id ?? 'p_${now.millisecondsSinceEpoch}',
      notebookId: widget.notebookId,
      title: _titleController.text.trim(),
      content: contentToSave,
      date: _pageDate,
      lastModified: now,
      templateType: _templateType,
      cueText: _cueController.text.trim(),
      summaryText: _summaryController.text.trim(),
      pdfPath: _pdfPath,
      isRtl: _isRtl,
      textHighlights: _textHighlights,
      audioMemos: _audioMemos,
      checklist: _checklist,
      stickers: _stickers,
      images: _images,
      strokes: _strokes,
      textBoxes: _textBoxes,
    );
    DataRepository().savePage(page);
    Navigator.pop(context);
  }

  void _showHighlightPickerForSelection(int start, int end) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: HighlightColorPickerModal(
          onColorSelected: (colorVal) {
            setState(() {
              _textHighlights.removeWhere((h) => (h.start < end && h.end > start));
              _textHighlights.add(TextHighlight(
                id: 'hl_${DateTime.now().millisecondsSinceEpoch}',
                start: start,
                end: end,
                colorValue: colorVal,
              ));
              if (_contentController is HighlightTextEditingController) {
                (_contentController as HighlightTextEditingController).highlights = _textHighlights;
              }
            });
            Navigator.pop(context);
          },
          onRemove: () {
            setState(() {
              _textHighlights.removeWhere((h) => (h.start < end && h.end > start));
              if (_contentController is HighlightTextEditingController) {
                (_contentController as HighlightTextEditingController).highlights = _textHighlights;
              }
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _addAudioMemo() async {
    if (!kIsWeb) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Microphone Permission Required', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold)),
            content: const Text(
              '1734 Notebook requires Microphone access to record voice memos during lecture notes and study sessions. Please enable it in Settings.',
              style: TextStyle(fontFamily: 'Essays1743'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(fontFamily: 'Essays1743')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Open Settings', style: TextStyle(fontFamily: 'Essays1743')),
              ),
            ],
          ),
        );
        return;
      }
    }

    final titleCtrl = TextEditingController();
    String? activePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isRec = VoiceRecorderHelper.isRecording;
          final sec = VoiceRecorderHelper.recordingSeconds;

          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              isRec ? 'Recording Voice Memo...' : 'Record Voice Memo',
              style: TextStyle(
                fontFamily: 'Essays1743',
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(hintText: 'Voice Memo Label (e.g. Lecture Key Point)'),
                  style: TextStyle(fontFamily: 'Essays1743', color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    if (isRec) {
                      await VoiceRecorderHelper.stopRecording(activePath);
                      setDialogState(() {});
                    } else {
                      activePath = await VoiceRecorderHelper.startRecording();
                      setDialogState(() {});
                    }
                  },
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: isRec ? Colors.redAccent : Theme.of(context).primaryColor,
                    child: Icon(
                      isRec ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isRec ? 'Recording: ${sec}s (Tap to Stop)' : 'Tap Mic to Start Recording',
                  style: TextStyle(
                    fontFamily: 'Essays1743',
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final nav = Navigator.of(context);
                  if (VoiceRecorderHelper.isRecording) {
                    await VoiceRecorderHelper.stopRecording(activePath);
                  }
                  nav.pop();
                },
                child: Text('Cancel', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                onPressed: () async {
                  final nav = Navigator.of(context);
                  Map<String, dynamic> result = {'path': 'local_memo.m4a', 'duration': 15};
                  if (VoiceRecorderHelper.isRecording) {
                    result = await VoiceRecorderHelper.stopRecording(activePath);
                  }
                  setState(() {
                    _audioMemos.add(AudioMemoItem(
                      id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim().isEmpty ? 'Lecture Memo' : titleCtrl.text.trim(),
                      audioPath: result['path'] as String? ?? 'local_memo.m4a',
                      durationSeconds: result['duration'] as int? ?? 15,
                      createdAt: DateTime.now(),
                    ));
                  });
                  nav.pop();
                },
                child: Text(
                  'Save Memo',
                  style: TextStyle(
                    fontFamily: 'Essays1743',
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _importPdfSlide() {
    setState(() {
      _pdfPath = 'lecture_slides_chapter1.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF Lecture Slides imported! You can now draw or write annotations over them.'),
        backgroundColor: Colors.black,
      ),
    );
  }

  void _selectTemplateSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Page Layout Template', style: TextStyle(fontFamily: 'Essays1743', fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.border_color_outlined, color: theme.iconTheme.color),
              title: Text('Cornell Notes (Lecture & Study Grid)', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
              subtitle: Text('Header, Cue Column, Class Notes, and Summary on Grid Paper', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
              onTap: () {
                setState(() => _templateType = PageTemplateType.cornell);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.view_week_outlined, color: theme.iconTheme.color),
              title: Text('Weekly Planner & Goals', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
              subtitle: Text('7-day breakdown grid with target checklists', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
              onTap: () {
                setState(() => _templateType = PageTemplateType.weeklyPlanner);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.grid_on_outlined, color: theme.iconTheme.color),
              title: Text('Monthly Habit Tracker', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
              subtitle: Text('Interactive habit grid matrix', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
              onTap: () {
                setState(() => _templateType = PageTemplateType.habitTracker);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.notes, color: theme.iconTheme.color),
              title: Text('Standard Freeform Page', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
              onTap: () {
                setState(() => _templateType = PageTemplateType.standard);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _images.add(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking gallery image: $e');
    }
  }

  Widget _buildBodyForTemplate() {
    final theme = Theme.of(context);
    Widget contentWidget;
    if (_templateType == PageTemplateType.cornell) {
      contentWidget = CornellNotesWidget(
        titleController: _titleController,
        cueController: _cueController,
        notesController: _contentController,
        summaryController: _summaryController,
        onChanged: () {},
      );
    } else if (_templateType == PageTemplateType.weeklyPlanner) {
      contentWidget = WeeklyPlannerWidget(
        contentController: _contentController,
        onChanged: () {},
      );
    } else if (_templateType == PageTemplateType.habitTracker) {
      contentWidget = HabitTrackerWidget(
        onChanged: () {},
      );
    } else {
      contentWidget = SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    textAlign: _isRtl ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontFamily: _isRtl ? 'Amiri' : 'Essays1743',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: _isRtl ? 'عنوان الصفحة...' : 'Page Title...',
                      hintStyle: TextStyle(
                        fontFamily: _isRtl ? 'Amiri' : 'Essays1743',
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                // Static Red Marker + Inline Note Editor Rabbit Animation (animation_19_frames)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, right: 8.0),
                      child: SelectedCompanionNoteWidget(scale: 2.2),
                    ),
                  ],
                ),
              ],
            ),
            Divider(color: theme.dividerColor),

            if (_pdfPath != null)
              PdfAnnotationViewer(
                pdfPath: _pdfPath!,
                onRemove: () => setState(() => _pdfPath = null),
              ),

            if (_audioMemos.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: _audioMemos
                    .map((memo) => AudioMemoPlayerWidget(
                          memo: memo,
                          onDelete: () => setState(() => _audioMemos.remove(memo)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _contentController,
              maxLines: null,
              textAlign: _isRtl ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontFamily: _isRtl ? 'Amiri' : 'Essays1743',
                fontSize: 18,
                height: _isRtl ? 1.6 : 1.5,
                color: theme.textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: _isRtl ? 'ابدأ كتابة ملاحظاتك هنا...' : 'Start writing your notes...',
                hintStyle: TextStyle(fontFamily: _isRtl ? 'Amiri' : 'Essays1743', color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4)),
                border: InputBorder.none,
              ),
            ),

            if (_images.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                _isRtl ? 'الصور المرفقة' : 'Attached Images',
                style: TextStyle(
                  fontFamily: _isRtl ? 'Amiri' : 'Essays1743',
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _images
                    .map(
                      (img) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: img.startsWith('assets/')
                                ? Image.asset(img, width: 100, height: 100, fit: BoxFit.cover)
                                : kIsWeb
                                    ? Image.network(img, width: 100, height: 100, fit: BoxFit.cover)
                                    : Image.file(File(img), width: 100, height: 100, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _images.remove(img);
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(3),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      );
    }

    return Directionality(
      textDirection: _isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: contentWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMMM dd, yyyy').format(_pageDate);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        title: Text(
          dateStr,
          style: TextStyle(
            fontFamily: _isRtl ? 'Amiri' : 'Essays1743',
            color: theme.appBarTheme.titleTextStyle?.color?.withOpacity(0.7) ?? theme.textTheme.bodyMedium?.color,
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          // Page-Level Language / Directionality Toggle (EN / عربي)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            decoration: BoxDecoration(
              color: _isRtl ? theme.primaryColor : theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: InkWell(
              onTap: () => setState(() => _isRtl = !_isRtl),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.translate,
                      size: 14,
                      color: _isRtl
                          ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
                          : theme.textTheme.bodyLarge?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isRtl ? 'عربي' : 'EN',
                      style: TextStyle(
                        fontFamily: _isRtl ? 'Amiri' : 'Essays1743',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isRtl
                            ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.border_color_outlined, color: theme.iconTheme.color),
            onPressed: () {
              final sel = _contentController.selection;
              final start = (sel.isValid && !sel.isCollapsed) ? sel.start : 0;
              final end = (sel.isValid && !sel.isCollapsed) ? sel.end : _contentController.text.length;
              _showHighlightPickerForSelection(start, end);
            },
            tooltip: 'Highlight Selected Text',
          ),
          IconButton(
            icon: Icon(Icons.dashboard_customize_outlined, color: theme.iconTheme.color),
            onPressed: _selectTemplateSheet,
            tooltip: 'Choose Page Template',
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf_outlined, color: theme.iconTheme.color),
            onPressed: _importPdfSlide,
            tooltip: 'Import PDF Slides',
          ),
          IconButton(
            icon: Icon(Icons.mic_none_outlined, color: theme.iconTheme.color),
            onPressed: _addAudioMemo,
            tooltip: 'Record Voice Memo',
          ),
          IconButton(
            icon: Icon(Icons.bookmark_add_outlined, color: theme.iconTheme.color),
            onPressed: () => _openStickerPicker(context),
            tooltip: 'Add Sticker',
          ),
          IconButton(
            icon: Icon(Icons.add_photo_alternate_outlined, color: theme.iconTheme.color),
            onPressed: _pickImageFromGallery,
            tooltip: 'Add Image',
          ),
          IconButton(
            icon: Icon(Icons.check, color: theme.iconTheme.color),
            onPressed: _save,
            tooltip: 'Save Page',
          ),
        ],
      ),
      body: AdvancedNoteCanvas(
        strokes: _strokes,
        textBoxes: _textBoxes,
        stickers: _stickers,
        images: _images,
        onStrokesChanged: (st) => setState(() => _strokes = st),
        onTextBoxesChanged: (tb) => setState(() => _textBoxes = tb),
        onStickersChanged: (st) => setState(() => _stickers = st),
        onImagesChanged: (img) => setState(() => _images = img),
        child: _buildBodyForTemplate(),
      ),
    );
  }

  void _openStickerPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StickerPickerSheet(
        onStickerSelected: (assetPath) {
          setState(() {
            _stickers = List.from(_stickers)
              ..add(PlacedSticker(
                id: 'st_${DateTime.now().millisecondsSinceEpoch}',
                assetPath: assetPath,
                x: 100,
                y: 150,
                width: 100,
                height: 100,
              ));
          });
        },
      ),
    );
  }
}

