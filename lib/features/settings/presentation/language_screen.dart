// settings/presentation/language_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({
    super.key,
    this.initialLanguageCode,
    this.onApplied,
  });

  /// Optional pre-selected language (e.g. "en", "de", "es", "ru", "tr", "fr")
  final String? initialLanguageCode;

  /// Optional callback if you want to apply language without Navigator.pop
  /// (e.g. call your SettingsCubit / Locale provider).
  final ValueChanged<String>? onApplied;

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String? _selected;

  final _languages = const <_LanguageOption>[
    _LanguageOption(
      code: 'en',
      label: 'English',
      assetPath: 'lib/assets/uk_flag.png',
    ),
    _LanguageOption(
      code: 'de',
      label: 'German',
      assetPath: 'lib/assets/de_flag.png',
    ),
    _LanguageOption(
      code: 'es',
      label: 'Spanish',
      assetPath: 'lib/assets/es_flag.png',
    ),
    _LanguageOption(
      code: 'ru',
      label: 'Russian',
      assetPath: 'lib/assets/ru_flag.png',
    ),
    _LanguageOption(
      code: 'tr',
      label: 'Turkish',
      assetPath: 'lib/assets/tr_flag.png',
    ),
    _LanguageOption(
      code: 'fr',
      label: 'French',
      assetPath: 'lib/assets/fr_flag.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLanguageCode;
  }

  void _apply() {
    final code = _selected;
    if (code == null) return;

    widget.onApplied?.call(code);
    Navigator.of(context).pop(code); // also returns the code for callers
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2A2A2E); // close to your screenshot background
    final w = MediaQuery.of(context).size.width;

    // 2 columns, comfortable spacing like the screenshot
    const crossAxisCount = 2;
    const spacing = 18.0;
    const sidePadding = 24.0;

    final tileWidth =
        (w - (sidePadding * 2) - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;

    // Hex looks best slightly taller than wide
    final hexSize = tileWidth.clamp(120.0, 170.0) * 0.72;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(sidePadding, 18, sidePadding, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar (back + title)
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Choose Language',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: 1.05,
                        ),
                        itemCount: _languages.length,
                        itemBuilder: (context, index) {
                          final opt = _languages[index];
                          final selected = opt.code == _selected;

                          return _LanguageTile(
                            option: opt,
                            selected: selected,
                            hexSize: hexSize,
                            onTap: () => setState(() => _selected = opt.code),
                          );
                        },
                      ),
                      const SizedBox(height: 22),

                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 140),
                          opacity: _selected == null ? 0.55 : 1.0,
                          child: ElevatedButton(
                            onPressed: _selected == null ? null : _apply,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3A3A40),
                              disabledBackgroundColor:
                              const Color(0xFF3A3A40),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Continue',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
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
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.option,
    required this.selected,
    required this.hexSize,
    required this.onTap,
  });

  final _LanguageOption option;
  final bool selected;
  final double hexSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
    selected ? const Color(0xFF5CE1E6) : Colors.white.withValues(alpha: 0.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 140),
            scale: selected ? 1.02 : 1.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Flag inside hex
                ClipPath(
                  clipper: PointyHexagonClipper(),
                  child: Image.asset(
                    option.assetPath,
                    width: hexSize,
                    height: hexSize,
                    fit: BoxFit.cover,
                  ),
                ),

                // Border outline
                CustomPaint(
                  size: Size(hexSize, hexSize),
                  painter: _HexBorderPainter(
                    color: borderColor,
                    strokeWidth: 2.2,
                  ),
                ),

                // Selected check
                Positioned(
                  top: 6,
                  right: 6,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: selected ? 1.0 : 0.0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F13)
                            .withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF5CE1E6),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Color(0xFF5CE1E6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            option.label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.code,
    required this.label,
    required this.assetPath,
  });

  final String code;
  final String label;
  final String assetPath;
}

/// Flat-top hexagon: left/right points, top/bottom edges flat.
/// Matches the look in your screenshot.
class PointyHexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    return Path()
      ..moveTo(w * 0.5, 0)        // top point
      ..lineTo(w, h * 0.25)       // upper-right
      ..lineTo(w, h * 0.75)       // lower-right
      ..lineTo(w * 0.5, h)        // bottom point
      ..lineTo(0, h * 0.75)       // lower-left
      ..lineTo(0, h * 0.25)       // upper-left
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}


class _HexBorderPainter extends CustomPainter {
  _HexBorderPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0) return;

    final path = PointyHexagonClipper().getClip(size);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HexBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
