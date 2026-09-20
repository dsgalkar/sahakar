import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../core/services/user_database_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/creative_avatar.dart';
import '../../../core/widgets/futuristic_widgets.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Apex Federation Futuristic Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.cyberPurpleGradient : AppColors.cyberCyanGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonPurple.withValues(alpha: isDark ? 0.35 : 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'NATIONAL COOPERATIVE FEDERATION',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const NeonPill(
                      text: 'AUDIT VERIFIED',
                      color: AppColors.neonGreen,
                      isFilled: true,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Governance & Social Security Ledger',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Central cryptographic registry for 42 affiliated primary societies & 3,280 verified KarmaYogis.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Statutory Social Security Fund (Sec 114) KPI Section
          const Text(
            'Statutory Social Security Fund (Sec 114)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'Mandated under Code on Social Security 2020 (effective 21 Nov 2025)',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Expanded(
                child: TelemetryCard(
                  label: 'Turnover Corpus (1.5%)',
                  value: '₹8,42,190',
                  subtext: 'Accumulated Sec 114',
                  icon: Icons.account_balance_rounded,
                  color: AppColors.neonGold,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: TelemetryCard(
                  label: 'Welfare Claims Paid',
                  value: '₹1,24,000',
                  subtext: 'Direct Pass-Through',
                  icon: Icons.health_and_safety_rounded,
                  color: AppColors.neonGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: TelemetryCard(
                  label: 'Insured Gig Members',
                  value: '3,280',
                  subtext: 'Active Cooperative Base',
                  icon: Icons.people_alt_rounded,
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: TelemetryCard(
                  label: 'e-Shram Seed Ratio',
                  value: '99.4%',
                  subtext: 'Aadhaar Biometric Linked',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.neonPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Worker KYC & Society Verification Queue
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Member KYC Verification Queue',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentGoldLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '3 Pending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentGoldLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _buildKycCard(
            name: 'Kailash Chand Verma',
            trade: 'HVAC Technician (Appliance)',
            society: 'Bhopal Karigar Sahakari Samiti',
            aadhaarStatus: 'DigiLocker Verified',
            policeStatus: 'Clearance Uploaded',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildKycCard(
            name: 'Manjula Ben Patel',
            trade: 'Sanitation Specialist (Cleaning)',
            society: 'Mahila Sewa Co-op Society',
            aadhaarStatus: 'DigiLocker Verified',
            policeStatus: 'Society Endorsed',
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          // Demand & Idle-Worker Heatmap Summary
          const Text(
            'District Demand vs Workforce Allocation',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _buildDistrictAllocationBar('Connaught Place (Central)', 88, 42, isDark),
          const SizedBox(height: 8),
          _buildDistrictAllocationBar('South Delhi (Saket / Hauz Khas)', 94, 68, isDark),
          const SizedBox(height: 8),
          _buildDistrictAllocationBar('East Delhi (Mayur Vihar)', 62, 58, isDark),
          const SizedBox(height: 8),
          _buildDistrictAllocationBar('Noida Sector 62 / Indirapuram', 75, 51, isDark),

          const SizedBox(height: 20),

          // Real-time Persistent User Accounts Database Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Registered Cooperative Members Database',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${UserDatabaseService.getAllUsers().length} Accounts Active',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlueLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...UserDatabaseService.getAllUsers().map((user) {
            final roleColor = user.role == UserRole.admin
                ? AppColors.neonPurple
                : (user.role == UserRole.gigWorker
                    ? AppColors.neonGold
                    : AppColors.neonCyan);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.2,
                ),
              ),
              child: InkWell(
                onTap: () => _showUserDetailsDialog(context, user, isDark),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    CreativeAvatar(
                      size: 42,
                      role: user.role,
                      tradeName: user.trade,
                      name: user.fullName,
                      isOnline: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              NeonPill(
                                text: user.role.label,
                                color: roleColor,
                                isFilled: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+91 ${user.phone} • ${user.city}, ${user.state}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          if (user.role == UserRole.gigWorker && user.trade != null)
                            Text(
                              '${user.trade} (${user.societyName ?? "Cooperative"})',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentGoldLight,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showUserDetailsDialog(BuildContext context, AppUser user, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.badge_rounded, color: AppColors.primaryBlueLight),
            const SizedBox(width: 8),
            Text(user.fullName),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('User ID', user.id),
              _detailRow('Mobile', '+91 ${user.phone}'),
              _detailRow('Email', user.email.isNotEmpty ? user.email : 'N/A'),
              _detailRow('Role', user.role.label),
              _detailRow('Primary Address', user.address),
              _detailRow('GPS Pin', '${user.latitude.toStringAsFixed(4)}, ${user.longitude.toStringAsFixed(4)}'),
              if (user.trade != null) _detailRow('Trade / Skill', user.trade!),
              if (user.eShramUan != null) _detailRow('e-Shram UAN', user.eShramUan!),
              if (user.societyName != null) _detailRow('Society', user.societyName!),
              if (user.designation != null) _detailRow('Designation', user.designation!),
              _detailRow('Registered On', user.registeredAt.toLocal().toString().split(' ').first),
              _detailRow('KYC Audit', user.isVerified ? 'Verified & Audited' : 'Pending'),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildKycCard({
    required String name,
    required String trade,
    required String society,
    required String aadhaarStatus,
    required String policeStatus,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CreativeAvatar(
            size: 44,
            tradeName: trade,
            name: name,
            isOnline: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    NeonPill(
                      text: aadhaarStatus,
                      color: AppColors.neonGreen,
                      isFilled: true,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$trade • $society',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 14, color: AppColors.neonCyan),
                    const SizedBox(width: 4),
                    Text(
                      policeStatus,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonGreen,
                        foregroundColor: const Color(0xFF07090E),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: const Size(60, 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictAllocationBar(String district, int demandIndex, int activeWorkers, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(district, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              Text(
                '$activeWorkers Active Workers',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlueLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: demandIndex / 100,
              backgroundColor: isDark ? Colors.black26 : Colors.grey.shade200,
              color: demandIndex > 80 ? AppColors.accentGoldLight : AppColors.primaryBlueLight,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
