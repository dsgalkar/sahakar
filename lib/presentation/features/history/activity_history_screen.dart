import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/app_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/futuristic_widgets.dart';

class ActivityHistoryScreen extends ConsumerStatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  ConsumerState<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends ConsumerState<ActivityHistoryScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    'Bookings & Gigs',
    'Location Updates',
    'Payments & SS Fund',
    'Emergency SOS',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentRole = ref.watch(currentRoleProvider);
    final allActivities = ref.watch(activityHistoryProvider);

    // Filter by role first
    final roleActivities = allActivities.where((a) {
      if (currentRole == UserRole.admin) return true; // Admin audits all activities
      return a.userRole == currentRole;
    }).toList();

    // Filter by category filter chip
    final categoryFiltered = roleActivities.where((a) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Bookings & Gigs') {
        return a.type == ActivityType.serviceBooked ||
            a.type == ActivityType.tripStarted ||
            a.type == ActivityType.workerArrived ||
            a.type == ActivityType.otpVerified ||
            a.type == ActivityType.serviceCompleted;
      }
      if (_selectedFilter == 'Location Updates') {
        return a.type == ActivityType.locationUpdated;
      }
      if (_selectedFilter == 'Payments & SS Fund') {
        return a.type == ActivityType.statutoryContribution ||
            (a.type == ActivityType.serviceCompleted && a.amount != null);
      }
      if (_selectedFilter == 'Emergency SOS') {
        return a.type == ActivityType.sosTriggered;
      }
      return true;
    }).toList();

    // Filter by search query
    final query = _searchController.text.trim().toLowerCase();
    final displayedActivities = categoryFiltered.where((a) {
      if (query.isEmpty) return true;
      return a.title.toLowerCase().contains(query) ||
          a.description.toLowerCase().contains(query) ||
          a.locationAddress.toLowerCase().contains(query) ||
          a.status.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // Header & Stats Bar
          _buildTopSummaryBar(context, currentRole, roleActivities.length, isDark),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search activity, address, or status...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (sel) {
                    if (sel) setState(() => _selectedFilter = filter);
                  },
                  selectedColor: isDark ? AppColors.neonCyan : AppColors.lightTextPrimary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? (isDark ? const Color(0xFF07090E) : Colors.white)
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Activities List
          Expanded(
            child: displayedActivities.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: displayedActivities.length,
                    itemBuilder: (context, index) {
                      final activity = displayedActivities[index];
                      return _buildActivityCard(context, activity, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSummaryBar(
    BuildContext context,
    UserRole currentRole,
    int totalCount,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.cyberCyanGradient : AppColors.cyberPurpleGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: isDark ? 0.35 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    NeonPill(
                      text: '${currentRole.shortTag} TELEMETRY TRAIL',
                      color: Colors.white,
                      isFilled: true,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$totalCount logged',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Activity & Wayfinding History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Chronological GPS-recorded log of every service action',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
            tooltip: 'Clear role activity history',
            onPressed: () => _confirmClearHistory(context, currentRole),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, AppActivity activity, bool isDark) {
    final iconData = _getIconForType(activity.type);
    final iconColor = _getColorForType(activity.type);
    final formattedTime = DateFormat('MMM d, h:mm a').format(activity.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activity.type == ActivityType.sosTriggered
              ? AppColors.emergencyRedLight.withOpacity(0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: activity.type == ActivityType.sosTriggered ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showActivityDetailSheet(context, activity, isDark),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Category Icon, Title, Status & Time
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                activity.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            NeonPill(
                              text: activity.status,
                              color: iconColor,
                              isFilled: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Description
              Text(
                activity.description,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),

              const SizedBox(height: 10),

              // Recorded Location & Amount Chips
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkSurface : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: AppColors.primaryBlueLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              activity.locationAddress,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (activity.amount != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.successGreenLight.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₹${activity.amount!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.successGreenLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 56,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No activities found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Activities such as instant bookings, location locks, and verified arrivals will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(ActivityType type) {
    switch (type) {
      case ActivityType.serviceBooked:
        return Icons.electric_moped_rounded;
      case ActivityType.tripStarted:
        return Icons.navigation_rounded;
      case ActivityType.workerArrived:
        return Icons.pin_drop_rounded;
      case ActivityType.otpVerified:
        return Icons.verified_rounded;
      case ActivityType.serviceCompleted:
        return Icons.task_alt_rounded;
      case ActivityType.statutoryContribution:
        return Icons.account_balance_wallet_rounded;
      case ActivityType.sosTriggered:
        return Icons.sos_rounded;
      case ActivityType.locationUpdated:
        return Icons.my_location_rounded;
      case ActivityType.kycAudited:
        return Icons.shield_rounded;
      case ActivityType.workerOnlineToggle:
        return Icons.sensors_rounded;
    }
  }

  Color _getColorForType(ActivityType type) {
    switch (type) {
      case ActivityType.serviceBooked:
        return AppColors.primaryBlueLight;
      case ActivityType.tripStarted:
        return Colors.indigoAccent;
      case ActivityType.workerArrived:
        return Colors.teal;
      case ActivityType.otpVerified:
        return AppColors.successGreenLight;
      case ActivityType.serviceCompleted:
        return AppColors.successGreenLight;
      case ActivityType.statutoryContribution:
        return AppColors.accentGoldLight;
      case ActivityType.sosTriggered:
        return AppColors.emergencyRedLight;
      case ActivityType.locationUpdated:
        return Colors.blue;
      case ActivityType.kycAudited:
        return Colors.purpleAccent;
      case ActivityType.workerOnlineToggle:
        return Colors.orangeAccent;
    }
  }

  void _showActivityDetailSheet(BuildContext context, AppActivity activity, bool isDark) {
    final formattedTime = DateFormat('MMMM d, yyyy • h:mm:ss a').format(activity.timestamp);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_getIconForType(activity.type), color: _getColorForType(activity.type)),
                    const SizedBox(width: 8),
                    Text(
                      'Activity Log Details',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              activity.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              activity.description,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _detailRow('User Role', activity.userRole.label),
                  _detailRow('User/Actor', activity.userName),
                  _detailRow('Recorded Address', activity.locationAddress),
                  if (activity.latitude != null && activity.longitude != null)
                    _detailRow(
                      'GPS Coordinates',
                      '${activity.latitude!.toStringAsFixed(5)}, ${activity.longitude!.toStringAsFixed(5)}',
                    ),
                  if (activity.ticketId != null) _detailRow('Associated Ticket', activity.ticketId!),
                  if (activity.amount != null)
                    _detailRow('Transaction Amount', '₹${activity.amount!.toStringAsFixed(2)}'),
                  _detailRow('Audit Status', activity.status),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, UserRole role) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Role History?'),
        content: Text(
          'This will remove activity entries for ${role.label}. Other roles will retain their logs.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(activityHistoryProvider.notifier).clearHistoryForRole(role);
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
