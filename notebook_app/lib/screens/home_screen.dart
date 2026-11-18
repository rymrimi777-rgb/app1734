import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repository.dart';
import 'notes_screen.dart';
import '../widgets/global_search.dart';
import '../widgets/pomodoro_timer.dart';
import '../widgets/cloud_sync.dart';

import '../widgets/rabbit_system.dart';
import '../widgets/companion_system.dart';

class HomeScreen extends StatelessWidget {
  final Function(int index) onNavigateTab;

  const HomeScreen({Key? key, required this.onNavigateTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repository = DataRepository();
    final today = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM dd, yyyy').format(today);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: repository,
      builder: (context, child) {
        final todayEvents = repository.getEventsForDate(today);
        final recentNotebooks = repository.notebooks.take(4).toList();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Title & Action Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            repository.userName,
                            style: TextStyle(
                              fontFamily: 'Essays1743',
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.search, color: theme.iconTheme.color, size: 26),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const GlobalSearchModal(),
                              );
                            },
                            tooltip: 'Global Search',
                          ),
                          IconButton(
                            icon: Icon(Icons.timer_outlined, color: theme.iconTheme.color, size: 26),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const PomodoroFocusTimerSheet(),
                              );
                            },
                            tooltip: 'Pomodoro Focus Timer',
                          ),
                          IconButton(
                            icon: Icon(Icons.cloud_sync_outlined, color: theme.iconTheme.color, size: 26),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const CloudSyncSheet(),
                              );
                            },
                            tooltip: 'Cloud Sync & Backup',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Date Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Today',
                            style: TextStyle(
                              fontFamily: 'Essays1743',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '[ $dateStr ]',
                            style: TextStyle(
                              fontFamily: 'Essays1743',
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      // Selected Companion Widget under Today section (Rabbit or Deer)
                      const SelectedCompanionHeaderWidget(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 16),
                  // Today's Notes Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's notes",
                        style: TextStyle(
                          fontFamily: 'Essays1743',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onNavigateTab(1), // Notes Tab
                        child: Text(
                          'View all',
                          style: TextStyle(fontFamily: 'Essays1743', fontSize: 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // New Note Button
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(color: theme.primaryColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: () {
                      if (repository.notebooks.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageEditorScreen(
                              notebookId: repository.notebooks.first.id,
                            ),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => const CreateNotebookDialog(),
                        );
                      }
                    },
                    child: Text(
                      '+ New Note',
                      style: TextStyle(
                        fontFamily: 'Essays1743',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Today's Agenda/Events
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's agenda/events",
                        style: TextStyle(
                          fontFamily: 'Essays1743',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onNavigateTab(2), // Agenda Tab
                        child: Text(
                          'View agenda',
                          style: TextStyle(fontFamily: 'Essays1743', fontSize: 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  todayEvents.isEmpty
                      ? Text(
                          'No events scheduled for today.',
                          style: TextStyle(fontFamily: 'Essays1743', fontSize: 15, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                        )
                      : Column(
                          children: todayEvents
                              .map(
                                (ev) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    border: Border.all(color: theme.dividerColor),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${ev.startTime} - ${ev.endTime}',
                                        style: TextStyle(
                                          fontFamily: 'Essays1743',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          ev.title,
                                          style: TextStyle(
                                            fontFamily: 'Essays1743',
                                            fontSize: 15,
                                            color: theme.textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                  const SizedBox(height: 28),
                  // Recent Notebooks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent notebooks',
                        style: TextStyle(
                          fontFamily: 'Essays1743',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onNavigateTab(3), // History Tab
                        child: Text(
                          'Library',
                          style: TextStyle(fontFamily: 'Essays1743', fontSize: 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 170,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentNotebooks.length,
                      itemBuilder: (context, index) {
                        final nb = recentNotebooks[index];
                        return GestureDetector(
                          onTapDown: (details) {
                            final targetOffset = Offset(
                              details.globalPosition.dx - 20,
                              details.globalPosition.dy - 35,
                            );
                            RabbitController.instance.walkTo(
                              targetOffset,
                              onArrived: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotebookDetailScreen(notebook: nb),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: 110,
                            margin: const EdgeInsets.only(right: 14),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: theme.dividerColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    child: Image.asset(
                                      nb.coverAsset,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Center(child: Icon(Icons.book, color: theme.iconTheme.color?.withOpacity(0.4))),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    nb.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Essays1743',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
