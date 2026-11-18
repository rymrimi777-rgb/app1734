import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../repository.dart';
import '../asset_manifest.dart';
import '../widgets/sticker_canvas.dart';

enum CalendarViewMode { month, week, day, table }

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final repository = DataRepository();
  DateTime _selectedDate = DateTime.now();
  CalendarViewMode _viewMode = CalendarViewMode.month;

  static const List<int> eventColors = [
    0xFFFFFFFF, // White
    0xFFFFF59D, // Pastel Yellow
    0xFFF8BBD0, // Pastel Pink
    0xFFC8E6C9, // Pastel Mint
    0xFFE1BEE7, // Pastel Lavender
  ];

  void _showSmartRemindersCenter() {
    final allEvents = repository.agendaEvents.where((e) => e.hasReminder).toList();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text('Smart Reminders', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
          ],
        ),
        content: SizedBox(
          width: 320,
          height: 350,
          child: allEvents.isEmpty
              ? Center(
                  child: Text('No active reminders scheduled.', style: TextStyle(fontFamily: 'Essays1743', color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
                )
              : ListView.builder(
                  itemCount: allEvents.length,
                  itemBuilder: (context, idx) {
                    final ev = allEvents[idx];
                    final dateStr = DateFormat('MMM dd, yyyy').format(ev.date);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0.5,
                      color: theme.scaffoldBackgroundColor,
                      child: ListTile(
                        title: Text(ev.title, style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                        subtitle: Text('$dateStr at ${ev.startTime} (${ev.reminderMinutesBefore}m before alert)',
                            style: TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
                        leading: const Icon(Icons.alarm, color: Colors.amber),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: theme.primaryColor, fontFamily: 'Essays1743')),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendarGrid() {
    final theme = Theme.of(context);
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun

    final List<Widget> dayTiles = [];

    // Add weekday header row
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final headerRow = Row(
      children: weekdays
          .map((w) => Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: TextStyle(
                      fontFamily: 'Essays1743',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ),
              ))
          .toList(),
    );

    // Empty lead slots
    for (int i = 1; i < startingWeekday; i++) {
      dayTiles.add(const SizedBox());
    }

    // Days tiles
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedDate.year, _selectedDate.month, day);
      final isSelected = date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;

      final dayEvents = repository.getEventsForDate(date);
      final hasEvents = dayEvents.isNotEmpty;

      dayTiles.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isSelected ? theme.primaryColor : theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? theme.primaryColor : theme.dividerColor,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontFamily: 'Essays1743',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (hasEvents) ...[
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: dayEvents.take(3).map((e) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber : Color(e.colorValue == 0xFFFFFFFF ? 0xFF888888 : e.colorValue),
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          headerRow,
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: dayTiles,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: repository,
      builder: (context, child) {
        final events = repository.getEventsForDate(_selectedDate);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0.5,
            title: Text(
              'Agenda & Reminders',
              style: TextStyle(
                fontFamily: 'Essays1743',
                color: theme.appBarTheme.titleTextStyle?.color ?? theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: theme.iconTheme.color),
                onPressed: _showSmartRemindersCenter,
                tooltip: 'Smart Reminders',
              ),
              IconButton(
                icon: Icon(Icons.add, color: theme.iconTheme.color),
                onPressed: () => _openEventDialog(context, null),
                tooltip: 'Add Agenda Event',
              ),
            ],
          ),
          body: Column(
            children: [
              // Monthly Agenda Rabbit Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: theme.cardColor,
                child: Image.asset(
                  AppAssets.rabbitsBanner,
                  height: 75,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),

              // Header Control Bar with View Mode Toggle
              Container(
                color: theme.cardColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: theme.iconTheme.color),
                          onPressed: () {
                            setState(() {
                              if (_viewMode == CalendarViewMode.table || _viewMode == CalendarViewMode.week) {
                                _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                              } else if (_viewMode == CalendarViewMode.month) {
                                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, _selectedDate.day);
                              } else {
                                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                              }
                            });
                          },
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(_selectedDate),
                          style: TextStyle(
                            fontFamily: 'Essays1743',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: theme.iconTheme.color),
                          onPressed: () {
                            setState(() {
                              if (_viewMode == CalendarViewMode.table || _viewMode == CalendarViewMode.week) {
                                _selectedDate = _selectedDate.add(const Duration(days: 7));
                              } else if (_viewMode == CalendarViewMode.month) {
                                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
                              } else {
                                _selectedDate = _selectedDate.add(const Duration(days: 1));
                              }
                            });
                          },
                        ),
                      ],
                    ),

                    // Toggle View Mode Segmented Buttons (Scrollable horizontally for small mobile screens)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: CalendarViewMode.values.map((mode) {
                          final isSel = _viewMode == mode;
                          final label = mode.name.toUpperCase();
                          return GestureDetector(
                            onTap: () => setState(() => _viewMode = mode),
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSel ? Colors.black : Colors.black26),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontFamily: 'Essays1743',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              if (_viewMode == CalendarViewMode.month) _buildMonthCalendarGrid(),

              if (_viewMode == CalendarViewMode.table)
                Expanded(child: _buildTableGrid())
              else ...[
                const Divider(height: 1, color: Colors.black12),

                // Selected Date Events List
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontFamily: 'Essays1743',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),

              Expanded(
                child: events.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No events scheduled for this date.',
                              style: TextStyle(
                                fontFamily: 'Essays1743',
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.black),
                              ),
                              onPressed: () => _openEventDialog(context, null),
                              child: const Text(
                                '+ Add Event',
                                style: TextStyle(fontFamily: 'Essays1743', color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Card(
                            color: Color(event.colorValue),
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.black26),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: StickerCanvasOverlay(
                              stickers: event.stickers,
                              onStickersChanged: (updatedStickers) {
                                event.stickers = updatedStickers;
                                repository.saveAgendaEvent(event);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${event.startTime} — ${event.endTime}',
                                              style: const TextStyle(
                                                fontFamily: 'Essays1743',
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            if (event.hasReminder) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.black12,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.notifications_active, size: 12, color: Colors.black),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '${event.reminderMinutesBefore}m before',
                                                      style: const TextStyle(fontSize: 10, fontFamily: 'Essays1743'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.bookmark_add_outlined,
                                                size: 22,
                                                color: Colors.black87,
                                              ),
                                              onPressed: () => _openStickerPicker(context, event),
                                              tooltip: 'Add Sticker to Event',
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                size: 20,
                                                color: Colors.black87,
                                              ),
                                              onPressed: () => _openEventDialog(context, event),
                                              tooltip: 'Edit Event',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontFamily: 'Essays1743',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (event.note != null && event.note!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        event.note!,
                                        style: const TextStyle(
                                          fontFamily: 'Essays1743',
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

  double _parseTimeToMinutes(String timeStr) {
    try {
      final clean = timeStr.trim().toLowerCase();
      bool isPm = clean.contains('pm');
      bool isAm = clean.contains('am');
      final digitsOnly = clean.replaceAll(RegExp(r'[^0-9:]'), '');
      final parts = digitsOnly.split(':');
      if (parts.isEmpty || parts[0].isEmpty) return 0.0;
      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 && parts[1].isNotEmpty ? int.parse(parts[1]) : 0;
      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      return (hour * 60 + minute).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  Color _getEventPastelColor(AgendaEvent event) {
    if (event.colorValue != 0xFFFFFFFF) {
      return Color(event.colorValue);
    }
    const pastels = [
      Color(0xFFFFF8E7), // Soft Butter Yellow / Warm Cream
      Color(0xFFF3E5F5), // Pale Lavender
      Color(0xFFE8F5E9), // Muted Sage
      Color(0xFFFCE4EC), // Dusty Rose
      Color(0xFFE1F5FE), // Soft Light Blue
      Color(0xFFFFF3E0), // Soft Peach / Warm Beige
    ];
    final hash = event.title.hashCode.abs();
    return pastels[hash % pastels.length];
  }

  Widget _buildTableGrid() {
    final theme = Theme.of(context);
    final monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day).add(Duration(days: i)));

    const double startHour = 7.0;
    const double endHour = 23.0;
    const double totalHours = endHour - startHour;
    const double hourHeight = 65.0;
    const double totalGridHeight = totalHours * hourHeight;
    const double timeColumnWidth = 55.0;
    const double minColumnWidth = 95.0;

    final now = DateTime.now();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - timeColumnWidth;
        final dayColWidth = availableWidth / 7 > minColumnWidth ? availableWidth / 7 : minColumnWidth;
        final gridWidth = dayColWidth * 7;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Left Time Column
              SizedBox(
                width: timeColumnWidth,
                child: Column(
                  children: [
                    // Header spacer
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        border: Border(
                          right: BorderSide(color: theme.dividerColor, width: 1),
                          bottom: BorderSide(color: theme.dividerColor, width: 1),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'TIME',
                        style: TextStyle(
                          fontFamily: 'Essays1743',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                        ),
                      ),
                    ),
                    // Time slot labels
                    ...List.generate(totalHours.toInt(), (i) {
                      final h = startHour.toInt() + i;
                      final timeStr = '${h.toString().padLeft(2, '0')}:00';
                      return Container(
                        height: hourHeight,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          border: Border(
                            right: BorderSide(color: theme.dividerColor, width: 1),
                            bottom: BorderSide(color: theme.dividerColor.withOpacity(0.25), width: 0.5),
                          ),
                        ),
                        child: Text(
                          timeStr,
                          style: TextStyle(
                            fontFamily: 'Essays1743',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.55),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Horizontally Scrollable Timetable Grid
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: gridWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Day Headers Row
                        Row(
                          children: weekDays.map((dayDate) {
                            final isToday = dayDate.year == now.year && dayDate.month == now.month && dayDate.day == now.day;
                            final isSelected = dayDate.year == _selectedDate.year && dayDate.month == _selectedDate.month && dayDate.day == _selectedDate.day;
                            final dayName = DateFormat('EEE').format(dayDate).toUpperCase();
                            final dayNum = DateFormat('d').format(dayDate);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate = dayDate;
                                });
                              },
                              child: Container(
                                width: dayColWidth,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected ? theme.primaryColor.withOpacity(0.12) : theme.cardColor,
                                  border: Border(
                                    right: BorderSide(color: theme.dividerColor, width: 0.5),
                                    bottom: BorderSide(color: theme.dividerColor, width: 1),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      dayName,
                                      style: TextStyle(
                                        fontFamily: 'Essays1743',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isToday ? Colors.amber[800] : theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isToday ? theme.primaryColor : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        dayNum,
                                        style: TextStyle(
                                          fontFamily: 'Essays1743',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isToday
                                              ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
                                              : theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        // Day Grid Content
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: weekDays.map((dayDate) {
                            final dayEvents = repository.getEventsForDate(dayDate);

                            return Container(
                              width: dayColWidth,
                              height: totalGridHeight,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: theme.dividerColor.withOpacity(0.5), width: 0.5),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Background Hour Grid lines & LongPress detector
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onLongPressStart: (details) {
                                      final y = details.localPosition.dy;
                                      final totalMins = (y / hourHeight) * 60 + (startHour * 60);
                                      int startH = (totalMins / 60).floor().clamp(7, 22);
                                      int startM = (((totalMins % 60) / 30).floor() * 30).clamp(0, 30);
                                      int endH = startM == 30 ? startH + 1 : startH + 1;
                                      int endM = startM;
                                      final startStr = "${startH.toString().padLeft(2, '0')}:${startM.toString().padLeft(2, '0')}";
                                      final endStr = "${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}";
                                      _openEventDialog(
                                        context,
                                        null,
                                        targetDate: dayDate,
                                        defaultStart: startStr,
                                        defaultEnd: endStr,
                                      );
                                    },
                                    child: Column(
                                      children: List.generate(totalHours.toInt(), (i) {
                                        return Container(
                                          height: hourHeight,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: theme.dividerColor.withOpacity(0.25), width: 0.5),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),

                                  // Event Blocks
                                  ...dayEvents.map((event) {
                                    final startMins = _parseTimeToMinutes(event.startTime);
                                    var endMins = _parseTimeToMinutes(event.endTime);
                                    if (endMins <= startMins) endMins = startMins + 60;

                                    final top = (((startMins - startHour * 60) / 60.0) * hourHeight).clamp(0.0, totalGridHeight - 20);
                                    final rawHeight = ((endMins - startMins) / 60.0) * hourHeight;
                                    final height = rawHeight < 36.0 ? 36.0 : rawHeight;

                                    final bgColor = _getEventPastelColor(event);

                                    return Positioned(
                                      top: top,
                                      left: 2,
                                      right: 2,
                                      height: height,
                                      child: GestureDetector(
                                        onTap: () => _openEventDialog(context, event, targetDate: dayDate),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.black38, width: 0.7),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.04),
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                event.title,
                                                maxLines: height < 48 ? 1 : 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontFamily: 'Essays1743',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              if (height >= 38) ...[
                                                const SizedBox(height: 1),
                                                Text(
                                                  '${event.startTime} - ${event.endTime}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Essays1743',
                                                    fontSize: 9.5,
                                                    color: Colors.black.withOpacity(0.75),
                                                  ),
                                                ),
                                              ],
                                              if (height >= 56 && event.note != null && event.note!.isNotEmpty) ...[
                                                const SizedBox(height: 1),
                                                Text(
                                                  event.note!,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Essays1743',
                                                    fontSize: 9.5,
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.black.withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEventDialog(BuildContext context, AgendaEvent? existing, {DateTime? targetDate, String? defaultStart, String? defaultEnd}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final startController = TextEditingController(text: existing?.startTime ?? defaultStart ?? '09:00');
    final endController = TextEditingController(text: existing?.endTime ?? defaultEnd ?? '10:00');
    final noteController = TextEditingController(text: existing?.note ?? '');
    int selectedColor = existing?.colorValue ?? eventColors[0];
    bool hasReminder = existing?.hasReminder ?? true;
    int reminderMinutesBefore = existing?.reminderMinutesBefore ?? 30;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            existing == null ? 'Add Agenda Event' : 'Edit Agenda Event',
            style: const TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    labelStyle: TextStyle(fontFamily: 'Essays1743'),
                  ),
                  style: const TextStyle(fontFamily: 'Essays1743'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startController,
                        decoration: const InputDecoration(
                          labelText: 'Start Time (09:00)',
                          labelStyle: TextStyle(fontFamily: 'Essays1743'),
                        ),
                        style: const TextStyle(fontFamily: 'Essays1743'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: endController,
                        decoration: const InputDecoration(
                          labelText: 'End Time (10:00)',
                          labelStyle: TextStyle(fontFamily: 'Essays1743'),
                        ),
                        style: const TextStyle(fontFamily: 'Essays1743'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Enable Smart Reminder', style: TextStyle(fontFamily: 'Essays1743', fontSize: 14)),
                  subtitle: Text('$reminderMinutesBefore minutes before event', style: const TextStyle(fontFamily: 'Essays1743', fontSize: 12)),
                  value: hasReminder,
                  activeColor: Colors.black,
                  onChanged: (val) => setDialogState(() => hasReminder = val),
                ),
                if (hasReminder)
                  Row(
                    children: [30, 60, 1440].map((mins) {
                      final label = mins == 1440 ? '24h before' : '${mins}m before';
                      final isSel = reminderMinutesBefore == mins;
                      return ChoiceChip(
                        label: Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.black, fontFamily: 'Essays1743')),
                        selected: isSel,
                        selectedColor: Colors.black,
                        onSelected: (sel) {
                          if (sel) setDialogState(() => reminderMinutesBefore = mins);
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 12),
                const Text(
                  'Event Pastel Shading',
                  style: TextStyle(fontFamily: 'Essays1743', fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  children: eventColors.map((c) {
                    final isSel = selectedColor == c;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedColor = c;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel ? Colors.black : Colors.black26,
                            width: isSel ? 2.5 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Note / Location (optional)',
                    labelStyle: TextStyle(fontFamily: 'Essays1743'),
                  ),
                  style: const TextStyle(fontFamily: 'Essays1743'),
                ),
              ],
            ),
          ),
          actions: [
            if (existing != null)
              TextButton(
                onPressed: () {
                  repository.deleteAgendaEvent(existing.id);
                  Navigator.pop(context);
                },
                child: const Text('Delete', style: TextStyle(fontFamily: 'Essays1743', color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Essays1743', color: Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                final event = AgendaEvent(
                  id: existing?.id ?? 'ev_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleController.text.trim(),
                  date: targetDate ?? existing?.date ?? _selectedDate,
                  startTime: startController.text.trim(),
                  endTime: endController.text.trim(),
                  note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                  colorValue: selectedColor,
                  hasReminder: hasReminder,
                  reminderMinutesBefore: reminderMinutesBefore,
                  stickers: existing?.stickers ?? [],
                );
                repository.saveAgendaEvent(event);
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(fontFamily: 'Essays1743')),
            ),
          ],
        ),
      ),
    );
  }

  void _openStickerPicker(BuildContext context, AgendaEvent event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StickerPickerSheet(
        onStickerSelected: (assetPath) {
          setState(() {
            event.stickers.add(PlacedSticker(
              id: 'ev_st_${DateTime.now().millisecondsSinceEpoch}',
              assetPath: assetPath,
              x: 150,
              y: 10,
              width: 60,
              height: 60,
            ));
            repository.saveAgendaEvent(event);
          });
        },
      ),
    );
  }
}

