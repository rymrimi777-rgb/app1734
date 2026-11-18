import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';
import '../screens/notes_screen.dart';

class GlobalSearchModal extends StatefulWidget {
  const GlobalSearchModal({Key? key}) : super(key: key);

  @override
  State<GlobalSearchModal> createState() => _GlobalSearchModalState();
}

class _GlobalSearchModalState extends State<GlobalSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final repository = DataRepository();
  Map<String, dynamic> _results = {'notebooks': [], 'pages': [], 'events': []};

  void _onSearchChanged(String query) {
    setState(() {
      _results = repository.searchAll(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Notebook> notebooks = _results['notebooks'] ?? [];
    final List<NotebookPage> pages = _results['pages'] ?? [];
    final List<AgendaEvent> events = _results['events'] ?? [];
    final totalCount = notebooks.length + pages.length + events.length;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.search, color: Colors.black, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(fontFamily: 'Essays1743', fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'Search notebooks, notes, agenda...',
                      hintStyle: TextStyle(fontFamily: 'Essays1743', color: Colors.black38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Colors.black12),
            const SizedBox(height: 8),

            if (_searchController.text.trim().isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Type keywords to search across notebooks, notes, handwritten texts, and agenda events.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Essays1743', color: Colors.black45, fontSize: 14),
                  ),
                ),
              )
            else if (totalCount == 0)
              const Expanded(
                child: Center(
                  child: Text(
                    'No results found.',
                    style: TextStyle(fontFamily: 'Essays1743', color: Colors.black45, fontSize: 16),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    if (notebooks.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('NOTEBOOKS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                      ),
                      ...notebooks.map((nb) => ListTile(
                            leading: const Icon(Icons.book, color: Colors.black),
                            title: Text(nb.name, style: const TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold)),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => NotebookDetailScreen(notebook: nb)),
                              );
                            },
                          )),
                    ],

                    if (pages.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('NOTEBOOK PAGES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                      ),
                      ...pages.map((p) => ListTile(
                            leading: const Icon(Icons.article_outlined, color: Colors.black),
                            title: Text(p.title.isEmpty ? 'Untitled Page' : p.title, style: const TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              p.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontFamily: 'Essays1743', color: Colors.black54),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PageEditorScreen(notebookId: p.notebookId, page: p),
                                ),
                              );
                            },
                          )),
                    ],

                    if (events.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('AGENDA EVENTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                      ),
                      ...events.map((e) => ListTile(
                            leading: const Icon(Icons.event, color: Colors.black),
                            title: Text(e.title, style: const TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold)),
                            subtitle: Text('${e.startTime} - ${e.endTime}', style: const TextStyle(fontFamily: 'Essays1743', color: Colors.black54)),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          )),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
