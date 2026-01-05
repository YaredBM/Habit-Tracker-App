import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/features/analytics/presentation/analytics_screen.dart';
import 'create_habit_screen.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import '/l10n/app_localizations.dart';

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

String _monthShort(AppLocalizations t, int month) {
  switch (month) {
    case 1:
      return t.habitDetailMonthJanShort;
    case 2:
      return t.habitDetailMonthFebShort;
    case 3:
      return t.habitDetailMonthMarShort;
    case 4:
      return t.habitDetailMonthAprShort;
    case 5:
      return t.habitDetailMonthMayShort;
    case 6:
      return t.habitDetailMonthJunShort;
    case 7:
      return t.habitDetailMonthJulShort;
    case 8:
      return t.habitDetailMonthAugShort;
    case 9:
      return t.habitDetailMonthSepShort;
    case 10:
      return t.habitDetailMonthOctShort;
    case 11:
      return t.habitDetailMonthNovShort;
    case 12:
      return t.habitDetailMonthDecShort;
    default:
      return t.habitDetailMonthJanShort;
  }
}

class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({
    super.key,
    required this.habitId,
    required this.initialData,
    this.onEdit,
    this.onDelete,
    this.onUpdateProgress,
  });

  final String habitId;
  final Map<String, dynamic> initialData;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onDelete;
  final Future<void> Function()? onUpdateProgress;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            t.habitDetailPleaseSignInHabits,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final docStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .doc(habitId)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docStream,
      builder: (context, snapshot) {
        final t = AppLocalizations.of(context)!;
        final data = snapshot.data?.data() ?? initialData;

        final title = data['title'] as String? ?? t.habitDetailDefaultHabitTitle;
        final description = data['description'] as String?;
        final colorValue = data['color'] as int? ?? 0xFF5CE1E6;
        final completedDates =
        (data['completedDates'] as List<dynamic>? ?? []).cast<String>();

        // We keep goalValue for writes, but don't strictly need it for the chart history
        final rawGoalValue = (data['goalValue'] as int?) ?? 1;
        final goalValue = rawGoalValue <= 0 ? 1 : rawGoalValue;

        final color = Color(colorValue);
        final completedSet = _parseDates(completedDates);
        final bestStreak = _bestStreak(completedSet);
        final currentStreak = _currentStreak(completedSet);
        final totalCompletions = completedSet.length;
        final score = _calculateScore(completedSet);
        final createdAtRaw = data['createdAt'];
        final createdAt =
        createdAtRaw is Timestamp ? createdAtRaw.toDate() : DateTime.now();

        // Stored month anchor (recommended to persist on habit creation)
        final hsmRaw = data['historyStartMonth'];
        final historyStartMonth = hsmRaw is Timestamp
            ? DateTime(hsmRaw.toDate().year, hsmRaw.toDate().month, 1)
            : DateTime(createdAt.year, createdAt.month, 1);

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: onEdit ??
                        () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreateHabitScreen(
                            habitId: habitId,
                            initialData: data,
                          ),
                        ),
                      );

                      if (context.mounted && result is String) {
                        Navigator.of(context).pop(result);
                      }
                    },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () async {
                  final confirmed = await _confirmDelete(context);
                  if (confirmed) {
                    if (onDelete != null) {
                      await onDelete!();
                    } else {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('habits')
                          .doc(habitId)
                          .delete();
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop('deleted');
                    }
                  }
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (description != null && description.isNotEmpty) ...[
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _StatsRow(
                    color: color,
                    score: score,
                    total: totalCompletions,
                    bestStreak: bestStreak,
                    currentStreak: currentStreak,
                  ),
                  const SizedBox(height: 20),

                  // --- HISTORY SECTION ---
                  _HistorySection(
                    color: color,
                    completedDates: completedSet,
                    historyStartMonth: historyStartMonth,
                    monthsBackFallback: 3, // last 3 months including current
                    onToggleDate: (date, isComplete) async {
                      final t = AppLocalizations.of(context)!;
                      final messenger = ScaffoldMessenger.of(context);
                      final dateKey = _dateKey(date);

                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('habits')
                            .doc(habitId)
                            .update({
                          'completedDates': isComplete
                              ? FieldValue.arrayRemove([dateKey])
                              : FieldValue.arrayUnion([dateKey]),
                          'progressByDate.$dateKey':
                          isComplete ? FieldValue.delete() : goalValue,
                        });

                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              isComplete
                                  ? t.habitDetailMarkedIncompleteDay
                                  : t.habitDetailMarkedCompleteDay,
                            ),
                            duration: const Duration(milliseconds: 900),
                          ),
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(t.habitDetailCouldNotUpdateDay),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- SCORE SECTION ---
                  _ScoreSection(
                    habitId: habitId,
                    color: color,
                    completedDates: completedSet,
                  ),

                  const SizedBox(height: 20),
                  _NotesSection(
                    color: color,
                    habitId: habitId,
                    habitTitle: title,
                  ),
                  if (onUpdateProgress != null) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onUpdateProgress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          t.habitDetailUpdateProgress,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final t = AppLocalizations.of(context)!;

    return await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF15151A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            t.habitDetailDeleteHabitTitle,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          content: Text(
            t.habitDetailDeleteHabitMessage,
            style: GoogleFonts.poppins(
              color: Colors.grey[300],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(t.habitDetailCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(t.habitDetailDelete),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  Set<DateTime> _parseDates(List<String> dates) {
    final set = <DateTime>{};
    for (final s in dates) {
      try {
        final d = DateTime.parse(s);
        set.add(DateTime(d.year, d.month, d.day));
      } catch (_) {
        continue;
      }
    }
    return set;
  }

  int _currentStreak(Set<DateTime> completed) {
    int streak = 0;
    DateTime cursor = DateTime.now();
    // Normalize to date only
    cursor = DateTime(cursor.year, cursor.month, cursor.day);

    // Check today first, if not done, check yesterday to continue streak
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

  int _calculateScore(Set<DateTime> completions) {
    final now = DateTime.now();
    final currentMonthCompletions = completions.where(
          (d) => d.year == now.year && d.month == now.month,
    );

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final completionCount = currentMonthCompletions.length;
    if (daysInMonth == 0) return 0; // Prevent div by zero

    return ((completionCount / daysInMonth) * 100).clamp(0, 100).round();
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.color,
    required this.score,
    required this.total,
    required this.bestStreak,
    required this.currentStreak,
  });

  final Color color;
  final int score;
  final int total;
  final int bestStreak;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: t.habitDetailStatScore,
            value: '$score%',
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: t.habitDetailStatTotal,
            value: '$total',
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: t.habitDetailStatBestStreak,
            value: '$bestStreak',
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: t.habitDetailStatStreak,
            value: '$currentStreak',
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

// --- REDESIGNED SCORE SECTION ---
class _ScoreSection extends StatelessWidget {
  const _ScoreSection({
    required this.habitId,
    required this.color,
    required this.completedDates,
  });

  final String habitId;
  final Color color;
  final Set<DateTime> completedDates;

  List<_ChartPoint> _points() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final lastPlottableDay = now.day.clamp(1, lastDayOfMonth);

    final points = <_ChartPoint>[];
    int completedSoFar = 0;

    for (int day = 1; day <= lastPlottableDay; day++) {
      final date = DateTime(now.year, now.month, day);
      if (completedDates.contains(date)) {
        completedSoFar++;
      }

      final double score = (completedSoFar / day * 100.0).clamp(0.0, 100.0);
      points.add(_ChartPoint(date: date, value: score));
    }
    return points;
  }

  String _formatDate(AppLocalizations t, int day, bool showMonth) {
    if (showMonth) {
      final now = DateTime.now();
      return '$day\n${_monthShort(t, now.month)}';
    }
    return '$day';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final points = _points();
    final tickDays = [3, 10, 17, 24];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              t.habitDetailScoreTitle,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AnalyticsScreen(habitId: habitId),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    t.habitDetailAnalytics,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF2E6FD0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      size: 18, color: Color(0xFF2E6FD0)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 240,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F13),
            borderRadius: BorderRadius.circular(24),
          ),
          child: points.isEmpty
              ? Center(
            child: Text(
              t.habitDetailNoDataYet,
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          )
              : LayoutBuilder(
            builder: (context, constraints) {
              const bottomPadding = 30.0;
              const leftPadding = 30.0;

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
                        _AxisLabel('100%'),
                        _AxisLabel('80%'),
                        _AxisLabel('60%'),
                        _AxisLabel('40%'),
                        _AxisLabel('20%'),
                        _AxisLabel('0%'),
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
                        return Stack(
                          children: tickDays.map((day) {
                            final index = day - 1;
                            final totalPoints = points.length;
                            if (index >= totalPoints) {
                              return const SizedBox();
                            }

                            final percentX = index / (totalPoints - 1);
                            final alignX = (percentX * 2) - 1;

                            return Align(
                              alignment: Alignment(alignX, 0),
                              child: Text(
                                _formatDate(t, day, day == 3),
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
      ],
    );
  }
}

class _ChartPoint {
  _ChartPoint({required this.date, required this.value});
  final DateTime date;
  final double value;
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
        final prevY = size.height *
            (1.0 - (prevP.value / 100.0).clamp(0.0, 1.0));

        final cp1X = prevX + (x - prevX) / 2;
        final cp2X = prevX + (x - prevX) / 2;

        path.cubicTo(cp1X, prevY, cp2X, y, x, y);
        fillPath.cubicTo(cp1X, prevY, cp2X, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final gradientShader = ui.Gradient.linear(
      Offset(0, 0),
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
    double startX = p1.dx;
    double startY = p1.dy;

    if (p1.dy == p2.dy) {
      while (startX < p2.dx) {
        canvas.drawLine(
          Offset(startX, startY),
          Offset(math.min(startX + dashWidth, p2.dx), startY),
          paint,
        );
        startX += dashWidth + dashSpace;
      }
    } else {
      while (startY < p2.dy) {
        canvas.drawLine(
          Offset(startX, startY),
          Offset(startX, math.min(startY + dashWidth, p2.dy)),
          paint,
        );
        startY += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreLineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.text);
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

// --- HISTORY SECTION ---
class _HistorySection extends StatefulWidget {
  const _HistorySection({
    required this.color,
    required this.completedDates,
    required this.onToggleDate,
    required this.historyStartMonth,
    this.monthsBackFallback = 3,
  });

  final Color color;
  final Set<DateTime> completedDates;
  final void Function(DateTime date, bool isComplete) onToggleDate;

  final DateTime historyStartMonth;
  final int monthsBackFallback;

  @override
  State<_HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<_HistorySection> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _monthForPage(int page) {
    final now = DateTime.now();
    return DateTime(now.year, now.month - page, 1);
  }

  String _headerLabelForMonth(DateTime month) {
    final t = AppLocalizations.of(context)!;
    return '${_monthShort(t, month.month)} ${month.year}';
  }

  int _monthsBetweenInclusive(DateTime startMonth, DateTime endMonth) {
    final s = DateTime(startMonth.year, startMonth.month, 1);
    final e = DateTime(endMonth.year, endMonth.month, 1);
    return (e.year - s.year) * 12 + (e.month - s.month) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final currentMonth = DateTime(now.year, now.month, 1);

    final fallbackStartMonth = DateTime(
      now.year,
      now.month - (widget.monthsBackFallback - 1),
      1,
    );

    final historyStartMonth = DateTime(
      widget.historyStartMonth.year,
      widget.historyStartMonth.month,
      1,
    );

    final earliestMonth = historyStartMonth.isBefore(fallbackStartMonth)
        ? historyStartMonth
        : fallbackStartMonth;

    final totalMonths =
    _monthsBetweenInclusive(earliestMonth, currentMonth).clamp(1, 240);

    final normalizedCompleted = widget.completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              t.habitDetailHistory,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                final page =
                _pageController.hasClients ? (_pageController.page ?? 0.0) : 0.0;
                final index = page.round().clamp(0, totalMonths - 1);
                final month = _monthForPage(index);
                return Text(
                  _headerLabelForMonth(month),
                  style:
                  GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            reverse: true,
            itemCount: totalMonths,
            itemBuilder: (context, index) {
              final monthStart = _monthForPage(index);
              final year = monthStart.year;
              final month = monthStart.month;

              final firstDay = DateTime(year, month, 1);
              final totalDays = DateTime(year, month + 1, 0).day;

              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.color.withValues(alpha: 0.35)),
                ),
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: totalDays + firstDay.weekday - 1,
                  itemBuilder: (context, gridIndex) {
                    if (gridIndex < firstDay.weekday - 1) {
                      return const SizedBox.shrink();
                    }

                    final dayNumber = gridIndex - firstDay.weekday + 2;
                    final date = DateTime(year, month, dayNumber);
                    final dateKey = DateTime(date.year, date.month, date.day);

                    final isDone = normalizedCompleted.contains(dateKey);
                    final isFuture = date.isAfter(today);

                    return GestureDetector(
                      onTap: isFuture ? null : () => widget.onToggleDate(date, isDone),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isFuture
                              ? Colors.white.withValues(alpha: 0.04)
                              : isDone
                              ? widget.color
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: isFuture
                              ? Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          )
                              : null,
                        ),
                        child: Text(
                          '$dayNumber',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDone
                                ? Colors.black
                                : isFuture
                                ? Colors.grey[600]
                                : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({
    required this.color,
    required this.habitId,
    required this.habitTitle,
  });

  final Color color;
  final String habitId;
  final String habitTitle;

  Future<void> _deleteNote({
    required BuildContext context,
    required String uid,
    required String habitId,
    required String noteId,
  }) async {
    final t = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF15151A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          t.habitDetailDeleteNoteTitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          t.habitDetailDeleteNoteMessage,
          style: GoogleFonts.poppins(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.habitDetailCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.habitDetailDelete),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirmed) return;

    final db = FirebaseFirestore.instance;

    final habitNoteRef = db
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(habitId)
        .collection('notes')
        .doc(noteId);

    final journalRef =
    db.collection('users').doc(uid).collection('journal').doc(noteId);

    final batch = db.batch();
    batch.delete(habitNoteRef);
    batch.delete(journalRef);

    await batch.commit();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.habitDetailNoteDeleted),
          duration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _notesShell(
        child: Text(
          t.habitDetailPleaseSignInNotes,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
        ),
      );
    }

    final notesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .doc(habitId)
        .collection('notes')
        .orderBy('entryDate', descending: true)
        .snapshots();

    String formatDayHeader(DateTime day) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final isToday = day == today;
      if (isToday) return t.habitDetailToday;
      return '${_two(day.day)}/${_two(day.month)}/${day.year}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              t.habitDetailNotes,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () async {
                final draft = await showModalBottomSheet<_NoteDraft>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _AddNoteSheet(
                    accent: const Color(0xFF2E6FD0),
                    habitTitle: habitTitle,
                  ),
                );

                if (draft == null) return;

                final text = draft.text.trim();
                if (text.isEmpty) return;

                final selected = draft.date;

                try {
                  final db = FirebaseFirestore.instance;
                  final uid = user.uid;

                  final noteId =
                      db.collection('users').doc(uid).collection('journal').doc().id;

                  final habitNoteRef = db
                      .collection('users')
                      .doc(uid)
                      .collection('habits')
                      .doc(habitId)
                      .collection('notes')
                      .doc(noteId);

                  final journalRef = db
                      .collection('users')
                      .doc(uid)
                      .collection('journal')
                      .doc(noteId);

                  final noteData = <String, dynamic>{
                    'text': text,
                    'entryDate': Timestamp.fromDate(selected),
                    'createdAt': FieldValue.serverTimestamp(),
                    'updatedAt': FieldValue.serverTimestamp(),
                    'habitId': habitId,
                    'habitTitle': habitTitle,
                    'noteId': noteId,
                  };

                  final batch = db.batch();
                  batch.set(habitNoteRef, noteData);
                  batch.set(journalRef, noteData);
                  await batch.commit();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t.habitDetailNoteSaved),
                        duration: const Duration(milliseconds: 900),
                      ),
                    );
                  }
                } on FirebaseException catch (e) {
                  debugPrint('Save note failed (${e.code}): ${e.message}');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t.habitDetailCouldNotSaveNoteWithCode(e.code)),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Save note failed: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.habitDetailCouldNotSaveNote)),
                    );
                  }
                }
              },
              child: Text(
                t.habitDetailAddNote,
                style: GoogleFonts.poppins(color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: notesStream,
          builder: (context, snap) {
            final t = AppLocalizations.of(context)!;

            if (snap.hasError) {
              return _notesShell(
                child: Text(
                  t.habitDetailCouldNotLoadNotes,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
                ),
              );
            }

            if (snap.connectionState == ConnectionState.waiting) {
              return _notesShell(
                child: Text(
                  t.habitDetailLoading,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
                ),
              );
            }

            final docs = snap.data?.docs ?? const [];
            if (docs.isEmpty) {
              return _notesShell(
                child: Text(
                  t.habitDetailNoNotesYet,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
                ),
              );
            }

            final groups = <DateTime, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
            final order = <DateTime>[];

            for (final d in docs) {
              final data = d.data();
              final ts =
                  (data['entryDate'] as Timestamp?) ?? (data['createdAt'] as Timestamp?);
              final dt = ts?.toDate() ?? DateTime.now();
              final day = DateTime(dt.year, dt.month, dt.day);

              if (!groups.containsKey(day)) {
                groups[day] = [];
                order.add(day);
              }
              groups[day]!.add(d);
            }

            return Column(
              children: order.map((day) {
                final list = groups[day]!;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDayHeader(day),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...list.map((doc) {
                        final data = doc.data();
                        final text = (data['text'] as String?) ?? '';
                        final ts = (data['entryDate'] as Timestamp?) ??
                            (data['createdAt'] as Timestamp?);
                        final dt = ts?.toDate() ?? DateTime.now();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatTime(dt),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  text,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    height: 1.35,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                onPressed: () async {
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user == null) return;

                                  await _deleteNote(
                                    context: context,
                                    uid: user.uid,
                                    habitId: habitId,
                                    noteId: doc.id,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _notesShell({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  String _formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';
  String _two(int n) => n.toString().padLeft(2, '0');
}

class _NoteDraft {
  _NoteDraft({required this.text, required this.date});
  final String text;
  final DateTime date;
}

class _AddNoteSheet extends StatefulWidget {
  const _AddNoteSheet({
    required this.accent,
    required this.habitTitle,
  });

  final Color accent;
  final String habitTitle;

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  late final TextEditingController _controller;
  DateTime _selected = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CupertinoDateTimePickerSheet(initial: _selected),
    );
    if (picked != null && mounted) {
      setState(() => _selected = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final h = MediaQuery.of(context).size.height;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: h * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFF0F0F13),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  t.habitDetailWhatHappenedToday,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    GestureDetector(
                      onTap: _pickDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatChipDate(_selected),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    if (widget.habitTitle.trim().isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.habitTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: widget.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.accent.withValues(alpha: 0.30),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(
                            _NoteDraft(
                              text: _controller.text,
                              date: _selected,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatChipDate(DateTime d) {
    final t = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final isToday = now.year == d.year && now.month == d.month && now.day == d.day;

    final time = '${_two(d.hour)}:${_two(d.minute)}';
    if (isToday) return t.habitDetailTodayTime(time);

    return '${_two(d.day)}/${_two(d.month)}/${d.year}  $time';
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

class _CupertinoDateTimePickerSheet extends StatefulWidget {
  const _CupertinoDateTimePickerSheet({required this.initial});
  final DateTime initial;

  @override
  State<_CupertinoDateTimePickerSheet> createState() =>
      _CupertinoDateTimePickerSheetState();
}

class _CupertinoDateTimePickerSheetState
    extends State<_CupertinoDateTimePickerSheet> {
  late DateTime _temp;

  @override
  void initState() {
    super.initState();
    _temp = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return SizedBox(
      height: 320,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    t.habitDetailPickerCancel,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_temp),
                  child: Text(
                    t.habitDetailPickerDone,
                    style: const TextStyle(
                      color: Color(0xFF4C7DFF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoTheme(
              data: const CupertinoThemeData(brightness: Brightness.dark),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: widget.initial,
                onDateTimeChanged: (d) => _temp = d,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
