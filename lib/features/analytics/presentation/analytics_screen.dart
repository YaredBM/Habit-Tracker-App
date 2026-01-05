import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/l10n/app_localizations.dart';

/* -------------------------------------------------------------------------- */
/* ENUMS & CONSTANTS                                                          */
/* -------------------------------------------------------------------------- */

enum AnalyticsRange { week, month }
enum _LabelMode { all, ticks }

/* -------------------------------------------------------------------------- */
/* MAIN SCREEN                                                                */
/* -------------------------------------------------------------------------- */

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, this.habitId});

  final String? habitId;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsRange _range = AnalyticsRange.week;
  late DateTime _currentMonth;
  String? _selectedHabitId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedHabitId = widget.habitId;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            t.analyticsSignInPrompt,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final habitsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          t.analyticsTitle,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: habitsStream,
        builder: (context, snapshot) {
          final t = AppLocalizations.of(context)!;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                t.analyticsNoHabitsYet,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }

          final docs = snapshot.data!.docs;
          final habits = <_HabitAnalyticsData>[];

          for (final doc in docs) {
            final data = doc.data();
            final title = (data['title'] as String?) ?? t.analyticsHabitFallbackTitle;
            final colorValue = data['color'] as int? ?? 0xFF5CE1E6;

            // completedDates
            final completedDatesRaw =
            (data['completedDates'] as List<dynamic>? ?? []).cast<String>();
            final completedSet = _parseDates(completedDatesRaw);

            // progressByDate + goal info (same pattern as HabitDetailScreen)
            final rawProgress = (data['progressByDate'] as Map<String, dynamic>? ?? {});
            final progressByDate = <String, num>{};
            rawProgress.forEach((key, value) {
              if (value is num) {
                progressByDate[key] = value;
              }
            });

            final goalEnabled = (data['goalEnabled'] as bool?) ?? false;
            final rawGoalValue = (data['goalValue'] as int?) ?? 1;
            final goalValue = goalEnabled ? (rawGoalValue <= 0 ? 1 : rawGoalValue) : 1;

            final best = _bestStreak(completedSet);
            final current = _currentStreak(completedSet);
            final score = _calculateScore(
              completions: completedSet,
              month: _currentMonth,
            );

            habits.add(
              _HabitAnalyticsData(
                id: doc.id,
                title: title,
                color: Color(colorValue),
                completedDates: completedSet,
                progressByDate: progressByDate,
                goalEnabled: goalEnabled,
                goalValue: goalValue,
                bestStreak: best,
                currentStreak: current,
                monthlyScore: score,
              ),
            );
          }

          _HabitAnalyticsData? selectedHabit;
          if (_selectedHabitId != null) {
            try {
              selectedHabit = habits.firstWhere((h) => h.id == _selectedHabitId);
            } catch (_) {
              selectedHabit = null;
            }
          }

          final bool showAll = _selectedHabitId == null || selectedHabit == null;

          final completionsByDay = _aggregateCompletions(habits);

          final double averageScore = habits.isEmpty
              ? 0
              : habits.map((h) => h.monthlyScore).fold<int>(0, (a, b) => a + b) / habits.length;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HabitTabs(
                  habits: habits,
                  selectedHabitId: showAll ? null : selectedHabit.id,
                  onSelected: (id) {
                    setState(() {
                      _selectedHabitId = id;
                      _range = AnalyticsRange.week;
                    });
                  },
                ),
                const SizedBox(height: 24),
                if (showAll)
                  _AllHabitsView(
                    habits: habits,
                    completionsByDay: completionsByDay,
                    averageScore: averageScore,
                    range: _range,
                    currentMonth: _currentMonth,
                    onRangeChanged: (r) => setState(() => _range = r),
                    onMonthChanged: (m) => setState(() => _currentMonth = m),
                  )
                else
                  _SingleHabitView(
                    habit: selectedHabit,
                    currentMonth: _currentMonth,
                    range: _range,
                    onRangeChanged: (r) => setState(() => _range = r),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<DateTime, int> _aggregateCompletions(List<_HabitAnalyticsData> habits) {
    final map = <DateTime, int>{};
    for (final h in habits) {
      for (final d in h.completedDates) {
        final key = _stripTime(d);
        map[key] = (map[key] ?? 0) + 1;
      }
    }
    return map;
  }
}

/* -------------------------------------------------------------------------- */
/* DATA MODELS & HELPERS (TOP LEVEL)                                          */
/* -------------------------------------------------------------------------- */

class _HabitAnalyticsData {
  final String id;
  final String title;
  final Color color;
  final Set<DateTime> completedDates;

  final Map<String, num> progressByDate;
  final bool goalEnabled;
  final int goalValue;

  final int bestStreak;
  final int currentStreak;
  final int monthlyScore;

  _HabitAnalyticsData({
    required this.id,
    required this.title,
    required this.color,
    required this.completedDates,
    required this.progressByDate,
    required this.goalEnabled,
    required this.goalValue,
    required this.bestStreak,
    required this.currentStreak,
    required this.monthlyScore,
  });
}

class _ChartPoint {
  final DateTime date;
  final double value;
  _ChartPoint({required this.date, required this.value});
}

class _BarChartData {
  final List<double> values;
  final List<String> labels;
  final List<int> indices;
  final double total;
  _BarChartData(this.values, this.labels, this.indices, this.total);
}

// --- Global Helper Functions ---

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

Set<DateTime> _parseDates(List<String> dates) {
  final set = <DateTime>{};
  for (final s in dates) {
    try {
      final d = DateTime.parse(s);
      set.add(DateTime(d.year, d.month, d.day));
    } catch (_) {}
  }
  return set;
}

DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

int _currentStreak(Set<DateTime> completed) {
  int streak = 0;
  DateTime cursor = _stripTime(DateTime.now());

  if (!completed.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!completed.contains(cursor)) {
      return 0;
    }
  }
  while (completed.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

int _bestStreak(Set<DateTime> completed) {
  if (completed.isEmpty) return 0;
  final sorted = completed.toList()..sort();
  int best = 1;
  int current = 1;
  for (int i = 1; i < sorted.length; i++) {
    final prev = sorted[i - 1];
    final curr = sorted[i];
    if (curr.difference(prev).inDays == 1) {
      current++;
    } else {
      best = current > best ? current : best;
      current = 1;
    }
  }
  if (current > best) best = current;
  return best;
}

int _calculateScore({
  required Set<DateTime> completions,
  required DateTime month,
}) {
  final end = DateTime(month.year, month.month + 1, 0);
  final daysInMonth = end.day;
  int count = 0;
  for (final d in completions) {
    if (d.year == month.year && d.month == month.month) {
      count++;
    }
  }
  if (daysInMonth == 0) return 0;
  return ((count / daysInMonth) * 100).round().clamp(0, 100);
}

/// Localized short month name (Jan..Dec) via l10n keys.
String _monthShortL10n(AppLocalizations t, int month) {
  switch (month) {
    case 1:
      return t.monthShortJan;
    case 2:
      return t.monthShortFeb;
    case 3:
      return t.monthShortMar;
    case 4:
      return t.monthShortApr;
    case 5:
      return t.monthShortMay;
    case 6:
      return t.monthShortJun;
    case 7:
      return t.monthShortJul;
    case 8:
      return t.monthShortAug;
    case 9:
      return t.monthShortSep;
    case 10:
      return t.monthShortOct;
    case 11:
      return t.monthShortNov;
    case 12:
      return t.monthShortDec;
    default:
      return t.monthShortJan;
  }
}

/// Localized weekday short (Mon..Sun) via l10n keys.
String _weekdayShortL10n(AppLocalizations t, int weekdayMonIs1) {
  switch (weekdayMonIs1) {
    case 1:
      return t.weekdayShortMon;
    case 2:
      return t.weekdayShortTue;
    case 3:
      return t.weekdayShortWed;
    case 4:
      return t.weekdayShortThu;
    case 5:
      return t.weekdayShortFri;
    case 6:
      return t.weekdayShortSat;
    case 7:
      return t.weekdayShortSun;
    default:
      return t.weekdayShortMon;
  }
}

String _monthLabel(AppLocalizations t, DateTime d) {
  return '${_monthShortL10n(t, d.month)} ${d.year}';
}

_BarChartData _prepareBarData(
    AppLocalizations t,
    AnalyticsRange range,
    DateTime currentMonth,
    double Function(DateTime) getValue,
    ) {
  final barValues = <double>[];
  final xLabels = <String>[];
  final labelIndices = <int>[];

  final now = DateTime.now();
  final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

  if (range == AnalyticsRange.week) {
    final weekStart = now.subtract(Duration(days: now.weekday - 1)); // Monday start
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      barValues.add(getValue(date));
      xLabels.add(_weekdayShortL10n(t, i + 1));
      labelIndices.add(i);
    }
  } else {
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      barValues.add(getValue(date));
      xLabels.add(day.toString());
    }
    labelIndices.add(0);
    if (daysInMonth >= 7) labelIndices.add(6);
    if (daysInMonth >= 14) labelIndices.add(13);
    if (daysInMonth >= 21) labelIndices.add(20);
    if (daysInMonth >= 30) labelIndices.add(daysInMonth - 1);
  }

  final total = barValues.fold<double>(0, (prev, v) => prev + v);
  return _BarChartData(barValues, xLabels, labelIndices, total);
}

/* -------------------------------------------------------------------------- */
/* SUB-WIDGETS                                                                */
/* -------------------------------------------------------------------------- */

class _HabitTabs extends StatelessWidget {
  const _HabitTabs({
    required this.habits,
    required this.selectedHabitId,
    required this.onSelected,
  });

  final List<_HabitAnalyticsData> habits;
  final String? selectedHabitId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _TabChip(
            label: t.analyticsAllHabitsTab,
            selected: selectedHabitId == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          ...habits.map(
                (h) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _TabChip(
                label: h.title,
                selected: selectedHabitId == h.id,
                onTap: () => onSelected(h.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFF1A1A1F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AllHabitsView extends StatelessWidget {
  const _AllHabitsView({
    required this.habits,
    required this.completionsByDay,
    required this.averageScore,
    required this.range,
    required this.currentMonth,
    required this.onRangeChanged,
    required this.onMonthChanged,
  });

  final List<_HabitAnalyticsData> habits;
  final Map<DateTime, int> completionsByDay;
  final double averageScore;
  final AnalyticsRange range;
  final DateTime currentMonth;
  final ValueChanged<AnalyticsRange> onRangeChanged;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    const accent = Color(0xFFB4FF39);

    final barData = _prepareBarData(
      t,
      range,
      currentMonth,
          (date) => (completionsByDay[_stripTime(date)] ?? 0).toDouble(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: _ScoreDonut(
            percentage: averageScore,
            color: accent,
            label: t.analyticsAverageScore,
          ),
        ),
        const SizedBox(height: 24),
        _BarChartSection(
          title: t.analyticsHabitsCompletedTitle,
          totalValue: barData.total.toInt().toString(),
          subTitle: t.analyticsTotalCompletedHabitsSubtitle,
          barValues: barData.values,
          xLabels: barData.labels,
          labelIndices: barData.indices,
          barColor: accent,
          range: range,
          onRangeChanged: onRangeChanged,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                t.analyticsHabitHeatmapTitle,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: currentMonth,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(data: ThemeData.dark(), child: child!);
                  },
                );
                if (picked != null) {
                  onMonthChanged(DateTime(picked.year, picked.month));
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF1B1B20),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.calendar_today, size: 14, color: Colors.white),
              label: Text(
                _monthLabel(t, currentMonth),
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _HeatmapCalendar(
          month: currentMonth,
          completionsByDay: completionsByDay,
        ),
      ],
    );
  }
}

class _SingleHabitView extends StatelessWidget {
  const _SingleHabitView({
    required this.habit,
    required this.currentMonth,
    required this.range,
    required this.onRangeChanged,
  });

  final _HabitAnalyticsData habit;
  final DateTime currentMonth;
  final AnalyticsRange range;
  final ValueChanged<AnalyticsRange> onRangeChanged;

  List<int> _anchorDaysForMonth(DateTime month, int lastDay) {
    const desired = [3, 10, 17, 24];
    return desired.where((d) => d <= lastDay).toList();
  }

  List<_ChartPoint> _weeklyCompletionPoints() {
    final month = DateTime(currentMonth.year, currentMonth.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final now = DateTime.now();
    final isCurrentMonth = now.year == month.year && now.month == month.month;
    final lastDay = isCurrentMonth ? now.day.clamp(1, daysInMonth) : daysInMonth;

    final monthCompletions = habit.completedDates
        .where((d) => d.year == month.year && d.month == month.month)
        .map(_stripTime)
        .toSet();

    final anchors = _anchorDaysForMonth(month, lastDay);
    final points = <_ChartPoint>[];

    for (final anchorDay in anchors) {
      final endDay = anchorDay;
      final startDay = math.max(1, endDay - 6);

      int count = 0;
      for (int d = startDay; d <= endDay; d++) {
        final date = DateTime(month.year, month.month, d);
        if (monthCompletions.contains(date)) {
          count++;
        }
      }

      points.add(
        _ChartPoint(
          date: DateTime(month.year, month.month, anchorDay),
          value: count.toDouble(),
        ),
      );
    }

    return points;
  }

  List<_ChartPoint> _scoreTrendPoints() {
    final month = DateTime(currentMonth.year, currentMonth.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final now = DateTime.now();
    final isCurrentMonth = now.year == month.year && now.month == month.month;
    final lastDay = isCurrentMonth ? now.day.clamp(1, daysInMonth) : daysInMonth;

    final monthCompletions = habit.completedDates
        .where((d) => d.year == month.year && d.month == month.month)
        .map(_stripTime)
        .toSet();

    final points = <_ChartPoint>[];
    int completedSoFar = 0;

    for (int day = 1; day <= lastDay; day++) {
      final date = DateTime(month.year, month.month, day);
      if (monthCompletions.contains(date)) {
        completedSoFar++;
      }
      final score = (completedSoFar / day * 100.0).clamp(0.0, 100.0);
      points.add(_ChartPoint(date: date, value: score));
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final barData = _prepareBarData(
      t,
      range,
      currentMonth,
          (date) => (habit.completedDates.contains(_stripTime(date)) ? 1.0 : 0.0),
    );

    final weeklyPoints = _weeklyCompletionPoints();
    final scorePoints = _scoreTrendPoints();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: _ScoreDonut(
            percentage: habit.monthlyScore.toDouble(),
            color: habit.color,
            label: t.analyticsAverageScore,
          ),
        ),
        const SizedBox(height: 24),
        _BarChartSection(
          title: t.analyticsHabitsCompletedTitle,
          totalValue: barData.total.toInt().toString(),
          subTitle: t.analyticsTotalCompletedHabitsSubtitle,
          barValues: barData.values,
          xLabels: barData.labels,
          labelIndices: barData.indices,
          barColor: habit.color,
          range: range,
          onRangeChanged: onRangeChanged,
        ),
        const SizedBox(height: 24),
        Text(
          t.analyticsStreakTitle,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StreakCard(
                label: t.analyticsBestStreak,
                value: habit.bestStreak,
                iconAsset: 'lib/assets/best_streak.png',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StreakCard(
                label: t.analyticsCurrentStreak,
                value: habit.currentStreak,
                iconAsset: 'lib/assets/current_streak.png',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          t.analyticsWeeklyCompletionsTitle,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _WeeklyCompletionsGraphCard(
          points: weeklyPoints,
          color: habit.color,
        ),
        const SizedBox(height: 24),
        Text(
          t.analyticsScoreTitle,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _ScoreGraphCard(
          points: scorePoints,
          color: habit.color,
        ),
      ],
    );
  }
}

class _ScoreDonut extends StatelessWidget {
  const _ScoreDonut({
    required this.percentage,
    required this.color,
    required this.label,
  });

  final double percentage;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: _DonutPainter(
              percentage: percentage.clamp(0, 100),
              color: color,
              backgroundColor: const Color(0xFF15151A),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${percentage.round()}%',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarChartSection extends StatelessWidget {
  const _BarChartSection({
    required this.title,
    required this.totalValue,
    required this.subTitle,
    required this.barValues,
    required this.xLabels,
    required this.labelIndices,
    required this.barColor,
    required this.range,
    required this.onRangeChanged,
  });

  final String title;
  final String totalValue;
  final String subTitle;
  final List<double> barValues;
  final List<String> xLabels;
  final List<int> labelIndices;
  final Color barColor;
  final AnalyticsRange range;
  final ValueChanged<AnalyticsRange> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final maxValue =
    barValues.isEmpty ? 1.0 : barValues.reduce(math.max).clamp(1.0, 999.0);
    final topYLabel = maxValue.round();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.ios_share, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 4),
            _RangeToggle(
              range: range,
              onChanged: onRangeChanged,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111116),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                totalValue,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subTitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _BarChartPainter(
                          values: barValues,
                          barColor: barColor,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -10,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          '$topYLabel',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -10,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          '0',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 20,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final children = <Widget>[];
                    if (barValues.isNotEmpty && barValues.length == xLabels.length) {
                      final n = barValues.length;
                      final totalSpacing = width * 0.25;
                      final barWidth = (width - totalSpacing) / n;
                      final space = totalSpacing / (n + 1);

                      for (final index in labelIndices) {
                        if (index < 0 || index >= xLabels.length) continue;
                        final barLeft = space + index * (barWidth + space);
                        final barCenter = barLeft + barWidth / 2;
                        final left = barCenter - 10;

                        children.add(
                          Positioned(
                            left: left,
                            child: SizedBox(
                              width: 20,
                              child: Text(
                                xLabels[index],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    }
                    return Stack(clipBehavior: Clip.none, children: children);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.label,
    required this.value,
    required this.iconAsset,
  });

  final String label;
  final int value;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            iconAsset,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _LineChartCard extends StatefulWidget {
  const _LineChartCard({
    required this.points,
    required this.color,
    this.fixedYLabels,
    required this.isPercent,
    required this.labelMode,
  });

  final List<_ChartPoint> points;
  final Color color;
  final List<int>? fixedYLabels;
  final bool isPercent;
  final _LabelMode labelMode;

  @override
  State<_LineChartCard> createState() => _LineChartCardState();
}

class _LineChartCardState extends State<_LineChartCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _LineChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<int> _computeTickIndices(int n) {
    if (n <= 1) return [0];
    if (n <= 4) return List<int>.generate(n, (i) => i);

    final step = (n - 1) / 3.0;
    final set = <int>{
      0,
      (step).round(),
      (step * 2).round(),
      n - 1,
    };
    final list = set.toList()..sort();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final yLabelSuffix = widget.isPercent ? '%' : '';

    double maxY;
    if (widget.fixedYLabels != null && widget.fixedYLabels!.isNotEmpty) {
      maxY = widget.fixedYLabels!.reduce(math.max).toDouble();
    } else if (widget.points.isNotEmpty) {
      maxY = widget.points.map((p) => p.value).reduce(math.max).clamp(1.0, double.infinity);
    } else {
      maxY = 1.0;
    }

    final tickIndices = widget.labelMode == _LabelMode.ticks
        ? _computeTickIndices(widget.points.length)
        : <int>[];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final height = constraints.maxHeight;

                      if (widget.fixedYLabels != null && widget.fixedYLabels!.isNotEmpty) {
                        return Stack(
                          children: widget.fixedYLabels!.map((val) {
                            final normalized = (val / maxY).clamp(0.0, 1.0);
                            final topPos = height * (1 - normalized);

                            double translateY = -6;
                            if (normalized >= 0.95) translateY = 0;
                            if (normalized <= 0.05) translateY = -12;

                            return Positioned(
                              top: topPos + translateY,
                              left: 0,
                              right: 0,
                              child: Text(
                                '$val$yLabelSuffix',
                                textAlign: TextAlign.right,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '100$yLabelSuffix',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            '0$yLabelSuffix',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: widget.points.isEmpty
                      ? Center(
                    child: Text(
                      t.analyticsNoData,
                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                    ),
                  )
                      : AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _SmoothLineChartPainter(
                          points: widget.points,
                          color: widget.color,
                          maxY: maxY,
                          labelMode: widget.labelMode,
                          horizontalGridValues: widget.fixedYLabels,
                          progress: _animation.value,
                          tickIndices: tickIndices,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (widget.labelMode == _LabelMode.all)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: widget.points.map((p) {
                return SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      Text(
                        '${p.date.day}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        _monthShortL10n(t, p.date.month),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            SizedBox(
              height: 20,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final n = widget.points.length;
                  if (n == 0) return const SizedBox.shrink();

                  final ticks = tickIndices.isEmpty ? List<int>.generate(n, (i) => i) : tickIndices;

                  final maxIndex = n - 1;
                  final children = <Widget>[];

                  for (final index in ticks) {
                    if (index < 0 || index >= n) continue;

                    final tt = maxIndex == 0 ? 0.0 : index / maxIndex;
                    final centerX = width * tt;
                    final left = (centerX - 12).clamp(0.0, width - 24);

                    final p = widget.points[index];
                    final showMonth = index == 0;
                    final label = showMonth
                        ? '${p.date.day}\n${_monthShortL10n(t, p.date.month)}'
                        : '${p.date.day}';

                    children.add(
                      Positioned(
                        left: left,
                        child: SizedBox(
                          width: 24,
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              height: 1.2,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Stack(children: children);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ScoreGraphCard extends StatelessWidget {
  const _ScoreGraphCard({
    required this.points,
    required this.color,
  });

  final List<_ChartPoint> points;
  final Color color;

  String _formatDate(AppLocalizations t, DateTime date, {required bool showMonth}) {
    if (!showMonth) return '${date.day}';
    return '${date.day}\n${_monthShortL10n(t, date.month)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    const tickDays = [3, 10, 17, 24];

    if (points.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F13),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          t.analyticsNoData,
          style: GoogleFonts.poppins(color: Colors.grey[700]),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F13),
        borderRadius: BorderRadius.circular(24),
      ),
      child: SizedBox(
        height: 180,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const bottomPadding = 26.0;
            const leftPadding = 32.0;

            return Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: bottomPadding,
                  width: leftPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _ScoreAxisLabel('100%'),
                      _ScoreAxisLabel('80%'),
                      _ScoreAxisLabel('60%'),
                      _ScoreAxisLabel('40%'),
                      _ScoreAxisLabel('20%'),
                      _ScoreAxisLabel('0%'),
                    ],
                  ),
                ),
                Positioned(
                  left: leftPadding,
                  top: 0,
                  right: 0,
                  bottom: bottomPadding,
                  child: CustomPaint(
                    painter: _ScoreLineChartPainter(
                      points: points,
                      tickDays: tickDays,
                      color: color,
                    ),
                  ),
                ),
                Positioned(
                  left: leftPadding,
                  right: 0,
                  bottom: 0,
                  height: bottomPadding,
                  child: LayoutBuilder(
                    builder: (ctx, box) {
                      final totalPoints = points.length;
                      if (totalPoints == 0) return const SizedBox.shrink();

                      return Stack(
                        children: tickDays.map((day) {
                          final index = day - 1;
                          if (index < 0 || index >= totalPoints) {
                            return const SizedBox.shrink();
                          }

                          final divisor = math.max(1, totalPoints - 1);
                          final tt = index / divisor;
                          final alignX = tt * 2 - 1;

                          final date = points[index].date;
                          final showMonth = day == tickDays.first;
                          final label = _formatDate(t, date, showMonth: showMonth);

                          return Align(
                            alignment: Alignment(alignX, 0),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                height: 1.2,
                                color: Colors.grey[400],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WeeklyCompletionsGraphCard extends StatelessWidget {
  const _WeeklyCompletionsGraphCard({
    required this.points,
    required this.color,
  });

  final List<_ChartPoint> points;
  final Color color;

  String _formatDate(AppLocalizations t, DateTime date, {required bool showMonth}) {
    if (!showMonth) return '${date.day}';
    return '${date.day}\n${_monthShortL10n(t, date.month)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (points.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F13),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          t.analyticsNoData,
          style: GoogleFonts.poppins(color: Colors.grey[700]),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F13),
        borderRadius: BorderRadius.circular(24),
      ),
      child: SizedBox(
        height: 180,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const bottomPadding = 26.0;
            const leftPadding = 32.0;
            final totalPoints = points.length;

            if (totalPoints == 0) return const SizedBox.shrink();

            return Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: bottomPadding,
                  width: leftPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _ScoreAxisLabel('7'),
                      _ScoreAxisLabel('5'),
                      _ScoreAxisLabel('3'),
                      _ScoreAxisLabel('0'),
                    ],
                  ),
                ),
                Positioned(
                  left: leftPadding,
                  top: 0,
                  right: 0,
                  bottom: bottomPadding,
                  child: CustomPaint(
                    painter: _SmoothLineChartPainter(
                      points: points,
                      color: color,
                      maxY: 7.0,
                      labelMode: _LabelMode.ticks,
                      horizontalGridValues: const [7, 5, 3, 0],
                      progress: 1.0,
                      tickIndices: List<int>.generate(totalPoints, (i) => i),
                    ),
                  ),
                ),
                Positioned(
                  left: leftPadding,
                  right: 0,
                  bottom: 0,
                  height: bottomPadding,
                  child: LayoutBuilder(
                    builder: (ctx, box) {
                      final divisor = math.max(1, totalPoints - 1);

                      return Stack(
                        children: [
                          for (int i = 0; i < totalPoints; i++)
                            Builder(
                              builder: (ctx) {
                                final tt = i / divisor;
                                final alignX = tt * 2 - 1;

                                final date = points[i].date;
                                final showMonth = i == 0;
                                final label = _formatDate(t, date, showMonth: showMonth);

                                return Align(
                                  alignment: Alignment(alignX, 0),
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      height: 1.2,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScoreAxisLabel extends StatelessWidget {
  const _ScoreAxisLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 10,
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _RangeToggle extends StatelessWidget {
  const _RangeToggle({
    required this.range,
    required this.onChanged,
  });

  final AnalyticsRange range;
  final ValueChanged<AnalyticsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B20),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RangeChip(
            label: t.analyticsThisWeek,
            selected: range == AnalyticsRange.week,
            onTap: () => onChanged(AnalyticsRange.week),
          ),
          _RangeChip(
            label: t.analyticsThisMonth,
            selected: range == AnalyticsRange.month,
            onTap: () => onChanged(AnalyticsRange.month),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _HeatmapCalendar extends StatelessWidget {
  const _HeatmapCalendar({
    required this.month,
    required this.completionsByDay,
  });

  final DateTime month;
  final Map<DateTime, int> completionsByDay;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = firstDay.weekday; // 1=Mon
    final totalCells = daysInMonth + firstWeekday - 1;

    final weekdayLetters = <String>[
      t.weekdayVeryShortMon,
      t.weekdayVeryShortTue,
      t.weekdayVeryShortWed,
      t.weekdayVeryShortThu,
      t.weekdayVeryShortFri,
      t.weekdayVeryShortSat,
      t.weekdayVeryShortSun,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekdayLetters.map((label) {
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8A8A99),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                return const SizedBox();
              }
              final day = index - (firstWeekday - 1) + 1;
              final date = DateTime(month.year, month.month, day);
              final count = completionsByDay[_stripTime(date)] ?? 0;
              final isCompleted = count > 0;

              final color = isCompleted
                  ? const Color(0xFFE54D5D)
                  : Colors.white.withValues(alpha: 0.05);

              return Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isCompleted ? Colors.white : Colors.grey[600],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* PAINTERS                                                                   */
/* -------------------------------------------------------------------------- */

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
  });

  final double percentage;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.values,
    required this.barColor,
  });

  final List<double> values;
  final Color barColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxValue = values.reduce(math.max).clamp(1.0, double.infinity);

    final bgBarPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final n = values.length;
    final totalSpacing = size.width * 0.25;
    final barWidth = (size.width - totalSpacing) / n;
    final space = totalSpacing / (n + 1);

    for (int i = 0; i < n; i++) {
      final value = values[i];
      final normalized = (value / maxValue).clamp(0.0, 1.0);
      final left = space + i * (barWidth + space);
      final right = left + barWidth;
      final barBottom = size.height;

      canvas.drawRRect(
        RRect.fromLTRBR(left, 0, right, barBottom, const Radius.circular(6)),
        bgBarPaint,
      );

      final barTop = size.height * (1 - normalized);
      final adjustedTop = (value > 0 && barTop == barBottom) ? barBottom - 4 : barTop;

      canvas.drawRRect(
        RRect.fromLTRBR(left, adjustedTop, right, barBottom, const Radius.circular(6)),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.barColor != barColor;
  }
}

class _ScoreLineChartPainter extends CustomPainter {
  _ScoreLineChartPainter({
    required this.points,
    required this.tickDays,
    required this.color,
  });

  final List<_ChartPoint> points;
  final List<int> tickDays;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const yBands = 5;
    for (int i = 0; i <= yBands; i++) {
      final y = size.height * (i / yBands);
      _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final totalDays = points.length;

    for (final day in tickDays) {
      if (day > totalDays) continue;
      final divisor = math.max(1, totalDays - 1);
      final percentX = (day - 1) / divisor;
      final x = size.width * percentX;
      _drawDashedLine(canvas, Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final path = Path();
    final fillPath = Path();
    final dx = totalDays > 1 ? size.width / (totalDays - 1) : 0.0;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final normalized = 1.0 - (p.value / 100.0).clamp(0.0, 1.0);
      final x = dx * i;
      final y = size.height * normalized;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = dx * (i - 1);
        final prevP = points[i - 1];
        final prevY = size.height * (1.0 - (prevP.value / 100.0).clamp(0.0, 1.0));

        final cp1X = prevX + (x - prevX) / 2;
        final cp2X = cp1X;

        path.cubicTo(cp1X, prevY, cp2X, y, x, y);
        fillPath.cubicTo(cp1X, prevY, cp2X, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final gradientShader = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(0, size.height),
      [
        color.withValues(alpha: 0.3),
        color.withValues(alpha: 0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = const Color(0xFF0F0F13)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (final day in tickDays) {
      if (day > totalDays) continue;
      final i = day - 1;
      final p = points[i];
      final normalized = 1.0 - (p.value / 100.0).clamp(0.0, 1.0);
      final x = dx * i;
      final y = size.height * normalized;

      canvas.drawCircle(Offset(x, y), 5, dotBorderPaint);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;

    if ((p1.dy - p2.dy).abs() < 0.01) {
      double x = p1.dx;
      while (x < p2.dx) {
        canvas.drawLine(
          Offset(x, p1.dy),
          Offset(math.min(x + dashWidth, p2.dx), p1.dy),
          paint,
        );
        x += dashWidth + dashSpace;
      }
    } else {
      double y = p1.dy;
      while (y < p2.dy) {
        canvas.drawLine(
          Offset(p1.dx, y),
          Offset(p1.dx, math.min(y + dashWidth, p2.dy)),
          paint,
        );
        y += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreLineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}

class _SmoothLineChartPainter extends CustomPainter {
  _SmoothLineChartPainter({
    required this.points,
    required this.color,
    required this.maxY,
    required this.labelMode,
    this.horizontalGridValues,
    this.progress = 1.0,
    this.tickIndices,
  });

  final List<_ChartPoint> points;
  final Color color;
  final double maxY;
  final _LabelMode labelMode;
  final List<int>? horizontalGridValues;
  final double progress;
  final List<int>? tickIndices;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = const Color(0xFF111116)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final spacing = points.length > 1 ? size.width / (points.length - 1) : 0.0;
    final coords = <Offset>[];

    for (int i = 0; i < points.length; i++) {
      final x = i * spacing;
      final rawNorm = (points[i].value / maxY).clamp(0.0, 1.0);
      final animatedNorm = rawNorm * progress;
      final y = size.height * (1 - animatedNorm);
      coords.add(Offset(x, y));
    }

    final indicesForTicks =
        tickIndices ?? List<int>.generate(coords.length, (i) => i);

    if (labelMode == _LabelMode.ticks) {
      for (final idx in indicesForTicks) {
        if (idx < 0 || idx >= coords.length) continue;
        final c = coords[idx];
        _drawDashedLine(canvas, Offset(c.dx, 0), Offset(c.dx, size.height), gridPaint);
      }
    } else {
      for (final c in coords) {
        _drawDashedLine(canvas, Offset(c.dx, 0), Offset(c.dx, size.height), gridPaint);
      }
    }

    if (horizontalGridValues != null && horizontalGridValues!.isNotEmpty) {
      for (final val in horizontalGridValues!) {
        final norm = (val / maxY).clamp(0.0, 1.0);
        final y = size.height * (1 - norm);
        _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    final path = Path();
    path.moveTo(coords[0].dx, coords[0].dy);
    for (int i = 0; i < coords.length - 1; i++) {
      final p0 = coords[i];
      final p1 = coords[i + 1];
      final cp1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final cp2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(coords.last.dx, size.height)
      ..lineTo(coords.first.dx, size.height)
      ..close();

    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(0, size.height),
      [
        color.withValues(alpha: 0.3 * progress),
        color.withValues(alpha: 0.0),
      ],
    );

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = gradient
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(path, linePaint);

    if (labelMode == _LabelMode.ticks) {
      for (final idx in indicesForTicks) {
        if (idx < 0 || idx >= coords.length) continue;
        final c = coords[idx];
        canvas.drawCircle(c, 5.0, dotBorderPaint);
        canvas.drawCircle(c, 3.5, dotPaint);
      }
    } else {
      for (final c in coords) {
        canvas.drawCircle(c, 5.0, dotBorderPaint);
        canvas.drawCircle(c, 3.5, dotPaint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;

    if (p1.dy == p2.dy) {
      double x = p1.dx;
      while (x < p2.dx) {
        canvas.drawLine(
          Offset(x, p1.dy),
          Offset(math.min(x + dashWidth, p2.dx), p1.dy),
          paint,
        );
        x += dashWidth + dashSpace;
      }
    } else {
      double y = p1.dy;
      while (y < p2.dy) {
        canvas.drawLine(
          Offset(p1.dx, y),
          Offset(p1.dx, math.min(y + dashWidth, p2.dy)),
          paint,
        );
        y += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SmoothLineChartPainter oldDelegate) {
    return true;
  }
}
