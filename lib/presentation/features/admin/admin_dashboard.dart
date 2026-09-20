import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

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
          // Apex Federation Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF132042), const Color(0xFF1E3A8A)]
                    : [AppColors.primaryBlue, const Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  blurRadius: 10,
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
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successGreenLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AUDIT VERIFIED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Governance & Social Security Ledger',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Central registry for 42 affiliated primary societies & 3,280 verified members.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Statutory Social Security Fund (Sec 114) KPI Section
          const Text(
            'Statutory Social Security Fund (Sec 114)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Mandated under Code on Social Security 2020 (effective 21 Nov 2025)',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Turnover Corpus (1.5%)',
                  value: '₹8,42,190',
                  icon: Icons.account_balance_rounded,
                  color: AppColors.accentGoldLight,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Welfare Claims Paid',
                  value: '₹1,24,000',
                  icon: Icons.health_and_safety_rounded,
                  color: AppColors.successGreenLight,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Insured Gig Members',
                  value: '3,280',
                  icon: Icons.people_alt_rounded,
                  color: AppColors.primaryBlueLight,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'e-Shram Seed Ratio',
                  value: '99.4%',
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.tealAccent.shade700,
                  isDark: isDark,
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

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successGreenLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  aadhaarStatus,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successGreenLight,
                  ),
                ),
              ),
            ],
          ),
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
              Icon(Icons.shield_outlined, size: 14, color: AppColors.primaryBlueLight),
              const SizedBox(width: 4),
              Text(
                policeStatus,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreenLight,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(60, 32),
                ),
                child: const Text('Approve', style: TextStyle(fontSize: 12)),
              ),
            ],
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
