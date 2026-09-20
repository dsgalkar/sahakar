import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/creative_avatar.dart';
import '../../../core/widgets/futuristic_widgets.dart';
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
          // User & Role Card with CreativeAvatar
          GlassNeonCard(
            neonGlowColor: currentRole == UserRole.user
                ? AppColors.neonCyan
                : (currentRole == UserRole.gigWorker ? AppColors.neonGold : AppColors.neonPurple),
            glowSpread: 0.12,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CreativeAvatar(
                  role: currentRole,
                  tradeName: currentRole == UserRole.gigWorker ? 'Electrician' : null,
                  radius: 30,
                  showGlow: true,
                  nsqfLevel: currentRole == UserRole.gigWorker ? 4 : null,
                  isLiveOnline: currentRole == UserRole.gigWorker,
                ),
                const SizedBox(width: 16),
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
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.2),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          NeonPill(
                            label: currentRole.label.toUpperCase(),
                            color: currentRole == UserRole.user
                                ? AppColors.neonCyan
                                : (currentRole == UserRole.gigWorker ? AppColors.neonGold : AppColors.neonPurple),
                            isFilled: true,
                          ),
                          const SizedBox(width: 6),
                          if (currentRole == UserRole.gigWorker)
                            const NeonPill(
                              label: 'NSQF L-4',
                              color: AppColors.neonGreen,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Switch Role / Logout',
                  icon: const Icon(Icons.logout_rounded, color: AppColors.neonCoral),
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
          _buildSectionHeader('Appearance & Theme', AppColors.neonCyan),
          GlassNeonCard(
            neonGlowColor: isDark ? AppColors.neonCyan : Colors.transparent,
            glowSpread: isDark ? 0.08 : 0.0,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Obsidian (Futuristic High Contrast)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  secondary: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.dark_mode_rounded, color: AppColors.neonCyan, size: 20),
                  ),
                  activeColor: AppColors.neonCyan,
                  value: ThemeMode.dark,
                  groupValue: currentTheme,
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(themeModeProvider.notifier).setTheme(mode);
                    }
                  },
                ),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                RadioListTile<ThemeMode>(
                  title: const Text('Light Porcelain (Minimalist Crisp)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  secondary: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.neonGold.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.light_mode_rounded, color: AppColors.neonGold, size: 20),
                  ),
                  activeColor: AppColors.neonGold,
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
          _buildSectionHeader('Bhashini Multilingual Engine', AppColors.neonPurple),
          GlassNeonCard(
            neonGlowColor: AppColors.neonPurple,
            glowSpread: 0.08,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.translate_rounded, color: AppColors.neonPurple, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '22 Scheduled Indian Languages Compatible:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
          _buildSectionHeader('Verification & Statutory Credentials', AppColors.neonGreen),
          GlassNeonCard(
            neonGlowColor: AppColors.neonGreen,
            glowSpread: 0.08,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_rounded, color: AppColors.neonGreen, size: 20),
                  ),
                  title: const Text('DigiLocker Aadhaar Verification', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  subtitle: const Text('UIDAI Verified • Penny-drop bank authenticated', style: TextStyle(fontSize: 11)),
                  trailing: const NeonPill(label: 'AUTHENTICATED', color: AppColors.neonGreen, isFilled: true),
                ),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.badge_rounded, color: AppColors.neonCyan, size: 20),
                  ),
                  title: const Text('e-Shram Universal Account Number (UAN)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  subtitle: const Text('UAN: 1009-4428-9912 • Portable Social Security', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.neonCyan),
                ),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.neonGold.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.gavel_rounded, color: AppColors.neonGold, size: 20),
                  ),
                  title: const Text('Code on Social Security 2020', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  subtitle: const Text('Section 114 Compliance • 1-2% Statutory Fund audit', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.neonGold),
                  onTap: () => _showComplianceDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 4: Safety & Offline Resilience
          _buildSectionHeader('Safety & Offline Mesh Resilience', AppColors.neonGold),
          GlassNeonCard(
            neonGlowColor: AppColors.neonGold,
            glowSpread: 0.08,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Audio Guidance & Dispatch Chimes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  subtitle: const Text('Audible vocal prompts for low-literacy workers', style: TextStyle(fontSize: 11)),
                  value: true,
                  activeColor: AppColors.neonCyan,
                  activeTrackColor: AppColors.neonCyan.withOpacity(0.3),
                  onChanged: (val) {},
                ),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sync_rounded, color: AppColors.neonCyan, size: 20),
                  ),
                  title: const Text('Offline Local Mesh & Sync', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  subtitle: const Text('2.4 MB ledger cached • SMS fallback enabled', style: TextStyle(fontSize: 11)),
                  trailing: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.neonCyan),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.darkSurface,
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: AppColors.neonGreen, size: 18),
                                SizedBox(width: 8),
                                Text('Cooperative dispatch ledger synchronized!'),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Text('Sync Now', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // About Sahakar
          Center(
            child: Column(
              children: [
                SahakarLogo(size: 48, showBadgeBorder: true, isCompact: true),
                const SizedBox(height: 10),
                const Text(
                  'SAHAKAR GRID • COOPERATIVE GIG PROTOCOL',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2),
                ),
                const SizedBox(height: 2),
                const Text(
                  'SIH 2026 • Ministry of Cooperation Aligned',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                const Text(
                  'v1.0.0-rc.2 (Cyber-Minimalist Engine)',
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

  Widget _buildSectionHeader(String title, Color neonColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: neonColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: neonColor.withOpacity(0.8), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: neonColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangChip(WidgetRef ref, String name, String code, String activeCode, bool isDark) {
    final isSelected = activeCode == code;
    return GestureDetector(
      onTap: () {
        ref.read(bhashiniLanguageProvider.notifier).setLanguage(code);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonPurple.withOpacity(0.2)
              : (isDark ? AppColors.darkSurface : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.neonPurple : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonPurple.withOpacity(0.35),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: Text(
          name,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.white : AppColors.neonPurple)
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showComplianceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.gavel_rounded, color: AppColors.neonGold),
            SizedBox(width: 8),
            Text('Statutory Compliance Framework'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Code on Social Security 2020 (Enforced 21 Nov 2025):',
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
            child: const Text('Close', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
