import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecohabit/features/journal/presentation/journal_screen.dart';
import 'package:ecohabit/features/settings/presentation/hub_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/features/analytics/presentation/analytics_screen.dart';
import 'create_habit_screen.dart';
import 'habit_detail_screen.dart';
import '/features/auth/presentation/sign_in_screen.dart';
import 'package:ecohabit/features/explore/presentation/explore_screen.dart';


enum HabitsTab { today, weekly, overall }

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF000000);

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          Future<void> openCreate() async {
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);
            final result = await navigator.push(
              MaterialPageRoute(
                builder: (_) => const CreateHabitScreen(),
              ),
            );

            if (!context.mounted) return;
            if (result is String) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Habit completed correctly'),
                ),
              );
              tabController.animateTo(HabitsTab.today.index);
            }
          }

          return Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.grid_view_rounded),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => HubScreen(),
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add),
                          color: Colors.white,
                          onPressed: openCreate,
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu_book_outlined),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => JournalScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Habits',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Custom tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _HabitsTabs(controller: tabController),
                  ),
                  const SizedBox(height: 12),

                  // Tab contents
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        _HabitsList(
                          tab: HabitsTab.today,
                          onCreate: openCreate,
                        ),
                        _HabitsList(
                          tab: HabitsTab.weekly,
                          onCreate: openCreate,
                        ),
                        _HabitsList(
                          tab: HabitsTab.overall,
                          onCreate: openCreate,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom navigation bar (a bit shorter & nicely aligned)
            bottomNavigationBar: Container(
              color: const Color(0xFF2A2A32),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 58,
                  child: BottomNavigationBar(
                    backgroundColor: const Color(0xFF2A2A32),
                    elevation: 0,
                    currentIndex: 0, // HabitsScreen is "Home"
                    type: BottomNavigationBarType.fixed,
                    iconSize: 24,
                    selectedFontSize: 0,
                    unselectedFontSize: 0,
                    selectedItemColor: Colors.white,
                    unselectedItemColor: Colors.white70,
                    onTap: (index) {
                      switch (index) {
                        case 0:
                        // already here (Home)
                          return;

                        case 1:
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => AnalyticsScreen()),
                          );
                          return;

                        case 2:
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ExploreScreen()),
                          );
                          return;
                      }
                    },
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.bar_chart_outlined),
                        label: 'Analytics',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.explore_outlined),
                        label: 'Explore',
                      ),
                    ],
                  ),
                ),
              ),
            ),

          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Optional: splash/loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const SignInScreen();
        }

        // User is signed in
        return const HabitsScreen();
      },
    );
  }
}

class _HabitsTabs extends StatelessWidget {
  final TabController controller;

  const _HabitsTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final index = controller.index;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TabPill(
              label: 'Today',
              isSelected: index == 0,
              onTap: () => controller.animateTo(0),
            ),
            const SizedBox(width: 12),
            _TabPill(
              label: 'Weekly',
              isSelected: index == 1,
              onTap: () => controller.animateTo(1),
            ),
            const SizedBox(width: 12),
            _TabPill(
              label: 'Overall',
              isSelected: index == 2,
              onTap: () => controller.animateTo(2),
            ),
          ],
        );
      },
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const pillBg = Color(0xFF202020);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? pillBg : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _HabitsList extends StatefulWidget {
  final HabitsTab tab;
  final VoidCallback onCreate;

  const _HabitsList({
    required this.tab,
    required this.onCreate,
  });

  @override
  State<_HabitsList> createState() => _HabitsListState();
}

class _HabitsListState extends State<_HabitsList> {
  bool _showCompletedToday = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final tabController = DefaultTabController.of(context);
    if (user == null) {
      return _EmptyHabitsState(
        title: 'Not signed in',
        subtitle: 'Please sign in to create habits.',
        onCreate: null,
      );
    }

    final habitsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .orderBy('createdAt', descending: false)
        .snapshots();

    String todayKey() => _dateKey(DateTime.now());

    Future<void> showCompletionCelebration() async {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogCtx) {
          return Dialog(
            backgroundColor: const Color(0xFF000000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/assets/good_job.png',
                    width: 140,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Good Job!',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'All set and done.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5CE1E6),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Great!',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    }

    Future<void> updateProgressCount({
      required String habitId,
      required Map<String, dynamic> data,
      required int previousCount,
      required int newCount,
    }) async {
      final today = todayKey();
      final goalValue = (data['goalValue'] as int?) ?? 1;
      final wasCompleted = previousCount >= goalValue;
      final nowCompleted = newCount >= goalValue;

      final messenger = ScaffoldMessenger.of(context);

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('habits')
            .doc(habitId)
            .update({
          'progressByDate.$today': newCount,
          'completedDates': nowCompleted
              ? FieldValue.arrayUnion([today])
              : FieldValue.arrayRemove([today]),
          'createdAt': FieldValue.serverTimestamp(),

        });

        if (!mounted) return;
        if (nowCompleted && !wasCompleted) {
          await showCompletionCelebration();
        } else {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Progress updated'),
              duration: Duration(milliseconds: 800),
            ),
          );
        }
      } catch (_) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Could not update progress. Try again.'),
          ),
        );
      }
    }

    void openCompletionSheet({
      required String habitId,
      required Map<String, dynamic> data,
      required int todayCount,
      required int goalValue,
      required String goalUnit,
    }) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF111115),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (ctx) {
          int localCount = todayCount;

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 14,
              bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                final reachedGoal = localCount >= goalValue;
                final plural = goalValue == 1 ? '' : 's';

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      data['title'] as String? ?? 'Habit',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$localCount / $goalValue $goalUnit$plural per day',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StepperButton(
                          icon: Icons.remove,
                          onTap: () {
                            setSheetState(() {
                              localCount = (localCount - 1).clamp(0, 999);
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: reachedGoal
                                  ? const Color(0xFF00B894)
                                  : Colors.white24,
                              width: 3,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$localCount',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _StepperButton(
                          icon: Icons.add,
                          onTap: () {
                            setSheetState(() {
                              localCount = (localCount + 1).clamp(0, 999);
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          updateProgressCount(
                            habitId: habitId,
                            data: data,
                            previousCount: todayCount,
                            newCount: localCount,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: reachedGoal
                              ? const Color(0xFF00B894)
                              : Colors.white,
                          foregroundColor:
                          reachedGoal ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          reachedGoal ? 'Mark completed' : 'Save progress',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + or - to register the times or units you set.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: habitsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF5CE1E6),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _EmptyHabitsState(
            onCreate: widget.onCreate,
          );
        }

        final docs = snapshot.data!.docs;

        if (widget.tab == HabitsTab.today) {
          if (docs.isEmpty) {
            return _EmptyHabitsState(
              onCreate: widget.onCreate,
            );
          }

          final List<_TodayHabitEntry> todayHabits = [];
          int completedCount = 0;

          for (final doc in docs) {
            final data = doc.data();
            final id = doc.id;

            final title = data['title'] as String? ?? '';
            final description = data['description'] as String?;
            final colorValue = data['color'] as int? ?? 0xFF5CE1E6;
            final completedDates =
            (data['completedDates'] as List<dynamic>? ?? [])
                .cast<String>();
            final goalEnabled = (data['goalEnabled'] as bool?) ?? false;

            final progressByDate =
            (data['progressByDate'] as Map<String, dynamic>? ?? {});
            final todayCount = (progressByDate[todayKey()] as int?) ??
                (completedDates.contains(todayKey()) ? 1 : 0);

            final goalValue = goalEnabled
                ? (data['goalValue'] as int?) ?? 1
                : 1;
            final goalUnit = (data['goalUnit'] as String?) ?? 'time';

            final color = Color(colorValue);
            final todayCompleted = todayCount >= goalValue;

            if (todayCompleted) {
              completedCount++;
              if (!_showCompletedToday) {
                continue;
              }
            }

            todayHabits.add(
              _TodayHabitEntry(
                id: id,
                data: data,
                title: title,
                description: description,
                color: color,
                completedToday: todayCompleted,
                goalEnabled: goalEnabled,
                goalValue: goalValue,
                goalUnit: goalUnit,
                todayCount: todayCount,
              ),
            );
          }

          final totalHabits = docs.length;

          Widget listContent;
          if (todayHabits.isEmpty) {
            listContent = completedCount == totalHabits
                ? const _AllHabitsCompleted()
                : _EmptyHabitsState(onCreate: widget.onCreate);
          } else {
            listContent = ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: todayHabits.length,
              separatorBuilder: (context, index) =>
              const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = todayHabits[index];

                final card = _TodayHabitCard(
                  title: item.title,
                  description: item.description,
                  color: item.color,
                  completedToday: item.completedToday,
                  goalValue: item.goalValue,
                  goalUnit: item.goalUnit,
                  currentCount: item.todayCount,
                  goalEnabled: item.goalEnabled,
                );

                final tappableCard = GestureDetector(
                  onTap: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    final result = await navigator.push(
                      MaterialPageRoute(
                        builder: (_) => HabitDetailScreen(
                          habitId: item.id,
                          initialData: item.data,
                          onEdit: () async {
                            final result = await navigator.push(
                              MaterialPageRoute(
                                builder: (_) => CreateHabitScreen(
                                  habitId: item.id,
                                  initialData: item.data,
                                ),
                              ),
                            );

                            if (!mounted) return;
                            if (result is String) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Habit completed correctly'),
                                ),
                              );
                              navigator.pop();
                            }
                          },
                          onDelete: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('habits')
                                .doc(item.id)
                                .delete();
                          },
                          onUpdateProgress: item.goalEnabled
                              ? () async => openCompletionSheet(
                            habitId: item.id,
                            data: item.data,
                            todayCount: item.todayCount,
                            goalValue: item.goalValue,
                            goalUnit: item.goalUnit,
                          )
                              : null,
                        ),
                      ),
                    );

                    if (!mounted) return;

                    if (result is String) {
                      if (result == 'deleted') {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Habit deleted'),
                          ),
                        );
                        tabController.animateTo(HabitsTab.today.index);
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Habit completed correctly'),
                          ),
                        );
                        tabController.animateTo(HabitsTab.today.index);
                      }
                    }
                  },
                  child: card,
                );

                if (item.completedToday) {
                  return tappableCard;
                }

                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.startToEnd,
                  confirmDismiss: (_) async {
                    await updateProgressCount(
                      habitId: item.id,
                      data: item.data,
                      previousCount: item.todayCount,
                      newCount: item.goalValue,
                    );
                    return true;
                  },
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 24),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  child: tappableCard,
                );
              },
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _TodayProgressSummary(
                  completedCount: completedCount,
                  totalHabits: totalHabits,
                  showCompleted: _showCompletedToday,
                  onToggleFilter: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFF15151A),
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (ctx) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              CheckboxListTile(
                                value: _showCompletedToday,
                                onChanged: (val) {
                                  setState(
                                          () => _showCompletedToday = val ?? false);
                                  Navigator.of(ctx).pop();
                                },
                                activeColor: const Color(0xFF5CE1E6),
                                checkColor: Colors.black,
                                title: Text(
                                  'Show Completed',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                controlAffinity:
                                ListTileControlAffinity.leading,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: listContent),
            ],
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final id = doc.id;

            final title = data['title'] as String? ?? '';
            final description = data['description'] as String?;
            final colorValue = data['color'] as int? ?? 0xFF5CE1E6;
            final repeatType = data['repeatType'] as String? ?? 'daily';
            final completedDates =
            (data['completedDates'] as List<dynamic>? ?? [])
                .cast<String>();

            final progressByDate =
            (data['progressByDate'] as Map<String, dynamic>? ?? {});
            final todayCount = (progressByDate[todayKey()] as int?) ??
                (completedDates.contains(todayKey()) ? 1 : 0);
            final goalValue = (data['goalValue'] as int?) ?? 1;
            final goalUnit = (data['goalUnit'] as String?) ?? 'time';
            final goalEnabled = (data['goalEnabled'] as bool?) ?? false;

            final color = Color(colorValue);
            final todayCompleted = todayCount >= goalValue;

            Widget card;
            switch (widget.tab) {
              case HabitsTab.today:
                card = _TodayHabitCard(
                  title: title,
                  description: description,
                  color: color,
                  completedToday: todayCompleted,
                  goalValue: goalValue,
                  goalUnit: goalUnit,
                  currentCount: todayCount,
                  goalEnabled: (data['goalEnabled'] as bool?) ?? false,
                );
                break;
              case HabitsTab.weekly:
                card = _WeeklyHabitCard(
                  title: title,
                  color: color,
                  completedDates: completedDates,
                );
                break;
              case HabitsTab.overall:
                card = _OverallHabitCard(
                  title: title,
                  color: color,
                  repeatType: repeatType,
                  completedDatesCount: completedDates.length,
                );
                break;
            }

            return GestureDetector(
              onTap: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final tabController = DefaultTabController.of(context);

                final result = await navigator.push(
                  MaterialPageRoute(
                    builder: (_) => HabitDetailScreen(
                      habitId: id,
                      initialData: data,
                      onEdit: () async {
                        final result = await navigator.push(
                          MaterialPageRoute(
                            builder: (_) => CreateHabitScreen(
                              habitId: id,
                              initialData: data,
                            ),
                          ),
                        );

                        if (!mounted) return;
                        if (result is String) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Habit completed correctly'),
                            ),
                          );
                          tabController.animateTo(HabitsTab.today.index);
                          navigator.pop();
                        }
                      },
                      onDelete: () async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('habits')
                            .doc(id)
                            .delete();
                      },
                      onUpdateProgress: goalEnabled
                          ? () async => openCompletionSheet(
                        habitId: id,
                        data: data,
                        todayCount: todayCount,
                        goalValue: goalValue,
                        goalUnit: goalUnit,
                      )
                          : null,
                    ),
                  ),
                );

                if (!mounted) return;
                if (result is String && result == 'deleted') {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Habit deleted'),
                    ),
                  );
                  tabController.animateTo(HabitsTab.today.index);
                }
              },
              child: card,
            );
          },
        );
      },
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _TodayHabitEntry {
  const _TodayHabitEntry({
    required this.id,
    required this.data,
    required this.title,
    required this.description,
    required this.color,
    required this.completedToday,
    required this.goalEnabled,
    required this.goalValue,
    required this.goalUnit,
    required this.todayCount,
  });

  final String id;
  final Map<String, dynamic> data;
  final String title;
  final String? description;
  final Color color;
  final bool completedToday;
  final bool goalEnabled;
  final int goalValue;
  final String goalUnit;
  final int todayCount;
}

class _TodayProgressSummary extends StatelessWidget {
  final int completedCount;
  final int totalHabits;
  final bool showCompleted;
  final VoidCallback onToggleFilter;

  const _TodayProgressSummary({
    required this.completedCount,
    required this.totalHabits,
    required this.showCompleted,
    required this.onToggleFilter,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalHabits == 0
        ? 0.0
        : (completedCount / totalHabits).clamp(0.0, 1.0);
    final barColor = completedCount == totalHabits && totalHabits > 0
        ? const Color(0xFF00B894)
        : const Color(0xFFE57373);
    final barWidth = MediaQuery.of(context).size.width / 3;

    return Row(
      children: [
        SizedBox(
          width: barWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$completedCount completed',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                showCompleted
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                showCompleted ? 'Completed shown' : 'Completed hidden',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onToggleFilter,
          icon: const Icon(Icons.more_horiz, color: Colors.white),
        ),
      ],
    );
  }
}

class _AllHabitsCompleted extends StatelessWidget {
  const _AllHabitsCompleted();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'lib/assets/good_job.png',
            width: 160,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'Good Job!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'All set and done.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHabitsState extends StatelessWidget {
  final VoidCallback? onCreate;
  final String? title;
  final String? subtitle;

  const _EmptyHabitsState({
    this.onCreate,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF5CE1E6);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'lib/assets/zzz_icon.png',
            width: 64,
            height: 64,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            title ?? 'No habits for today',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle ?? 'There is no habit for today. Create one?',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (onCreate != null)
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: onCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  '+ Create',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// TODAY TAB – pill-style card

class _TodayHabitCard extends StatelessWidget {
  final String title;
  final String? description;
  final Color color;
  final bool completedToday;
  final int goalValue;
  final String goalUnit;
  final int currentCount;
  final bool goalEnabled;

  const _TodayHabitCard({
    required this.title,
    required this.description,
    required this.color,
    required this.completedToday,
    required this.goalValue,
    required this.goalUnit,
    required this.currentCount,
    required this.goalEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final bg = goalEnabled
        ? const Color(0xFF15151A)
        : color.withValues(alpha: 0.28);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: completedToday ? color : Colors.grey[700],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  completedToday ? Icons.check : Icons.notifications_none,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (goalEnabled)
            Text(
              '$currentCount / $goalValue $goalUnit${goalValue == 1 ? '' : 's'} per day',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[300],
                fontWeight: FontWeight.w500,
              ),
            ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// WEEKLY TAB – 7-day chips that highlight completed days

class _WeeklyHabitCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> completedDates;

  const _WeeklyHabitCard({
    required this.title,
    required this.color,
    required this.completedDates,
  });

  @override
  Widget build(BuildContext context) {
    final chipBg = Colors.white.withValues(alpha: 0.06);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1)); // Monday
    final weekEnd = weekStart.add(const Duration(days: 7));

    final Set<int> completedDaysOfWeek = {};

    for (final s in completedDates) {
      try {
        final d = DateTime.parse(s);
        if (!d.isBefore(weekStart) && d.isBefore(weekEnd) && !d.isAfter(today)) {
          completedDaysOfWeek.add(d.weekday);
        }
      } catch (_) {
        // ignore parse errors
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(7, (index) {
                const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final dayIndex = index + 1;
                final date = weekStart.add(Duration(days: index));
                final locked = date.isAfter(today);
                final done = !locked && completedDaysOfWeek.contains(dayIndex);

                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: done
                        ? color
                        : locked
                        ? Colors.white.withValues(alpha: 0.03)
                        : chipBg,
                    borderRadius: BorderRadius.circular(999),
                    border: locked
                        ? Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    )
                        : null,
                  ),
                  child: Text(
                    labels[index],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: done
                          ? Colors.black
                          : locked
                          ? Colors.grey[600]
                          : Colors.white,
                    ),
                  ),
                );
              }),
              const Spacer(),
              Text(
                '${completedDaysOfWeek.length} completed',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// OVERALL TAB – big grid of dots like the reference

class _OverallHabitCard extends StatelessWidget {
  final String title;
  final Color color;
  final String repeatType;
  final int completedDatesCount;

  const _OverallHabitCard({
    required this.title,
    required this.color,
    required this.repeatType,
    required this.completedDatesCount,
  });

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF15151A);
    const totalDots = 120;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 3,
            runSpacing: 3,
            children: List.generate(
              totalDots,
                  (index) {
                final filled = index < completedDatesCount;
                return Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: filled
                        ? color.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            repeatType == 'daily'
                ? 'Everyday'
                : repeatType == 'weekly'
                ? 'Weekly habit'
                : 'Monthly habit',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';