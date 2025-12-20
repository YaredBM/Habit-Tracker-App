import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:intl/intl.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  User? get _user => FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>> _journalRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('journal');
  }

  Stream<List<_JournalEntry>> _entriesStream(String uid) {
    return _journalRef(uid)
        .orderBy('entryDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_JournalEntry.fromDoc).toList());
  }

  Future<void> _openComposer({_JournalEntry? editing}) async {
    final user = _user;
    if (user == null) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Required for custom height
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        // WRAPPER: Makes the sheet 85% of the screen height
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: _JournalComposerSheet(
            initialEntry: editing,
            onSave: (text, date) async {
              final trimmed = text.trim();
              if (trimmed.isEmpty) return;

              final ref = _journalRef(user.uid);

              if (editing == null) {
                await ref.add({
                  'text': trimmed,
                  'entryDate': Timestamp.fromDate(date),
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              } else {
                await ref.doc(editing.id).update({
                  'text': trimmed,
                  'entryDate': Timestamp.fromDate(date),
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }
            },
          ),
        );
      },
    );
  }

  Future<void> _deleteEntry(_JournalEntry entry) async {
    final user = _user;
    if (user == null) return;

    final db = FirebaseFirestore.instance;
    final uid = user.uid;

    final batch = db.batch();

    // Always delete from journal
    batch.delete(_journalRef(uid).doc(entry.id));

    // If it came from a habit, also delete the mirrored habit note
    final hid = entry.habitId;
    if (hid != null && hid.isNotEmpty) {
      final habitNoteRef = db
          .collection('users')
          .doc(uid)
          .collection('habits')
          .doc(hid)
          .collection('notes')
          .doc(entry.id); // SAME ID as journal
      batch.delete(habitNoteRef);
    }

    await batch.commit();

    if (!mounted) return;
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    final user = _user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Please sign in to view your journal.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

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
          'Journal',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _openComposer(),
          ),
        ],
      ),
      body: StreamBuilder<List<_JournalEntry>>(
        stream: _entriesStream(user.uid),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const <_JournalEntry>[];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4C7DFF)),
            );
          }

          if (entries.isEmpty) {
            return _EmptyJournalState(
              onAdd: () => _openComposer(),
            );
          }

          final grouped = _groupByMonth(entries);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
            children: [
              for (final group in grouped)
                _MonthGroup(
                  title: group.monthLabel,
                  entries: group.entries,
                  onTapEntry: (e) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _JournalDetailScreen(
                          entry: e,
                          onDelete: () => _deleteEntry(e),
                          onEdit: () async {
                            Navigator.of(context).pop();
                            await _openComposer(editing: e);
                          },
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
      // FAB REMOVED HERE
    );
  }
}

/* -------------------------------------------------------------------------- */
/* EMPTY STATE                                                                */
/* -------------------------------------------------------------------------- */

class _EmptyJournalState extends StatelessWidget {
  const _EmptyJournalState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final textStyleTitle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    final textStyleSub = GoogleFonts.poppins(
      fontSize: 12,
      color: Colors.grey[500],
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _ZzzIcon(),
            const SizedBox(height: 16),
            Text('No Notes yet', style: textStyleTitle),
            const SizedBox(height: 4),
            Text('Add a note to get started', style: textStyleSub),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C7DFF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                '+ Add',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZzzIcon extends StatelessWidget {
  const _ZzzIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: 5,
            child: Text(
              'z',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4C7DFF),
              ),
            ),
          ),
          Center(
            child: Text(
              'Z',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4C7DFF),
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 5,
            child: Text(
              'z',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4C7DFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* MONTH GROUP LIST                                                           */
/* -------------------------------------------------------------------------- */

class _MonthGroup extends StatelessWidget {
  const _MonthGroup({
    required this.title,
    required this.entries,
    required this.onTapEntry,
  });

  final String title;
  final List<_JournalEntry> entries;
  final ValueChanged<_JournalEntry> onTapEntry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
        ),
        for (final e in entries) ...[
          _JournalListTile(entry: e, onTap: () => onTapEntry(e)),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _JournalListTile extends StatelessWidget {
  const _JournalListTile({
    required this.entry,
    required this.onTap,
  });

  final _JournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dayBadge = _DayBadge(date: entry.entryDate);
    final timeText = _formatTime(entry.entryDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dayBadge,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    entry.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // time chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          timeText,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // habit tag chip (optional)
                      if (entry.habitTitle != null && entry.habitTitle!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E6FD0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.habitTitle!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
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

class _DayBadge extends StatelessWidget {
  const _DayBadge({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdayShort(date.weekday).toUpperCase();
    final day = date.day.toString();

    return Container(
      width: 50,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weekday,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          Text(
            day,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* COMPOSER SHEET                                                             */
/* -------------------------------------------------------------------------- */

class _JournalComposerSheet extends StatefulWidget {
  const _JournalComposerSheet({
    required this.onSave,
    this.initialEntry,
  });

  final _JournalEntry? initialEntry;
  final Future<void> Function(String text, DateTime date) onSave;

  @override
  State<_JournalComposerSheet> createState() => _JournalComposerSheetState();
}

class _JournalComposerSheetState extends State<_JournalComposerSheet> {
  late final TextEditingController _controller;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialEntry?.text ?? '',
    );
    _selectedDate = widget.initialEntry?.entryDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isToday {
    final now = DateTime.now();
    return now.year == _selectedDate.year &&
        now.month == _selectedDate.month &&
        now.day == _selectedDate.day;
  }

  String get _dateChipLabel {
    if (_isToday) return 'Today';
    return _formatChipDateTime(_selectedDate);
  }

  Future<void> _pickDateTime() async {
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DateTimePickerSheet(initial: _selectedDate),
    );

    if (result != null) {
      setState(() => _selectedDate = result);
    }
  }

  Future<void> _handleSave() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    await widget.onSave(text, _selectedDate);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // We only worry about bottom insets (keyboard), the height is handled by the parent
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: math.max(20, viewInsets + 20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max, // Fill the 85% height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close button
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),

          // Input area - EXPANDED to fill the space
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLines: null, // Allows infinite lines
              expands: true, // Forces text field to fill the Expanded parent
              textAlignVertical: TextAlignVertical.top,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'What happened today?',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bottom row: date chip + save button
          // Bottom row: date chip + save button
          Row(
            children: [
              // tappable date chip ("Today" or selected date)
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _dateChipLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF4C7DFF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4C7DFF).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.check, color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* DATE/TIME PICKER SHEET                                                     */
/* -------------------------------------------------------------------------- */

class _DateTimePickerSheet extends StatefulWidget {
  const _DateTimePickerSheet({required this.initial});

  final DateTime initial;

  @override
  State<_DateTimePickerSheet> createState() => _DateTimePickerSheetState();
}

class _DateTimePickerSheetState extends State<_DateTimePickerSheet> {
  late DateTime _temp;

  @override
  void initState() {
    super.initState();
    _temp = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 300,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: Colors.grey[500]),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(_temp),
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF4C7DFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  brightness: Brightness.dark,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: widget.initial,
                  maximumDate: DateTime(2100),
                  minimumDate: DateTime(2000),
                  onDateTimeChanged: (d) => _temp = d,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* DETAIL SCREEN                                                              */
/* -------------------------------------------------------------------------- */

class _JournalDetailScreen extends StatelessWidget {
  const _JournalDetailScreen({
    required this.entry,
    required this.onDelete,
    required this.onEdit,
  });

  final _JournalEntry entry;
  final Future<void> Function() onDelete;
  final Future<void> Function() onEdit;

  @override
  Widget build(BuildContext context) {
    final date = entry.entryDate;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1C1C1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Delete note?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  content: Text(
                    'This action cannot be undone.',
                    style: GoogleFonts.poppins(color: Colors.grey[400]),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ) ?? false;

              if (ok) await onDelete();
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: onEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDetailDate(date),
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatTime(date),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  entry.text,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* MODEL + GROUPING                                                           */
/* -------------------------------------------------------------------------- */

class _JournalEntry {
  _JournalEntry({
    required this.id,
    required this.text,
    required this.entryDate,
    this.habitId,
    this.habitTitle,
  });

  final String id;
  final String text;
  final DateTime entryDate;
  final String? habitId;
  final String? habitTitle;

  factory _JournalEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = (data['entryDate'] as Timestamp?) ?? Timestamp.now();

    return _JournalEntry(
      id: doc.id,
      text: (data['text'] as String?) ?? '',
      entryDate: ts.toDate(),
      habitId: data['habitId'] as String?,
      habitTitle: data['habitTitle'] as String?,
    );
  }
}



class _MonthGroupData {
  final String monthLabel;
  final List<_JournalEntry> entries;

  _MonthGroupData(this.monthLabel, this.entries);
}

List<_MonthGroupData> _groupByMonth(List<_JournalEntry> entries) {
  final map = <String, List<_JournalEntry>>{};

  for (final e in entries) {
    final key = '${e.entryDate.year}-${e.entryDate.month.toString().padLeft(2, '0')}';
    map.putIfAbsent(key, () => []).add(e);
  }

  final keys = map.keys.toList()
    ..sort((a, b) => b.compareTo(a));

  return keys.map((k) {
    final parts = k.split('-');
    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 1;
    final label = _monthName(month);
    final display = year > 0 ? '$label $year' : label;

    final list = map[k]!..sort((a, b) => b.entryDate.compareTo(a.entryDate));
    return _MonthGroupData(display, list);
  }).toList();
}

/* -------------------------------------------------------------------------- */
/* FORMATTERS                                                                 */
/* -------------------------------------------------------------------------- */

String _weekdayShort(int weekday) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[(weekday - 1).clamp(0, 6)];
}

String _monthName(int month) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return months[(month - 1).clamp(0, 11)];
}

String _monthShort(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[(month - 1).clamp(0, 11)];
}

String _formatTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _formatChipDateTime(DateTime d) {
  final day = d.day.toString();
  final month = _monthShort(d.month);
  return '$day $month';
}

String _formatDetailDate(DateTime d) {
  return '${d.day} ${_monthShort(d.month)}';
}