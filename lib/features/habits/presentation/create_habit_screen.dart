import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'
as color_picker;
import 'package:google_fonts/google_fonts.dart';
import '/l10n/app_localizations.dart';

import '../../../notifications/notification_service.dart';

enum HabitRepeatType { daily, weekly, monthly }

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({
    super.key,
    this.habitId,
    this.initialData,
  });

  final String? habitId; // null => create, non-null => edit
  final Map<String, dynamic>? initialData;

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Color _selectedColor = const Color(0xFF5CE1E6);

  HabitRepeatType _repeatType = HabitRepeatType.daily;
  bool _repeatEnabled = true;

  // Daily: 1 = Mon ... 7 = Sun
  final Set<int> _selectedWeekdays = {1, 2, 3, 4, 5, 6, 7};

  // Weekly: times per week (1–7)
  int _weeklyFrequency = 7;

  // Monthly: day of month (1–31)
  int _monthlyDay = DateTime.now().day.clamp(1, 31);

  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _goalEnabled = false;
  int _goalValue = 1;
  String _goalUnit = 'time';
  final List<String> _goalUnits = const [
    'time',
    'minute',
    'hour',
    'kg',
    'km',
    'l',
    'oz',
  ];

  bool _isSaving = false;
  String? _error;
  String? _titleError;

  bool get _isEdit => widget.habitId != null;

  @override
  void initState() {
    super.initState();

    final data = widget.initialData;
    if (data == null) return;

    _titleController.text = (data['title'] as String?) ?? '';
    _descriptionController.text = (data['description'] as String?) ?? '';
    _goalValue = (data['goalValue'] as int?) ?? 1;
    _goalUnit = (data['goalUnit'] as String?) ?? _goalUnit;

    // Fallback for legacy goal text like "1 time per day"
    final legacyGoal = data['goalText'] as String?;
    if (legacyGoal != null && legacyGoal.isNotEmpty) {
      final parsed = RegExp(r'^(\d+)\s+(\w+)').firstMatch(legacyGoal);
      if (parsed != null) {
        _goalValue = int.tryParse(parsed.group(1) ?? '') ?? _goalValue;
        _goalUnit = parsed.group(2) ?? _goalUnit;
      }
    }

    final colorVal = data['color'] as int?;
    if (colorVal != null) {
      _selectedColor = Color(colorVal);
    }

    _repeatEnabled = (data['repeatEnabled'] as bool?) ?? true;

    final repeatTypeStr = (data['repeatType'] as String?) ?? 'daily';
    switch (repeatTypeStr) {
      case 'weekly':
        _repeatType = HabitRepeatType.weekly;
        break;
      case 'monthly':
        _repeatType = HabitRepeatType.monthly;
        break;
      default:
        _repeatType = HabitRepeatType.daily;
        break;
    }

    final repeatData =
        (data['repeatData'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    if (_repeatType == HabitRepeatType.daily) {
      final days = (repeatData['daysOfWeek'] as List<dynamic>? ?? [])
          .cast<int>()
          .toSet();
      if (days.isNotEmpty) {
        _selectedWeekdays
          ..clear()
          ..addAll(days);
      }
    } else if (_repeatType == HabitRepeatType.weekly) {
      _weeklyFrequency =
          (repeatData['timesPerWeek'] as int?)?.clamp(1, 7) ?? 7;
    } else if (_repeatType == HabitRepeatType.monthly) {
      _monthlyDay =
          (repeatData['dayOfMonth'] as int?)?.clamp(1, 31) ?? _monthlyDay;
    }

    _reminderEnabled = (data['reminderEnabled'] as bool?) ?? false;
    final reminderTimeMap = data['reminderTime'] as Map<String, dynamic>?;
    if (reminderTimeMap != null) {
      final hour = (reminderTimeMap['hour'] as int?) ?? _reminderTime.hour;
      final minute = (reminderTimeMap['minute'] as int?) ?? _reminderTime.minute;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    }
    _goalEnabled = (data['goalEnabled'] as bool?) ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  int _colorToInt(Color color) => color.toARGB32();

  String _goalUnitLabel(AppLocalizations t, String unit) {
    switch (unit) {
      case 'time':
        return t.createHabitUnitTime;
      case 'minute':
        return t.createHabitUnitMinute;
      case 'hour':
        return t.createHabitUnitHour;
      case 'kg':
        return t.createHabitUnitKg;
      case 'km':
        return t.createHabitUnitKm;
      case 'l':
        return t.createHabitUnitL;
      case 'oz':
        return t.createHabitUnitOz;
      default:
        return unit;
    }
  }

  Future<void> _openColorPicker() async {
    final t = AppLocalizations.of(context)!;

    const presetColors = <Color>[
      Color(0xFF5CE1E6),
      Color(0xFF6C5CE7),
      Color(0xFFFF7675),
      Color(0xFF00B894),
      Color(0xFFFFA726),
      Color(0xFF42A5F5),
      Color(0xFFD1C4E9),
      Color(0xFFEF9A9A),
      Color(0xFFFDD835),
      Color(0xFF26A69A),
      Color(0xFF8D6E63),
      Color(0xFFEC407A),
      Color(0xFF9CCC65),
      Color(0xFF78909C),
      Color(0xFFB39DDB),
      Color(0xFFFFB74D),
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        Color localColor = _selectedColor;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> openAdvancedPicker() async {
              final picked = await showDialog<Color>(
                context: ctx,
                builder: (dialogCtx) {
                  Color dialogColor = localColor;
                  return AlertDialog(
                    backgroundColor: const Color(0xFF1A1A1F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      t.createHabitColorPicker,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    content: StatefulBuilder(
                      builder: (context, setDialogState) {
                        return SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              color_picker.ColorPicker(
                                pickerColor: dialogColor,
                                onColorChanged: (c) {
                                  setDialogState(() => dialogColor = c);
                                },
                                pickerAreaHeightPercent: 0.8,
                                enableAlpha: false,
                                labelTypes: const [],
                                displayThumbColor: true,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        child: Text(t.createHabitCancel),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(dialogCtx).pop(dialogColor),
                        child: Text(t.createHabitDone),
                      ),
                    ],
                  );
                },
              );

              if (picked != null) {
                setSheetState(() => localColor = picked);
              }
            }

            return Padding(
              padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SizedBox(
                height: 330,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        t.createHabitPickColorTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // "Color picker" button (advanced)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: openAdvancedPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF6F61),
                                Color(0xFF5CE1E6),
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.color_lens_outlined,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t.createHabitColorPicker,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Preset colors grid (rounded squares)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemCount: presetColors.length,
                          itemBuilder: (context, index) {
                            final c = presetColors[index];
                            final selected =
                                _colorToInt(c) == _colorToInt(localColor);

                            return GestureDetector(
                              onTap: () =>
                                  setSheetState(() => localColor = c),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: c,
                                  borderRadius: BorderRadius.circular(10),
                                  border: selected
                                      ? Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  )
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _selectedColor = localColor);
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(
                            t.createHabitContinue,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveHabit() async {
    final t = AppLocalizations.of(context)!;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    setState(() {
      _titleError = title.isEmpty ? t.createHabitTitleRequired : null;
      _error = null;
    });

    if (_titleError != null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = t.createHabitMustBeSignedIn;
      });
      return;
    }

    setState(() => _isSaving = true);

    try {
      String repeatType;
      Map<String, dynamic> repeatData = {};

      switch (_repeatType) {
        case HabitRepeatType.daily:
          repeatType = 'daily';
          repeatData = {
            'daysOfWeek': _selectedWeekdays.toList()..sort(),
          };
          break;
        case HabitRepeatType.weekly:
          repeatType = 'weekly';
          repeatData = {
            'timesPerWeek': _weeklyFrequency,
          };
          break;
        case HabitRepeatType.monthly:
          repeatType = 'monthly';
          repeatData = {
            'dayOfMonth': _monthlyDay,
          };
          break;
      }

      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits');

      final payload = <String, dynamic>{
        'title': title,
        'description': description.isEmpty ? null : description,
        'color': _colorToInt(_selectedColor),
        'repeatEnabled': _repeatEnabled,
        'repeatType': repeatType,
        'repeatData': repeatData,
        'reminderEnabled': _reminderEnabled,
        'reminderTime': _reminderEnabled
            ? {'hour': _reminderTime.hour, 'minute': _reminderTime.minute}
            : null,
        'goalEnabled': _goalEnabled,
        'goalValue': _goalEnabled ? _goalValue : null,
        'goalUnit': _goalEnabled ? _goalUnit : null,
        'goalText': _goalEnabled ? t.createHabitGoalText(_goalValue, _goalUnit) : null,
      };

      final existingProgress =
          (widget.initialData?['progressByDate'] as Map<String, dynamic>?) ??
              <String, dynamic>{};

      late final String habitId;

      if (_isEdit) {
        final existingCompleted =
            widget.initialData?['completedDates'] as List<dynamic>? ?? [];
        payload['completedDates'] = existingCompleted;
        payload['progressByDate'] = existingProgress;

        habitId = widget.habitId!;
        await collection.doc(habitId).update(payload);
      } else {
        final now = DateTime.now();

        payload['createdAt'] = FieldValue.serverTimestamp();

        // If you want the calendar to start at the CURRENT month:
        payload['historyStartMonth'] =
            Timestamp.fromDate(DateTime(now.year, now.month, 1));

        payload['completedDates'] = <String>[];
        payload['progressByDate'] = <String, dynamic>{};

        final newDoc = await collection.add(payload);
        habitId = newDoc.id;
      }

      // notifications
      if (_reminderEnabled) {
        await NotificationService.requestPermission();
        await NotificationService.scheduleHabitReminder(
          habitId: habitId,
          time: _reminderTime,
          habitTitle: title,
        );
      } else {
        await NotificationService.cancelHabitReminder(habitId);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true); // back to HabitsScreen
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = t.createHabitFailedToSave;
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF5CE1E6),
              surface: Color(0xFF15151A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  String _formatTimeOfDay(TimeOfDay time, AppLocalizations t) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? t.createHabitAm : t.createHabitPm;
    return '$hour:$minute $period';
  }

  String _goalLabel(AppLocalizations t) {
    final plural = _goalValue == 1 ? '' : 's';
    final unitLabel = _goalUnitLabel(t, _goalUnit);
    return t.createHabitGoalLabelText(_goalValue, unitLabel, plural);
  }

  Future<void> _openGoalPicker() async {
    final t = AppLocalizations.of(context)!;

    int tempValue = _goalValue;
    String tempUnit = _goalUnit;
    final valueOptions = List<int>.generate(50, (index) => index + 1);

    final valueController =
    FixedExtentScrollController(initialItem: tempValue - 1);
    final unitController = FixedExtentScrollController(
      initialItem: _goalUnits.indexOf(tempUnit).clamp(0, _goalUnits.length - 1),
    );

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15151A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t.createHabitGoalLabel,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      child: ListWheelScrollView.useDelegate(
                        controller: valueController,
                        itemExtent: 36,
                        perspective: 0.005,
                        onSelectedItemChanged: (index) {
                          tempValue = valueOptions[index];
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: valueOptions.length,
                          builder: (_, index) {
                            final value = valueOptions[index];
                            return Center(
                              child: Text(
                                '$value',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: ListWheelScrollView.useDelegate(
                        controller: unitController,
                        itemExtent: 36,
                        perspective: 0.005,
                        onSelectedItemChanged: (index) {
                          tempUnit = _goalUnits[index];
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: _goalUnits.length,
                          builder: (_, index) {
                            final unit = _goalUnits[index];
                            return Center(
                              child: Text(
                                _goalUnitLabel(t, unit),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Text(
                      t.createHabitPerDay,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _goalValue = tempValue;
                        _goalUnit = tempUnit;
                      });
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5CE1E6),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      t.createHabitSetGoal,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    const bgColor = Color(0xFF000000);
    const cardColor = Color(0xFF15151A);
    const fieldColor = Color(0xFF1E1C22);
    final borderColor = Colors.white12;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isEdit ? t.createHabitEditTitle : t.createHabitCreateTitle,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                Text(
                  _error!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Title
              _LabeledField(
                label: t.createHabitTitleLabel,
                child: _TextFieldBox(
                  controller: _titleController,
                  hintText: t.createHabitTitleHint,
                  fieldColor: fieldColor,
                  borderColor: borderColor,
                ),
              ),
              if (_titleError != null) ...[
                const SizedBox(height: 4),
                Text(
                  _titleError!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.redAccent,
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // Description
              _LabeledField(
                label: t.createHabitDescriptionLabel,
                child: _TextFieldBox(
                  controller: _descriptionController,
                  hintText: t.createHabitDescriptionHint,
                  maxLines: 3,
                  fieldColor: fieldColor,
                  borderColor: borderColor,
                ),
              ),
              const SizedBox(height: 14),

              // Color
              _LabeledField(
                label: t.createHabitColorLabel,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _openColorPicker,
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Text(
                          t.createHabitColorLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[300],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Repeat card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          t.createHabitRepeatLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _repeatEnabled,
                          onChanged: (v) {
                            setState(() {
                              _repeatEnabled = v;
                            });
                          },
                          thumbColor: WidgetStateProperty.resolveWith<Color?>(
                                (states) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFF5CE1E6);
                              }
                              return Colors.white24;
                            },
                          ),
                          trackColor: WidgetStateProperty.resolveWith<Color?>(
                                (states) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFF5CE1E6)
                                    .withValues(alpha: 0.3);
                              }
                              return Colors.white12;
                            },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Repeat tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          _RepeatChip(
                            label: t.createHabitDaily,
                            selected: _repeatType == HabitRepeatType.daily,
                            onTap: () {
                              setState(() => _repeatType = HabitRepeatType.daily);
                            },
                          ),
                          _RepeatChip(
                            label: t.createHabitWeekly,
                            selected: _repeatType == HabitRepeatType.weekly,
                            onTap: () {
                              setState(() => _repeatType = HabitRepeatType.weekly);
                            },
                          ),
                          _RepeatChip(
                            label: t.createHabitMonthly,
                            selected: _repeatType == HabitRepeatType.monthly,
                            onTap: () {
                              setState(() => _repeatType = HabitRepeatType.monthly);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_repeatEnabled) _buildRepeatBody(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Reminder & Goal
              _ToggleRow(
                label: t.createHabitReminderLabel,
                value: _reminderEnabled,
                onChanged: (v) async {
                  setState(() => _reminderEnabled = v);
                  if (v) {
                    await NotificationService.requestPermission();
                    await _pickReminderTime();
                  }
                },
              ),
              if (_reminderEnabled) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.createHabitSendNotificationAt,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _formatTimeOfDay(_reminderTime, t),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _pickReminderTime,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.notifications_active_outlined,
                                size: 18),
                            label: Text(
                              t.createHabitPickTime,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.createHabitReminderInfo,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _ToggleRow(
                label: t.createHabitGoalLabel,
                value: _goalEnabled,
                onChanged: (v) => setState(() => _goalEnabled = v),
              ),
              if (_goalEnabled) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            t.createHabitGoalLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _openGoalPicker,
                            child: Text(
                              t.createHabitEdit,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF5CE1E6),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _goalLabel(t),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.createHabitTrackUnitsHelp,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      )
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5CE1E6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                      : Text(
                    _isEdit ? t.createHabitSaveChanges : t.createHabitSave,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatBody() {
    final t = AppLocalizations.of(context)!;

    switch (_repeatType) {
      case HabitRepeatType.daily:
        final labels = [
          t.createHabitMonShort,
          t.createHabitTueShort,
          t.createHabitWedShort,
          t.createHabitThuShort,
          t.createHabitFriShort,
          t.createHabitSatShort,
          t.createHabitSunShort,
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.createHabitOnTheseDays,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                final dayIndex = index + 1;
                final selected = _selectedWeekdays.contains(dayIndex);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedWeekdays.remove(dayIndex);
                      } else {
                        _selectedWeekdays.add(dayIndex);
                      }
                      if (_selectedWeekdays.isEmpty) {
                        _selectedWeekdays.add(dayIndex);
                      }
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF5CE1E6)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      labels[index],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );

      case HabitRepeatType.weekly:
        final freqText = _weeklyFrequency == 7
            ? t.createHabitEveryday
            : t.createHabitDaysPerWeek(_weeklyFrequency);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.createHabitFrequency,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  freqText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
                const Spacer(),
                _StepperButton(
                  icon: Icons.remove,
                  onTap: () {
                    setState(() {
                      _weeklyFrequency = (_weeklyFrequency - 1).clamp(1, 7);
                    });
                  },
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_weeklyFrequency',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StepperButton(
                  icon: Icons.add,
                  onTap: () {
                    setState(() {
                      _weeklyFrequency = (_weeklyFrequency + 1).clamp(1, 7);
                    });
                  },
                ),
              ],
            ),
          ],
        );

      case HabitRepeatType.monthly:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.createHabitOnThisDayEachMonth,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemCount: 31,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final selected = _monthlyDay == day;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _monthlyDay = day);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF5CE1E6)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$day',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
    }
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[300],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _TextFieldBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Color fieldColor;
  final Color borderColor;
  final int maxLines;

  const _TextFieldBox({
    required this.controller,
    required this.hintText,
    required this.fieldColor,
    required this.borderColor,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.white,
      ),
      cursorColor: Colors.white70,
      decoration: InputDecoration(
        filled: true,
        fillColor: fieldColor,
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey[500],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.white24, width: 1.2),
        ),
      ),
    );
  }
}

class _RepeatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RepeatChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Switch(
          value: value,
          onChanged: onChanged,
          thumbColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF5CE1E6);
              }
              return Colors.white24;
            },
          ),
          trackColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF5CE1E6).withValues(alpha: 0.3);
              }
              return Colors.white12;
            },
          ),
        ),
      ],
    );
  }
}
