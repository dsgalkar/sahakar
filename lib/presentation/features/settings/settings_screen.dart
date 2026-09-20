import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sahakar_logo.dart';
import '../../auth/login_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = ref.watch(themeModeProvider);
    final currentRole = ref.watch(currentRoleProvider);
    final currentLang = ref.watch(bhashiniLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SahakarLogo(size: 28, showBadgeBorder: false, isCompact: true),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        children: [
          // User & Role Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'settings_profile_logo',
                  child: SahakarLogo(
                    size: 52,
                    showBadgeBorder: true,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentRole == UserRole.user
                            ? 'Ananya Sharma'
                            : (currentRole == UserRole.gigWorker
                                ? 'Rameshwar Kumar'
                                : 'Cooperative Federation Admin'),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlueLight.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Active Role: ${currentRole.label}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlueLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Switch Role / Logout',
                  icon: const Icon(Icons.logout_rounded, color: AppColors.emergencyRedLight),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 1: Appearance & Theme (Dark & Light Mode)
          _buildSectionHeader('Appearance & Theme'),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Mode (High Contrast Sleek)'),
                  secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.accentGoldLight),
                  value: ThemeMode.dark,
                  groupValue: currentTheme,
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(themeModeProvider.notifier).setTheme(mode);
                    }
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode (Crisp Clean)'),
                  secondary: const Icon(Icons.light_mode_rounded, color: AppColors.accentGold),
                  value: ThemeMode.light,
                  groupValue: currentTheme,
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(themeModeProvider.notifier).setTheme(mode);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: Multilingual Bhashini Support
          _buildSectionHeader('Bhashini Multilingual Language'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select voice & interface language (22 Scheduled Languages compatible):',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildLangChip(ref, 'English', 'en', currentLang, isDark),
                    _buildLangChip(ref, 'हिन्दी (Hindi)', 'hi', currentLang, isDark),
                    _buildLangChip(ref, 'मराठी (Marathi)', 'mr', currentLang, isDark),
                    _buildLangChip(ref, 'বাংলা (Bengali)', 'bn', currentLang, isDark),
                    _buildLangChip(ref, 'தமிழ் (Tamil)', 'ta', currentLang, isDark),
                    _buildLangChip(ref, 'తెలుగు (Telugu)', 'te', currentLang, isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 3: Statutory & Verification Links
          _buildSectionHeader('Verification & Statutory Compliance'),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.verified_rounded, color: AppColors.successGreenLight),
                  title: const Text('DigiLocker Aadhaar Verification'),
                  subtitle: const Text('Verified • UIDAI compliant penny-drop check'),
                  trailing: const Icon(Icons.check_circle_rounded, color: AppColors.successGreenLight),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.badge_rounded, color: AppColors.primaryBlueLight),
                  title: const Text('e-Shram Universal Account Number (UAN)'),
                  subtitle: const Text('Active • Portable national benefits'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.gavel_rounded, color: AppColors.accentGoldLight),
                  title: const Text('Code on Social Security 2020'),
                  subtitle: const Text('Section 114 compliance • 1-2% statutory fund audit'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showComplianceDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 4: Offline & Safety
          _buildSectionHeader('Safety & Offline Resilience'),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Audio Guidance & Dispatch Chimes'),
                  subtitle: const Text('Plays audible notifications for low-literacy workers'),
                  value: true,
                  activeColor: AppColors.primaryBlueLight,
                  onChanged: (val) {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sync_rounded, color: AppColors.primaryBlueLight),
                  title: const Text('Offline Local Cache & Sync'),
                  subtitle: const Text('2.4 MB cached • Syncs automatically via SMS/Data'),
                  trailing: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cooperative dispatch ledger synchronized!')),
                      );
                    },
                    child: const Text('Sync Now'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // About Sahakar
          Center(
            child: Column(
              children: [
                SahakarLogo(size: 44, showBadgeBorder: true, isCompact: true),
                const SizedBox(height: 8),
                const Text(
                  'Sahakar : Instant Gig Support',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const Text(
                  'SIH 2026 • Ministry of Cooperation Aligned',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Text(
                  'Version 1.0.0-rc.1 (Cooperative Build 2026.09)',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.2),
      ),
    );
  }

  Widget _buildLangChip(WidgetRef ref, String name, String code, String activeCode, bool isDark) {
    final isSelected = activeCode == code;
    return ChoiceChip(
      label: Text(name),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          ref.read(bhashiniLanguageProvider.notifier).setLanguage(code);
        }
      },
      selectedColor: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  void _showComplianceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Statutory Compliance Framework'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Code on Social Security 2020 (Brought into force on 21 Nov 2025):',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              SizedBox(height: 8),
              Text(
                '• Section 114: Aggregators must contribute 1-2% of annual turnover to the Social Security Fund.',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                '• Section 113: Compulsory registration of all gig and platform workers on e-Shram for portable social security.',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                '• Cooperative Architecture: 88% direct wage pass-through, eliminating predatory 25-30% private intermediary fees.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
