// lib/features/explore/presentation/explore_screen.dart
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/l10n/app_localizations.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

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
                title: t.exploreMostPopularRoutines,
                routines: _ExploreData.mostPopular(t),
              ),
              const SizedBox(height: 18),

              _Section(
                title: t.exploreBecomeBetterYou,
                routines: _ExploreData.becomeBetter(t),
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
    final t = AppLocalizations.of(context)!;

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
          t.exploreTitle,
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
    final t = AppLocalizations.of(context)!;

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
                    t.exploreHeroHeadline,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.exploreHeroSubtitle,
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
                        t.exploreHeroCta,
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
    final t = AppLocalizations.of(context)!;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
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
                    t.exploreRoutineTag,
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
    final t = AppLocalizations.of(context)!;

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
                          t.exploreRoutineTag,
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
                      t.exploreHabitsTitle,
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
                    t.exploreCopyHabitsButton(_selected.length),
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
    final t = AppLocalizations.of(context)!;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.explorePleaseSignInToCopyHabits)),
      );
      return;
    }

    final db = FirebaseFirestore.instance;
    final habitsCol = db.collection('users').doc(user.uid).collection('habits');

    final batch = db.batch();
    final random = math.Random();

    for (final idx in selectedIndexes) {
      final h = routine.habits[idx];

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
          content: Text(t.exploreCopiedHabitsSnack(selectedIndexes.length)),
          duration: const Duration(milliseconds: 900),
        ),
      );

      Navigator.of(context).pop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.exploreCouldNotCopyHabits)),
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
    final t = AppLocalizations.of(context)!;

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
                    t.exploreConfirmCopyTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.exploreConfirmCopySubtitle(count),
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
                            t.exploreYes,
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
                        t.exploreCancel,
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
  static List<_RoutineTemplate> mostPopular(AppLocalizations t) => <_RoutineTemplate>[
    _RoutineTemplate(
      title: t.exploreRoutineProcrastinationTitle,
      subtitle: t.exploreRoutineTag,
      rating: 4.7,
      imageAsset: 'lib/assets/routine_procrastination.jpg',
      description: t.exploreRoutineProcrastinationDescription,
      habits: <_HabitTemplate>[
        _HabitTemplate(title: t.exploreHabitPomodoroTitle, subtitle: t.exploreHabitPomodoroSubtitle),
        _HabitTemplate(title: t.exploreHabitTimeBlockingTitle, subtitle: t.exploreHabitTimeBlockingSubtitle),
        _HabitTemplate(title: t.exploreHabitEatThatFrogTitle, subtitle: t.exploreHabitEatThatFrogSubtitle),
        _HabitTemplate(title: t.exploreHabitBreakTasksTitle, subtitle: t.exploreHabitBreakTasksSubtitle),
        _HabitTemplate(title: t.exploreHabitSmartGoalsTitle, subtitle: t.exploreHabitSmartGoalsSubtitle),
      ],
    ),
    _RoutineTemplate(
      title: t.exploreRoutineAnxietyTitle,
      subtitle: t.exploreRoutineTag,
      rating: 4.6,
      imageAsset: 'lib/assets/anxiety_relief.jpg',
      description: t.exploreRoutineAnxietyDescription,
      habits: <_HabitTemplate>[
        _HabitTemplate(title: t.exploreHabitBoxBreathingTitle, subtitle: t.exploreHabitBoxBreathingSubtitle),
        _HabitTemplate(title: t.exploreHabitShortWalkTitle, subtitle: t.exploreHabitShortWalkSubtitle),
        _HabitTemplate(title: t.exploreHabitJournalDumpTitle, subtitle: t.exploreHabitJournalDumpSubtitle),
        _HabitTemplate(title: t.exploreHabitLimitCaffeineTitle, subtitle: t.exploreHabitLimitCaffeineSubtitle),
        _HabitTemplate(title: t.exploreHabitSleepWindDownTitle, subtitle: t.exploreHabitSleepWindDownSubtitle),
      ],
    ),
    _RoutineTemplate(
      title: t.exploreRoutineFocusBoostTitle,
      subtitle: t.exploreRoutineTag,
      rating: 4.5,
      imageAsset: 'lib/assets/focus_boost.jpg',
      description: t.exploreRoutineFocusBoostDescription,
      habits: <_HabitTemplate>[
        _HabitTemplate(title: t.exploreHabitNoPhoneStartTitle, subtitle: t.exploreHabitNoPhoneStartSubtitle),
        _HabitTemplate(title: t.exploreHabitDeepWorkBlockTitle, subtitle: t.exploreHabitDeepWorkBlockSubtitle),
        _HabitTemplate(title: t.exploreHabitSingleTaskListTitle, subtitle: t.exploreHabitSingleTaskListSubtitle),
        _HabitTemplate(title: t.exploreHabitHydrateTitle, subtitle: t.exploreHabitHydrateSubtitle),
      ],
    ),
    _RoutineTemplate(
      title: t.exploreRoutineMorningMomentumTitle,
      subtitle: t.exploreRoutineTag,
      rating: 4.4,
      imageAsset: 'lib/assets/morning_momentum.jpg',
      description: t.exploreRoutineMorningMomentumDescription,
      habits: <_HabitTemplate>[
        _HabitTemplate(title: t.exploreHabitMakeBedTitle, subtitle: t.exploreHabitMakeBedSubtitle),
        _HabitTemplate(title: t.exploreHabitTop3PrioritiesTitle, subtitle: t.exploreHabitTop3PrioritiesSubtitle),
        _HabitTemplate(title: t.exploreHabitStretchTitle, subtitle: t.exploreHabitStretchSubtitle),
        _HabitTemplate(title: t.exploreHabitProteinBreakfastTitle, subtitle: t.exploreHabitProteinBreakfastSubtitle),
      ],
    ),
  ];

  static List<_RoutineTemplate> becomeBetter(AppLocalizations t) => <_RoutineTemplate>[
    _RoutineTemplate(
      title: t.exploreRoutineCreativityBoostTitle,
      subtitle: t.exploreRoutineTag,
      rating: 4.5,
      imageAsset: 'lib/assets/creativity_boosting.jpg',
      description: t.exploreRoutineCreativityBoostDescription,
      habits: <_HabitTemplate>[
        _HabitTemplate(title: t.exploreHabitIdeaCaptureTitle, subtitle: t.exploreHabitIdeaCaptureSubtitle),
        _HabitTemplate(title: t.exploreHabitCreateBeforeConsumeTitle, subtitle: t.exploreHabitCreateBeforeConsumeSubtitle),
        _HabitTemplate(title: t.exploreHabitInputWalkTitle, subtitle: t.exploreHabitInputWalkSubtitle),
        _HabitTemplate(title: t.exploreHabitDailySketchTitle, subtitle: t.exploreHabitDailySketchSubtitle),
      ],
    ),
    _RoutineTemplate(
      title: t.exploreRoutineProductivityEnhancerTitle,
      subtitle: t.exploreRoutineTag,
      rating: 4.6,
      imageAsset: 'lib/assets/productivity_enhancer.jpeg',
      description: t.exploreRoutineProductivityEnhancerDescription,
      habits: <_HabitTemplate>[
        _HabitTemplate(title: t.exploreHabitPlanTomorrowTitle, subtitle: t.exploreHabitPlanTomorrowSubtitle),
        _HabitTemplate(title: t.exploreHabitInboxZeroTitle, subtitle: t.exploreHabitInboxZeroSubtitle),
        _HabitTemplate(title: t.exploreHabitTwoMinuteRuleTitle, subtitle: t.exploreHabitTwoMinuteRuleSubtitle),
        _HabitTemplate(title: t.exploreHabitShutdownRitualTitle, subtitle: t.exploreHabitShutdownRitualSubtitle),
      ],
    ),
    _RoutineTemplate(
      title: t.exploreRoutineBuildConfidenceTitle,
      subtitle: t.exploreRoutineTag,
      rating: 4.4,
      imageAsset: 'lib/assets/build_confidence.jpg',
      description: t.exploreRoutineBuildConfidenceDescription,
      habits: <_HabitTemplate>[
        _HabitTemplate(title: t.exploreHabitDailyWinTitle, subtitle: t.exploreHabitDailyWinSubtitle),
        _HabitTemplate(title: t.exploreHabitPracticeSkillTitle, subtitle: t.exploreHabitPracticeSkillSubtitle),
        _HabitTemplate(title: t.exploreHabitPostureResetTitle, subtitle: t.exploreHabitPostureResetSubtitle),
        _HabitTemplate(title: t.exploreHabitPositiveReframeTitle, subtitle: t.exploreHabitPositiveReframeSubtitle),
      ],
    ),
    _RoutineTemplate(
      title: t.exploreRoutineBetterSleepTitle,
      subtitle: t.exploreRoutineTag,
      rating: 4.7,
      imageAsset: 'lib/assets/better_sleep.jpeg',
      description: t.exploreRoutineBetterSleepDescription,
      habits: <_HabitTemplate>[
        _HabitTemplate(title: t.exploreHabitNoScreensTitle, subtitle: t.exploreHabitNoScreensSubtitle),
        _HabitTemplate(title: t.exploreHabitCoolRoomTitle, subtitle: t.exploreHabitCoolRoomSubtitle),
        _HabitTemplate(title: t.exploreHabitReadTitle, subtitle: t.exploreHabitReadSubtitle),
        _HabitTemplate(title: t.exploreHabitSameBedtimeTitle, subtitle: t.exploreHabitSameBedtimeSubtitle),
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
