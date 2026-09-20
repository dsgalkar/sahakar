import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../customer/live_tracking_screen.dart';

class WorkerDashboard extends ConsumerStatefulWidget {
  const WorkerDashboard({super.key});

  @override
  ConsumerState<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {
  final TextEditingController _otpVerifyController = TextEditingController();

  @override
  void dispose() {
    _otpVerifyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOnline = ref.watch(workerOnlineStatusProvider);
    final tickets = ref.watch(activeTicketsProvider);
    final activeTicket = tickets.where((t) => t.status != TicketStatus.completed).firstOrNull;
    final worker = MockDataService.getCooperativeWorkers().first;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Worker Profile & Online Toggle Bar
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
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.accentGoldLight.withOpacity(0.2),
                  child: const Icon(
                    Icons.engineering_rounded,
                    size: 30,
                    color: AppColors.accentGoldLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            worker.name,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 16, color: AppColors.successGreenLight),
                        ],
                      ),
                      Text(
                        '${worker.trade} • Level ${worker.nsqfLevel}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        worker.societyName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlueLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch(
                      value: isOnline,
                      activeColor: AppColors.successGreenLight,
                      onChanged: (val) {
                        ref.read(workerOnlineStatusProvider.notifier).setStatus(val);
                      },
                    ),
                    Text(
                      isOnline ? 'ONLINE' : 'OFFLINE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isOnline ? AppColors.successGreenLight : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // e-Shram & Statutory Welfare Header Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'e-Shram Pass',
                  subtitle: 'Aadhaar Verified',
                  badge: 'UAN Active',
                  icon: Icons.badge_rounded,
                  color: AppColors.primaryBlueLight,
                  isDark: isDark,
                  onTap: () => _showEShramPassModal(context, worker, isDark),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: 'Micro-Insurance',
                  subtitle: '₹5 Job Accident Cover',
                  badge: 'Active Policy',
                  icon: Icons.shield_rounded,
                  color: AppColors.successGreenLight,
                  isDark: isDark,
                  onTap: () => _showInsuranceDetails(context, isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daily Earnings & Social Security Fund Accumulation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E2A4A), const Color(0xFF131D38)]
                    : [Colors.blue.shade50, Colors.teal.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(
                  label: "Today's Wage",
                  value: '₹1,240',
                  icon: Icons.account_balance_wallet_rounded,
                  color: isDark ? Colors.white : AppColors.primaryBlue,
                ),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                _buildMetric(
                  label: 'SS Fund Accrued',
                  value: '₹68',
                  icon: Icons.savings_rounded,
                  color: AppColors.accentGoldLight,
                ),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                _buildMetric(
                  label: 'Completed Gigs',
                  value: '4 Jobs',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.successGreenLight,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Active Assigned Job Ticket Action Center
          Text(
            'Assigned Instant Dispatch Ticket',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),

          if (activeTicket != null)
            _buildActiveJobCard(context, activeTicket, isDark)
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.radar_rounded, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text(
                    'Waiting for nearby instant tickets...',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'You are in the 3.5 km priority dispatch circle for New Delhi',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // SOS Panic Button for Gig Workers
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.emergencyRedLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.emergencyRedLight.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.health_and_safety_rounded, color: AppColors.emergencyRedLight, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Worker Safety SOS',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      Text(
                        'Alert cooperative supervisor & local PCR immediately',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.emergencyRed,
                        content: Text('🚨 Emergency alert sent to Society Supervisor & Emergency Contact'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyRed),
                  child: const Text('SOS'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 22),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildActiveJobCard(BuildContext context, TicketRequest ticket, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLight.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flash_on_rounded, color: AppColors.accentGoldLight),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.serviceName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Customer: ${ticket.customerName} (${ticket.customerPhone})',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGoldLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.status.displayName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentGoldLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ticket.customerAddress,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Direct Payout Share (88%)', style: TextStyle(fontSize: 12)),
                  Text(
                    '₹${ticket.fairPrice.workerWage.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.successGreenLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Step Action Buttons for Gig Worker
            if (ticket.status == TicketStatus.requested || ticket.status == TicketStatus.accepted)
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(activeTicketsProvider.notifier)
                      .updateTicketStatus(ticket.id, TicketStatus.enRoute);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marked En Route! User live map updated.')),
                  );
                },
                icon: const Icon(Icons.navigation_rounded),
                label: const Text('START TRIP / MARK EN ROUTE'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  backgroundColor: AppColors.primaryBlueLight,
                ),
              )
            else if (ticket.status == TicketStatus.enRoute)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LiveTrackingScreen(ticketId: ticket.id),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map_rounded, size: 16),
                      label: const Text('View Route'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(activeTicketsProvider.notifier)
                            .updateTicketStatus(ticket.id, TicketStatus.arrived);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Arrived outside customer location.')),
                        );
                      },
                      icon: const Icon(Icons.pin_drop_rounded, size: 16),
                      label: const Text('Mark Arrived'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreenLight),
                    ),
                  ),
                ],
              )
            else if (ticket.status == TicketStatus.arrived)
              ElevatedButton.icon(
                onPressed: () => _showVerifyOtpModal(context, ticket),
                icon: const Icon(Icons.verified_user_rounded),
                label: const Text('ENTER CUSTOMER OTP & START WORK'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  backgroundColor: AppColors.accentGoldLight,
                  foregroundColor: Colors.black,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showVerifyOtpModal(BuildContext context, TicketRequest ticket) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify Customer Start OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ask the customer for their 4-digit service start OTP (visible on their Live Tracking screen):',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _otpVerifyController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                hintText: 'e.g. 4829',
                prefixIcon: Icon(Icons.lock_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(activeTicketsProvider.notifier)
                  .updateTicketStatus(ticket.id, TicketStatus.completed);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.successGreen,
                  content: Text('🎉 Service Completed! ₹219 added to instant bank wallet.'),
                ),
              );
            },
            child: const Text('Verify & Complete Gig'),
          ),
        ],
      ),
    );
  }

  void _showEShramPassModal(BuildContext context, WorkerProfile worker, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'e-Shram Digital Pass',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Digital Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'GOVERNMENT OF INDIA',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'e-Shram UAN',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      worker.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'UAN: ${worker.eShramUan}',
                      style: const TextStyle(
                        color: AppColors.accentGoldLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'COOPERATIVE SOCIETY',
                              style: TextStyle(color: Colors.white54, fontSize: 8),
                            ),
                            Text(
                              worker.societyName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.qr_code_2_rounded, size: 40, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Statutory Welfare Portability: Linked to Code on Social Security 2020. Valid across India for PM-JAY, PM-SYM & ESIC benefits.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInsuranceDetails(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: AppColors.successGreenLight),
            SizedBox(width: 8),
            Text('Job Micro-Insurance Shield'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Under Sahakar cooperative bye-laws, every accepted gig is automatically insured with a ₹5 micro-policy covering:',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 8),
            Text('• Up to ₹2,00,000 accidental disability cover'),
            Text('• Up to ₹50,000 emergency medical expense buffer'),
            Text('• Direct federation claim settlement within 48 hours'),
          ],
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
