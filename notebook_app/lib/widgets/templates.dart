import 'package:flutter/material.dart';

class FineGridPaperPainter extends CustomPainter {
  final double gridSize;
  final Color gridColor;
  final Color lineColor;

  FineGridPaperPainter({
    this.gridSize = 20.0,
    this.gridColor = const Color(0x1F000000),
    this.lineColor = const Color(0xFF222222),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw background grid lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FineGridPaperPainter oldDelegate) => false;
}

class CornellNotesWidget extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController cueController;
  final TextEditingController notesController;
  final TextEditingController summaryController;
  final VoidCallback onChanged;

  const CornellNotesWidget({
    Key? key,
    required this.titleController,
    required this.cueController,
    required this.notesController,
    required this.summaryController,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FineGridPaperPainter(),
      child: Container(
        constraints: const BoxConstraints(minHeight: 900),
        child: Column(
          children: [
            // Top Header Section (Title / Topic / Date)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black87, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    onChanged: (_) => onChanged(),
                    style: const TextStyle(
                      fontFamily: 'Essays1743',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Topic / Title...',
                      hintStyle: TextStyle(fontFamily: 'Essays1743', color: Colors.black38),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                  const Text(
                    'CORNELL NOTES METHOD',
                    style: TextStyle(
                      fontFamily: 'Essays1743',
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),

            // Middle Two Columns (Cue Column & Notes Column)
            Expanded(
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Cue Column (Approx 30% width)
                    Container(
                      width: 140,
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.black87, width: 2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CUES / KEY POINTS',
                            style: TextStyle(
                              fontFamily: 'Essays1743',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: TextField(
                              controller: cueController,
                              onChanged: (_) => onChanged(),
                              maxLines: null,
                              style: const TextStyle(
                                fontFamily: 'Essays1743',
                                fontSize: 16,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                hintText: '• Main Keywords\n• Exam Questions\n• Key Concepts',
                                hintStyle: TextStyle(fontFamily: 'Essays1743', color: Colors.black26),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Main Notes Column
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CLASS NOTES / LECTURE DETAILS',
                              style: TextStyle(
                                fontFamily: 'Essays1743',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: TextField(
                                controller: notesController,
                                onChanged: (_) => onChanged(),
                                maxLines: null,
                                style: const TextStyle(
                                  fontFamily: 'Essays1743',
                                  fontSize: 17,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Record detailed notes, formulas, diagrams, explanations...',
                                  hintStyle: TextStyle(fontFamily: 'Essays1743', color: Colors.black26),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Summary Section
            Container(
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black87, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SUMMARY (Brief synthesis in your own words)',
                    style: TextStyle(
                      fontFamily: 'Essays1743',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: TextField(
                      controller: summaryController,
                      onChanged: (_) => onChanged(),
                      maxLines: null,
                      style: const TextStyle(
                        fontFamily: 'Essays1743',
                        fontSize: 16,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Summarize the main takeaway of this page...',
                        hintStyle: TextStyle(fontFamily: 'Essays1743', color: Colors.black26),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyPlannerWidget extends StatelessWidget {
  final TextEditingController contentController;
  final VoidCallback onChanged;

  const WeeklyPlannerWidget({
    Key? key,
    required this.contentController,
    required this.onChanged,
  }) : super(key: key);

  static const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FineGridPaperPainter(),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minHeight: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WEEKLY PLANNER & GOALS',
              style: TextStyle(
                fontFamily: 'Essays1743',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.black,
              ),
            ),
            const Divider(color: Colors.black, thickness: 1.5),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: contentController,
                onChanged: (_) => onChanged(),
                maxLines: null,
                style: const TextStyle(
                  fontFamily: 'Essays1743',
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  hintText: '📌 WEEKLY TARGETS:\n• Complete Math Assignment\n• Read Chapter 4\n\n'
                      'MONDAY: Prepare slides\nTUESDAY: Study Group at 4 PM\nWEDNESDAY: Exam Review\n'
                      'THURSDAY: Lab Submission\nFRIDAY: Project Demo\nWEEKEND: Relax & Rest',
                  hintStyle: TextStyle(fontFamily: 'Essays1743', color: Colors.black38),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HabitTrackerWidget extends StatefulWidget {
  final VoidCallback onChanged;

  const HabitTrackerWidget({Key? key, required this.onChanged}) : super(key: key);

  @override
  State<HabitTrackerWidget> createState() => _HabitTrackerWidgetState();
}

class _HabitTrackerWidgetState extends State<HabitTrackerWidget> {
  final List<String> _habits = [
    'Read 30 mins',
    'Workout / Exercise',
    'Drink 2L Water',
    'Code / Practice',
    'Meditation 10m',
  ];
  final Map<String, Set<int>> _completedDays = {};

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FineGridPaperPainter(),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MONTHLY HABIT TRACKER',
              style: TextStyle(
                fontFamily: 'Essays1743',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(color: Colors.black, thickness: 1.5),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(28),
                children: [
                  // Days Header
                  TableRow(
                    children: [
                      const SizedBox(width: 140, child: Text('Habit / Day', style: TextStyle(fontWeight: FontWeight.bold))),
                      ...List.generate(14, (i) => Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
                    ],
                  ),
                  ..._habits.map((habit) {
                    final set = _completedDays.putIfAbsent(habit, () => {});
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(habit, style: const TextStyle(fontFamily: 'Essays1743', fontSize: 14)),
                        ),
                        ...List.generate(14, (dayIdx) {
                          final isChecked = set.contains(dayIdx + 1);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isChecked) {
                                  set.remove(dayIdx + 1);
                                } else {
                                  set.add(dayIdx + 1);
                                }
                              });
                              widget.onChanged();
                            },
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isChecked ? Colors.black : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black54),
                              ),
                              child: isChecked
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
