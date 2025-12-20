import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProPlanScreen extends StatelessWidget {
  const ProPlanScreen({
    super.key,
    this.isSubscribed = true,
    this.planLabel = 'Pro Yearly',
  });

  final bool isSubscribed;
  final String planLabel;

  // Call this to open it exactly like the screenshot (modal bottom sheet).
  static Future<void> show(
      BuildContext context, {
        bool isSubscribed = true,
        String planLabel = 'Pro Yearly',
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProPlanScreen(isSubscribed: isSubscribed, planLabel: planLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF111015);
    const sheet = Color(0xFF0F0F13);
    const card = Color(0xFF15151A);
    const proBlue = Color(0xFF2E6FD0);

    final h = MediaQuery.of(context).size.height;

    final features = <_ProFeature>[
      _ProFeature(
        label: 'Unlimited Habits',
        leadingAsset: 'lib/assets/current_streak.png',
        free: true,
        pro: true,
      ),
      _ProFeature(
        label: 'Routine AI',
        leadingAsset: 'lib/assets/sparkles.png',
        free: false,
        pro: true,
      ),
      _ProFeature(
        label: 'Analytics',
        leadingAsset: 'lib/assets/bar_analytics.png',
        free: false,
        pro: true,
      ),
      _ProFeature(
        label: 'Goal setting',
        leadingAsset: 'lib/assets/best_streak.png',
        free: false,
        pro: true,
      ),
      _ProFeature(
        label: 'Journaling',
        leadingAsset: 'lib/assets/journal_book.png',
        free: false,
        pro: true,
      ),
      _ProFeature(
        label: 'Color Picker',
        leadingAsset: 'lib/assets/color_palette.png',
        free: false,
        pro: true,
      ),
      _ProFeature(
        label: 'Backup habits',
        leadingAsset: 'lib/assets/disk_backup.png',
        free: false,
        pro: true,
      ),
    ];

    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: h * 0.86,
            decoration: const BoxDecoration(
              color: sheet,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'EcoHabit Pro ',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(Icons.star, color: Color(0xFFFFD166), size: 16),
                      const Spacer(),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        // Subscription card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text('🎉', style: TextStyle(fontSize: 22)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isSubscribed ? 'You are subscribed to' : 'Upgrade to',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      planLabel,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: proBlue,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Feature table (FREE vs PRO)
                        _FeatureTable(
                          cardColor: card,
                          proBlue: proBlue,
                          features: features,
                        ),

                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),

                // Bottom close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: bg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureTable extends StatelessWidget {
  const _FeatureTable({
    required this.cardColor,
    required this.proBlue,
    required this.features,
  });

  final Color cardColor;
  final Color proBlue;
  final List<_ProFeature> features;

  @override
  Widget build(BuildContext context) {
    const colW = 58.0;
    const rowH = 44.0;
    const headerH = 34.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          // Table shell
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
          ),

          // PRO column highlight (behind)
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: colW,
                margin: const EdgeInsets.only(top: 0),
                decoration: BoxDecoration(
                  color: proBlue.withValues(alpha: 0.26),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          // Actual table content
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: headerH,
                  child: Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      SizedBox(
                        width: colW,
                        child: Center(
                          child: Text(
                            'FREE',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: colW,
                        child: Center(
                          child: Text(
                            'PRO',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: proBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),

                const SizedBox(height: 6),

                ...features.map((f) {
                  return SizedBox(
                    height: rowH,
                    child: Row(
                      children: [
                        // left cell
                        Expanded(
                          child: Row(
                            children: [
                              _FeatureIcon(f),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  f.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // FREE column
                        SizedBox(
                          width: colW,
                          child: Center(
                            child: f.free
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : const SizedBox.shrink(),
                          ),
                        ),

                        // PRO column
                        SizedBox(
                          width: colW,
                          child: Center(
                            child: f.pro
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  const _FeatureIcon(this.feature);
  final _ProFeature feature;

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withValues(alpha: 0.06);
    final border = Colors.white.withValues(alpha: 0.10);

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      alignment: Alignment.center,
      child: feature.leadingAsset != null
          ? Image.asset(
        feature.leadingAsset!,
        width: 18,
        height: 18,
        fit: BoxFit.contain,
      )
          : Icon(
        feature.leadingIcon ?? Icons.circle,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}

class _ProFeature {
  _ProFeature({
    required this.label,
    required this.free,
    required this.pro,
    this.leadingAsset,
    this.leadingIcon,
  });

  final String label;
  final bool free;
  final bool pro;

  final String? leadingAsset;
  final IconData? leadingIcon;
}
