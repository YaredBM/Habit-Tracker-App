import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum _SettingsTheme { light, dark }
enum _StartWeekOn { saturday, sunday, monday }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _SettingsTheme _theme = _SettingsTheme.dark;
  _StartWeekOn _startWeekOn = _StartWeekOn.monday;
  int _accentIndex = 0;

  final List<Color> _accentColors = const [
    Color(0xFF4C8DF6), // blue
    Color(0xFF3FBF7F), // green
    Color(0xFFF2A13B), // yellow / orange
    Color(0xFFF56B5C), // red
    Color(0xFF9B6BFF), // purple
    Color(0xFF8E8EFF), // violet
    Color(0xFFFF71C1), // pink
  ];

  final List<String> _habitTabsOrder = [
    'Today',
    'Weekly',
    'Overall',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                'Settings',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),

              // THEME
              Text(
                'Theme',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _SettingsOptionCard<_SettingsTheme>(
                groupValue: _theme,
                onChanged: (value) {
                  setState(() {
                    _theme = value;
                  });
                },
                options: const [
                  _SettingsOption<_SettingsTheme>(
                    value: _SettingsTheme.light,
                    label: 'Light',
                  ),
                  _SettingsOption<_SettingsTheme>(
                    value: _SettingsTheme.dark,
                    label: 'Dark',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ACCENT COLOR
              Text(
                'Accent color',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (int i = 0; i < _accentColors.length; i++) ...[
                    _AccentDot(
                      color: _accentColors[i],
                      selected: _accentIndex == i,
                      onTap: () {
                        setState(() {
                          _accentIndex = i;
                        });
                      },
                    ),
                    if (i != _accentColors.length - 1)
                      const SizedBox(width: 12),
                  ],
                ],
              ),

              const SizedBox(height: 28),

              // START WEEK ON
              Text(
                'Start week on',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _SettingsOptionCard<_StartWeekOn>(
                groupValue: _startWeekOn,
                onChanged: (value) {
                  setState(() {
                    _startWeekOn = value;
                  });
                },
                options: const [
                  _SettingsOption<_StartWeekOn>(
                    value: _StartWeekOn.saturday,
                    label: 'Saturday',
                  ),
                  _SettingsOption<_StartWeekOn>(
                    value: _StartWeekOn.sunday,
                    label: 'Sunday',
                  ),
                  _SettingsOption<_StartWeekOn>(
                    value: _StartWeekOn.monday,
                    label: 'Monday',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // HABIT TABS ORDER
              Text(
                'Habit tabs order',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF15151A),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  buildDefaultDragHandles: false,
                  itemCount: _habitTabsOrder.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _habitTabsOrder.removeAt(oldIndex);
                      _habitTabsOrder.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final label = _habitTabsOrder[index];
                    final isLast = index == _habitTabsOrder.length - 1;

                    return ReorderableDragStartListener(
                      key: ValueKey(label),
                      index: index,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  label,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.menu,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Container(
                              margin:
                              const EdgeInsets.symmetric(horizontal: 16),
                              height: 0.6,
                              color:
                              Colors.white.withValues(alpha: 0.08),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Long press an item to reorder',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SUB-WIDGETS                                                                */
/* -------------------------------------------------------------------------- */

class _SettingsOption<T> {
  final T value;
  final String label;

  const _SettingsOption({
    required this.value,
    required this.label,
  });
}

class _SettingsOptionCard<T> extends StatelessWidget {
  const _SettingsOptionCard({
    required this.groupValue,
    required this.onChanged,
    required this.options,
  });

  final T groupValue;
  final ValueChanged<T> onChanged;
  final List<_SettingsOption<T>> options;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF15151A),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            _SettingsOptionRow<T>(
              option: options[i],
              selected: options[i].value == groupValue,
              onTap: () => onChanged(options[i].value),
              isFirst: i == 0,
              isLast: i == options.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsOptionRow<T> extends StatelessWidget {
  const _SettingsOptionRow({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
  });

  final _SettingsOption<T> option;
  final bool selected;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(22) : Radius.zero,
        bottom: isLast ? const Radius.circular(22) : Radius.zero,
      ),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Text(
              option.label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(
                Icons.check,
                size: 18,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2.5,
            ),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
