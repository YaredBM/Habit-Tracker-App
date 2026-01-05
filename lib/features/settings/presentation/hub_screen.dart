import 'package:ecohabit/features/analytics/presentation/analytics_screen.dart';
import 'package:ecohabit/features/journal/presentation/journal_screen.dart';
import 'package:ecohabit/features/settings/presentation/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/features/settings/presentation/settings_screen.dart';
import 'pro_plan_screen.dart';
import 'package:ecohabit/features/settings/presentation/language_screen.dart';
import 'package:ecohabit/core/locale/locale_controller.dart';
import '/l10n/app_localizations.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({
    super.key,
    this.onSettingsTap,
    this.onAnalyticsTap,
    this.onJournalTap,
    this.onAccountTap,
    this.onBackupTap,
    this.appVersion = '2.0.4',
  });

  final VoidCallback? onSettingsTap;
  final VoidCallback? onAnalyticsTap;
  final VoidCallback? onJournalTap;
  final VoidCallback? onAccountTap;
  final VoidCallback? onBackupTap;
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false, // AppBar already handles top padding
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    const _ProCard(),
                    const SizedBox(height: 16),
                    _HubMenuCard(
                      onSettingsTap: onSettingsTap,
                      onAnalyticsTap: onAnalyticsTap,
                      onJournalTap: onJournalTap,
                      onAccountTap: onAccountTap,
                      onBackupTap: onBackupTap,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                t.hubVersionLabel(appVersion),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
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
/* PRO CARD                                                                   */
/* -------------------------------------------------------------------------- */

class _ProCard extends StatelessWidget {
  const _ProCard();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        ProPlanScreen.show(
          context,
          isSubscribed: true,
          planLabel: t.hubProPlanLabel,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF15151A),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD54F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Text(
              t.hubProTitle,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 22),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* MENU CARD                                                                  */
/* -------------------------------------------------------------------------- */

class _HubMenuCard extends StatelessWidget {
  const _HubMenuCard({
    required this.onSettingsTap,
    required this.onAnalyticsTap,
    required this.onJournalTap,
    required this.onAccountTap,
    required this.onBackupTap,
  });

  final VoidCallback? onSettingsTap;
  final VoidCallback? onAnalyticsTap;
  final VoidCallback? onJournalTap;
  final VoidCallback? onAccountTap;
  final VoidCallback? onBackupTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF121216),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _HubMenuItem(
            icon: Icons.settings_outlined,
            label: t.hubMenuSettings,
            onTap: onSettingsTap ??
                    () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
          ),
          const _HubDivider(),
          _HubMenuItem(
            icon: Icons.bar_chart_outlined,
            label: t.hubMenuAnalytics,
            onTap: onAnalyticsTap ??
                    () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                  );
                },
          ),
          const _HubDivider(),
          _HubMenuItem(
            icon: Icons.menu_book_outlined,
            label: t.hubMenuJournal,
            onTap: onJournalTap ??
                    () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const JournalScreen()),
                  );
                },
          ),
          const _HubDivider(),
          _HubMenuItem(
            icon: Icons.person_outline,
            label: t.hubMenuAccount,
            onTap: onAccountTap ??
                    () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AccountScreen()),
                  );
                },
          ),
          _HubMenuItem(
            icon: Icons.language_outlined,
            label: t.chooseLanguageTitle,
            onTap: () async {
              final code = await Navigator.of(context).push<String>(
                MaterialPageRoute(builder: (_) => const LanguageScreen()),
              );

              if (!context.mounted || code == null) return;

              await localeController.setLocale(
                code == 'system' ? null : Locale(code),
              );
            },
          ),
          const _HubDivider(),
          _HubMenuItem(
            icon: Icons.folder_open_outlined,
            label: t.hubMenuBackup,
            onTap: onBackupTap,
          ),
        ],
      ),
    );
  }
}

class _HubMenuItem extends StatelessWidget {
  const _HubMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
      ],
    );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: row,
      ),
    );
  }
}

class _HubDivider extends StatelessWidget {
  const _HubDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 0.7,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}
