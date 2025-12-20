// lib/features/explore/presentation/explore_screen.dart
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0B0E);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(
                onTapClose: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 14),

              const _HeroExploreCard(),
              const SizedBox(height: 18),

              _Section(
                title: 'Most Popular Routines',
                routines: _ExploreData.mostPopular,
              ),
              const SizedBox(height: 18),

              _Section(
                title: 'Become Better You',
                routines: _ExploreData.becomeBetter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onTapClose});
  final VoidCallback onTapClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onTapClose,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: const Icon(Icons.grid_view_rounded,
                color: Colors.white70, size: 20),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Explore',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: const Icon(Icons.local_fire_department_rounded,
                color: Colors.white70, size: 20),
          ),
        ),
      ],
    );
  }
}

class _HeroExploreCard extends StatelessWidget {
  const _HeroExploreCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'lib/assets/pink_purple_grad.jpg',
              fit: BoxFit.cover,
            ),
            // dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    'Intelligent\nProjects are\nhere',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create Projects with AI\nTeammates, Notes, Tasks and\nFiles',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      height: 1.2,
                      color: Colors.white.withValues(alpha: 0.80),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Create free project',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 16, color: Colors.white),
                    ],
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.routines});
  final String title;
  final List<_RoutineTemplate> routines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: routines.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, i) {
            return _RoutineCard(
              routine: routines[i],
              onTap: () => _RoutineDetailsSheet.show(context, routines[i]),
            );
          },
        ),
      ],
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.routine, required this.onTap});
  final _RoutineTemplate routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // inside _RoutineCard build():
            Image.asset(
              routine.imageAsset,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ROUTINE',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.orangeAccent.withValues(alpha: 0.85),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    routine.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        routine.rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.70),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.star_rounded,
                          size: 14, color: Colors.white.withValues(alpha: 0.55)),
                    ],
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

class _RoutineDetailsSheet {
  static Future<void> show(BuildContext context, _RoutineTemplate routine) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => _RoutineDetailsBody(routine: routine),
    );
  }
}

class _RoutineDetailsBody extends StatefulWidget {
  const _RoutineDetailsBody({required this.routine});
  final _RoutineTemplate routine;

  @override
  State<_RoutineDetailsBody> createState() => _RoutineDetailsBodyState();
}

class _RoutineDetailsBodyState extends State<_RoutineDetailsBody> {
  late final Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {for (int i = 0; i < widget.routine.habits.length; i++) i};
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.routine;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F13),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          children: [
            // Header image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: Image.asset(r.imageAsset, fit: BoxFit.cover),
                  ),
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.78),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(999),
                      child: Ink(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ROUTINE',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.orangeAccent.withValues(alpha: 0.85),
                            letterSpacing: 0.9,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          r.title,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              r.rating.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.star_rounded,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.55)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Habits',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...List.generate(r.habits.length, (i) {
                      final h = r.habits[i];
                      final selected = _selected.contains(i);

                      return _HabitRow(
                        title: h.title,
                        subtitle: h.subtitle,
                        selected: selected,
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selected.remove(i);
                            } else {
                              _selected.add(i);
                            }
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                    SizedBox(height: bottomInset),
                  ],
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () async {
                    final count = _selected.length;
                    final ok = await _ConfirmCopySheet.show(context, count);
                    if (ok != true) return;

                    if (!context.mounted) return;
                    await _copySelectedHabits(
                      context: context,
                      routine: r,
                      selectedIndexes: _selected.toList()..sort(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2A33),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Copy ${_selected.length} habits',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copySelectedHabits({
    required BuildContext context,
    required _RoutineTemplate routine,
    required List<int> selectedIndexes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to copy habits.')),
      );
      return;
    }

    final db = FirebaseFirestore.instance;
    final habitsCol = db.collection('users').doc(user.uid).collection('habits');

    final batch = db.batch();
    final random = math.Random();

    for (final idx in selectedIndexes) {
      final h = routine.habits[idx];

      // Match your app's habit schema
      final docRef = habitsCol.doc();
      final color = _seededAccent(random);

      batch.set(docRef, <String, dynamic>{
        'title': h.title,
        'description': h.subtitle,
        'color': color.toARGB32(),
        'repeatEnabled': true,
        'repeatType': 'daily',
        'repeatData': <String, dynamic>{
          'daysOfWeek': [1, 2, 3, 4, 5, 6, 7],
        },
        'reminderEnabled': false,
        'reminderTime': null,
        'goalEnabled': false,
        'goalValue': null,
        'goalUnit': null,
        'goalText': null,
        'createdAt': FieldValue.serverTimestamp(),
        'historyStartMonth': Timestamp.fromDate(
          DateTime(DateTime.now().year, DateTime.now().month, 1),
        ),
        'completedDates': <String>[],
        'progressByDate': <String, dynamic>{},
      });
    }

    try {
      await batch.commit();
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied ${selectedIndexes.length} habits'),
          duration: const Duration(milliseconds: 900),
        ),
      );

      // Close the details sheet after copy
      Navigator.of(context).pop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not copy habits. Try again.')),
      );
    }
  }

  Color _seededAccent(math.Random r) {
    const accents = [
      Color(0xFF5CE1E6),
      Color(0xFF6C5CE7),
      Color(0xFFFF7675),
      Color(0xFF00B894),
      Color(0xFFFFA726),
      Color(0xFF42A5F5),
    ];
    return accents[r.nextInt(accents.length)];
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.85)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.0)
                        : Colors.white.withValues(alpha: 0.20),
                    width: 1.2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                    size: 16, color: Colors.black)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.35), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmCopySheet {
  static Future<bool?> show(BuildContext context, int count) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF15151A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Copy habits?',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$count habits will be created.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C7DFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Yes',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

/// --------- Data ---------

class _ExploreData {
  static final mostPopular = <_RoutineTemplate>[
    _RoutineTemplate(
      title: 'Overcome\nProcrastination',
      subtitle: 'Routine',
      rating: 4.7,
      imageAsset: 'lib/assets/routine_procrastination.jpg',
      description:
      'Procrastination can sabotage your productivity and hinder your success, '
          'but it doesn’t have to dictate your future. This routine offers evidence-based '
          'strategies to help you overcome procrastination and build momentum.',
      habits: const [
        _HabitTemplate(
          title: 'Pomodoro Technique',
          subtitle: 'Use focused 25-min blocks with short breaks.',
        ),
        _HabitTemplate(
          title: 'Time Blocking',
          subtitle: 'Schedule your day into clear task windows.',
        ),
        _HabitTemplate(
          title: 'Eat That Frog',
          subtitle: 'Do the hardest task first to reduce avoidance.',
        ),
        _HabitTemplate(
          title: 'Break Tasks into Smaller Steps',
          subtitle: 'Turn big tasks into small, actionable steps.',
        ),
        _HabitTemplate(
          title: 'Set SMART Goals',
          subtitle: 'Specific, Measurable, Achievable, Relevant, Time-bound.',
        ),
      ],
    ),
    _RoutineTemplate(
      title: 'Relieve\nAnxiety',
      subtitle: 'Routine',
      rating: 4.6,
      imageAsset: 'lib/assets/anxiety_relief.jpg',
      description:
      'A practical routine to lower baseline stress and reduce anxious spirals '
          'with small daily actions.',
      habits: const [
        _HabitTemplate(title: 'Box Breathing', subtitle: '4-4-4-4 breathing cycle.'),
        _HabitTemplate(title: 'Short Walk', subtitle: '10 minutes outside if possible.'),
        _HabitTemplate(title: 'Journal Dump', subtitle: 'Write thoughts without filtering.'),
        _HabitTemplate(title: 'Limit Caffeine', subtitle: 'Reduce triggers after noon.'),
        _HabitTemplate(title: 'Sleep Wind-down', subtitle: 'Consistent pre-sleep ritual.'),
      ],
    ),
    _RoutineTemplate(
      title: 'Focus\nBoost',
      subtitle: 'Routine',
      rating: 4.5,
      imageAsset: 'lib/assets/focus_boost.jpg',
      description:
      'Strengthen your focus with a compact routine designed for deep work.',
      habits: const [
        _HabitTemplate(title: 'No-Phone Start', subtitle: 'First 30 mins without scrolling.'),
        _HabitTemplate(title: 'Deep Work Block', subtitle: 'One 45–60 min focus sprint.'),
        _HabitTemplate(title: 'Single Task List', subtitle: 'Pick 1–3 outcomes max.'),
        _HabitTemplate(title: 'Hydrate', subtitle: 'Water before coffee.'),
      ],
    ),
    _RoutineTemplate(
      title: 'Morning\nMomentum',
      subtitle: 'Routine',
      rating: 4.4,
      imageAsset: 'lib/assets/morning_momentum.jpg',
      description:
      'Start the day with momentum and a clear plan.',
      habits: const [
        _HabitTemplate(title: 'Make the Bed', subtitle: 'Quick win to start.'),
        _HabitTemplate(title: 'Top 3 Priorities', subtitle: 'Write the day’s outcomes.'),
        _HabitTemplate(title: 'Stretch', subtitle: '2–5 minutes full body.'),
        _HabitTemplate(title: 'Protein Breakfast', subtitle: 'Stable energy.'),
      ],
    ),
  ];

  static final becomeBetter = <_RoutineTemplate>[
    _RoutineTemplate(
      title: 'Creativity\nBoosting\nRoutine',
      subtitle: 'Routine',
      rating: 4.5,
      imageAsset: 'lib/assets/creativity_boosting.jpg',
      description:
      'A simple routine to increase creative output and reduce friction.',
      habits: const [
        _HabitTemplate(title: 'Idea Capture', subtitle: 'Write 5 ideas daily.'),
        _HabitTemplate(title: 'Create Before Consume', subtitle: 'Make first, scroll later.'),
        _HabitTemplate(title: 'Input Walk', subtitle: 'Take a walk for inspiration.'),
        _HabitTemplate(title: 'Daily Sketch', subtitle: '2 minutes, no pressure.'),
      ],
    ),
    _RoutineTemplate(
      title: 'Productivity\nEnhancer\nRoutine',
      subtitle: 'Routine',
      rating: 4.6,
      imageAsset: 'lib/assets/productivity_enhancer.jpeg',
      description:
      'Improve output with better planning and execution habits.',
      habits: const [
        _HabitTemplate(title: 'Plan Tomorrow', subtitle: 'End-of-day 5-minute plan.'),
        _HabitTemplate(title: 'Inbox Zero', subtitle: 'Clear messages in one block.'),
        _HabitTemplate(title: 'Two-Minute Rule', subtitle: 'Do it now if it’s quick.'),
        _HabitTemplate(title: 'Shutdown Ritual', subtitle: 'Close loops, end work cleanly.'),
      ],
    ),
    _RoutineTemplate(
      title: 'Build\nConfidence',
      subtitle: 'Routine',
      rating: 4.4,
      imageAsset: 'lib/assets/build_confidence.jpg',
      description:
      'Small daily actions to build confidence and consistency.',
      habits: const [
        _HabitTemplate(title: 'Daily Win', subtitle: 'Record one win every day.'),
        _HabitTemplate(title: 'Practice Skill', subtitle: '10 minutes deliberate practice.'),
        _HabitTemplate(title: 'Posture Reset', subtitle: '2x daily check-in.'),
        _HabitTemplate(title: 'Positive Reframe', subtitle: 'Rewrite the story in your head.'),
      ],
    ),
    _RoutineTemplate(
      title: 'Better\nSleep',
      subtitle: 'Routine',
      rating: 4.7,
      imageAsset: 'lib/assets/better_sleep.jpeg',
      description:
      'A calming routine to improve sleep quality and recovery.',
      habits: const [
        _HabitTemplate(title: 'No Screens', subtitle: 'Avoid screens 30 mins before bed.'),
        _HabitTemplate(title: 'Cool Room', subtitle: 'Lower temp for better sleep.'),
        _HabitTemplate(title: 'Read', subtitle: '10 pages of a book.'),
        _HabitTemplate(title: 'Same Bedtime', subtitle: 'Consistency beats perfection.'),
      ],
    ),
  ];
}

class _RoutineTemplate {
  _RoutineTemplate({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.description,
    required this.habits,
    required this.imageAsset,
  });

  final String title;
  final String subtitle;
  final double rating;
  final String description;
  final List<_HabitTemplate> habits;
  final String imageAsset;
}

class _HabitTemplate {
  const _HabitTemplate({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}
