import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../repository.dart';
import 'notes_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final repository = DataRepository();
  String? _activeFolderId;
  String _sortBy = 'newest'; // newest, oldest, name

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: repository,
      builder: (context, child) {
        final folders = repository.folders;
        List<Notebook> notebooks = _activeFolderId != null
            ? repository.notebooks.where((n) => n.folderId == _activeFolderId).toList()
            : repository.notebooks;

        // Sort notebooks
        if (_sortBy == 'newest') {
          notebooks.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        } else if (_sortBy == 'oldest') {
          notebooks.sort((a, b) => a.lastModified.compareTo(b.lastModified));
        } else if (_sortBy == 'name') {
          notebooks.sort((a, b) => a.name.compareTo(b.name));
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0.5,
            iconTheme: theme.iconTheme,
            title: Text(
              'History & Organization',
              style: TextStyle(
                fontFamily: 'Essays1743',
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.sort, color: theme.iconTheme.color),
                color: theme.cardColor,
                onSelected: (val) {
                  setState(() {
                    _sortBy = val;
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'newest', child: Text('Sort by Newest', style: TextStyle(fontFamily: 'Essays1743', color: theme.textTheme.bodyLarge?.color))),
                  PopupMenuItem(value: 'oldest', child: Text('Sort by Oldest', style: TextStyle(fontFamily: 'Essays1743', color: theme.textTheme.bodyLarge?.color))),
                  PopupMenuItem(value: 'name', child: Text('Sort by Name', style: TextStyle(fontFamily: 'Essays1743', color: theme.textTheme.bodyLarge?.color))),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Folders Navigation
                Text(
                  'Folders',
                  style: TextStyle(
                    fontFamily: 'Essays1743',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // All Folder Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeFolderId = null;
                          });
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _activeFolderId == null ? theme.primaryColor : theme.cardColor,
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_special_outlined,
                                color: _activeFolderId == null
                                    ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
                                    : theme.iconTheme.color,
                                size: 28,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'All Notes',
                                style: TextStyle(
                                  fontFamily: 'Essays1743',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _activeFolderId == null
                                      ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
                                      : theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ...folders.map((folder) {
                        final isSelected = _activeFolderId == folder.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _activeFolderId = folder.id;
                            });
                          },
                          child: Container(
                            width: 85,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? theme.primaryColor : theme.cardColor,
                              border: Border.all(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.asset(
                                    folder.iconAsset,
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.folder, color: isSelected ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white) : theme.iconTheme.color),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  folder.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Essays1743',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Notebooks List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _activeFolderId == null
                          ? 'All Notebooks (${notebooks.length})'
                          : '${folders.firstWhere((f) => f.id == _activeFolderId, orElse: () => HistoryFolder(id: '', name: 'Folder', iconAsset: '')).name} (${notebooks.length})',
                      style: TextStyle(
                        fontFamily: 'Essays1743',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      'Sort: ${_sortBy.toUpperCase()}',
                      style: TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                notebooks.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No notebooks found in this folder.',
                            style: TextStyle(fontFamily: 'Essays1743', color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notebooks.length,
                        itemBuilder: (context, index) {
                          final notebook = notebooks[index];
                          final pagesCount = repository.getPagesForNotebook(notebook.id).length;
                          final dateStr = DateFormat('MMMM dd, yyyy').format(notebook.lastModified);

                          return Card(
                            color: theme.cardColor,
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 45,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.asset(
                                    notebook.coverAsset,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.book, color: theme.disabledColor),
                                  ),
                                ),
                              ),
                              title: Text(
                                notebook.name,
                                style: TextStyle(
                                  fontFamily: 'Essays1743',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              subtitle: Text(
                                '$dateStr  •  $pagesCount pages',
                                style: TextStyle(fontFamily: 'Essays1743', fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                              ),
                              trailing: PopupMenuButton<String?>(
                                icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                                color: theme.cardColor,
                                onSelected: (folderId) {
                                  repository.moveNotebookToFolder(notebook.id, folderId);
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: null,
                                    child: Text('Move to: No Folder', style: TextStyle(fontFamily: 'Essays1743', color: theme.textTheme.bodyLarge?.color)),
                                  ),
                                  ...folders.map((f) => PopupMenuItem(
                                        value: f.id,
                                        child: Text('Move to: ${f.name}', style: TextStyle(fontFamily: 'Essays1743', color: theme.textTheme.bodyLarge?.color)),
                                      )),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotebookDetailScreen(notebook: notebook),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
