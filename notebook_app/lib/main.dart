import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/agenda_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/rabbit_system.dart';
import 'widgets/rabbit_notification_banner.dart';
import 'widgets/companion_system.dart';
import 'repository.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Essays1743NotebookApp());
}

class Essays1743NotebookApp extends StatelessWidget {
  const Essays1743NotebookApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repository = DataRepository();

    return AnimatedBuilder(
      animation: repository,
      builder: (context, child) {
        final currentThemeMode = repository.currentThemeMode;
        final themeData = AppTheme.getThemeData(currentThemeMode);

        return MaterialApp(
          title: '1734 Notebook',
          debugShowCheckedModeBanner: false,
          theme: themeData,
          home: const SplashScreen(),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTimeBasedNotifications();
    });
  }

  void _checkTimeBasedNotifications() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      RabbitNotificationBanner.show(context, type: RabbitBannerType.morning);
    } else if (hour >= 18 || hour < 22) {
      RabbitNotificationBanner.show(context, type: RabbitBannerType.evening);
    }
  }

  void _onNavigateTab(int index) {
    setState(() {
      _currentIndex = index;
    });

    final size = MediaQuery.of(context).size;
    RabbitController.instance.moveToTab(index, size.width, size.height);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> screens = [
      HomeScreen(onNavigateTab: _onNavigateTab),
      const NotesLibraryTab(),
      const AgendaScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return UnifiedCompanionOverlay(
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavigateTab,
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
          selectedLabelStyle: const TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Essays1743', fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Agenda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    ),
  );
}
}

class NotesLibraryTab extends StatelessWidget {
  const NotesLibraryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repository = DataRepository();
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: repository,
      builder: (context, child) {
        final notebooks = repository.notebooks;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0.5,
            iconTheme: theme.iconTheme,
            title: Text(
              'Notebooks Library',
              style: TextStyle(
                fontFamily: 'Essays1743',
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: theme.iconTheme.color),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const CreateNotebookDialog(),
                  );
                },
              ),
            ],
          ),
          body: notebooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No notebooks created yet.',
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
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const CreateNotebookDialog(),
                          );
                        },
                        child: Text(
                          '+ Create Notebook',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontFamily: 'Essays1743',
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: notebooks.length,
                  itemBuilder: (context, index) {
                    final notebook = notebooks[index];
                    final pageCount = repository.getPagesForNotebook(notebook.id).length;

                    return GestureDetector(
                      onTapDown: (details) {
                        final targetOffset = Offset(
                          details.globalPosition.dx - 20,
                          details.globalPosition.dy - 35,
                        );
                        if (CompanionManager.instance.isRabbit) {
                          RabbitController.instance.walkTo(
                            targetOffset,
                            onArrived: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotebookDetailScreen(notebook: notebook),
                                ),
                              );
                            },
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotebookDetailScreen(notebook: notebook),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: theme.dividerColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.25 : 0.08),
                              blurRadius: 6,
                              offset: const Offset(2, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                child: Image.asset(
                                  notebook.coverAsset,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(child: Icon(Icons.book, size: 48, color: theme.disabledColor)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notebook.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Essays1743',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$pageCount pages',
                                    style: TextStyle(
                                      fontFamily: 'Essays1743',
                                      fontSize: 12,
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
