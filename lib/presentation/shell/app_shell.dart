import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/creative_avatar.dart';
import '../../core/widgets/futuristic_widgets.dart';
import '../../core/widgets/sahakar_logo.dart';
import '../auth/login_screen.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/customer/customer_home.dart';
import '../features/customer/live_tracking_screen.dart';
import '../features/history/activity_history_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/worker/worker_dashboard.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentRole = ref.watch(currentRoleProvider);
    final currentUser = ref.watch(currentUserProvider);
    final tickets = ref.watch(activeTicketsProvider);
    final activeTicket = tickets.where((t) => t.status != TicketStatus.completed).firstOrNull;

    // Build the screens list based on current role permissions
    List<Widget> availableScreens = [];
    List<BottomNavigationBarItem> navItems = [];

    switch (currentRole) {
      case UserRole.user:
        availableScreens = [
          const CustomerHomeScreen(),
          const ActivityHistoryScreen(),
        ];
        navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.hub_rounded),
            activeIcon: Icon(Icons.hub_rounded, color: AppColors.neonCyan),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            activeIcon: Icon(Icons.receipt_long_rounded, color: AppColors.neonCyan),
            label: 'Telemetry History',
          ),
        ];
        break;

      case UserRole.gigWorker:
        availableScreens = [
          const CustomerHomeScreen(),
          const WorkerDashboard(),
          const ActivityHistoryScreen(),
        ];
        navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.hub_rounded),
            activeIcon: Icon(Icons.hub_rounded, color: AppColors.neonCyan),
            label: 'Client View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt_rounded),
            activeIcon: Icon(Icons.bolt_rounded, color: AppColors.neonGold),
            label: 'KarmaYogi Grid',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            activeIcon: Icon(Icons.receipt_long_rounded, color: AppColors.neonCyan),
            label: 'History',
          ),
        ];
        break;

      case UserRole.admin:
        availableScreens = [
          const CustomerHomeScreen(),
          const WorkerDashboard(),
          const AdminDashboard(),
          const ActivityHistoryScreen(),
        ];
        navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.hub_rounded),
            activeIcon: Icon(Icons.hub_rounded, color: AppColors.neonCyan),
            label: 'Client View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt_rounded),
            activeIcon: Icon(Icons.bolt_rounded, color: AppColors.neonGold),
            label: 'Workers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_rounded),
            activeIcon: Icon(Icons.shield_rounded, color: AppColors.neonPurple),
            label: 'Trustee Ledger',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            activeIcon: Icon(Icons.receipt_long_rounded, color: AppColors.neonCyan),
            label: 'Audit History',
          ),
        ];
        break;
    }

    if (_currentIndex >= availableScreens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: SahakarLogo(
          size: 34,
          showBadgeBorder: false,
          isCompact: false,
          onTap: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),
        actions: [
          // Futuristic Neon Role Pill
          NeonPill(
            text: currentRole.shortTag,
            color: currentRole == UserRole.admin
                ? AppColors.neonPurple
                : (currentRole == UserRole.gigWorker
                    ? AppColors.neonGold
                    : AppColors.neonCyan),
            isFilled: true,
          ),
          const SizedBox(width: 6),

          // Quick Theme Toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? AppColors.neonGold : AppColors.lightTextPrimary,
              size: 20,
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),

          // Creative User Avatar in Header (Clickable to Settings)
          Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 2.0),
            child: CreativeAvatar(
              size: 36,
              role: currentRole,
              tradeName: currentUser.trade,
              name: currentUser.fullName,
              isOnline: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ),
        ],
      ),

      drawer: _buildAppDrawer(context, ref, currentRole, activeTicket, isDark, availableScreens.length - 1),
      body: availableScreens[_currentIndex],

      bottomNavigationBar: navItems.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                items: navItems,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            )
          : null,
    );
  }

  Widget _buildAppDrawer(
    BuildContext context,
    WidgetRef ref,
    UserRole currentRole,
    TicketRequest? activeTicket,
    bool isDark,
    int historyIndex,
  ) {
    final currentUser = ref.watch(currentUserProvider);

    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with CreativeAvatar and User Info
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.cyberPurpleGradient : AppColors.cyberCyanGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CreativeAvatar(
                      size: 50,
                      role: currentRole,
                      tradeName: currentUser.trade,
                      name: currentUser.fullName,
                      isOnline: true,
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() => _currentIndex = 0);
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentUser.role.shortTag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  currentUser.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${currentUser.role.label} • +91 ${currentUser.phone}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Role Switcher Section (Demo friendly)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'SWITCH ROLE (DEMO)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          RadioListTile<UserRole>(
            dense: true,
            title: const Text('Customer / User (User section only)'),
            value: UserRole.user,
            groupValue: currentRole,
            onChanged: (role) {
              if (role != null) {
                ref.read(currentRoleProvider.notifier).setRole(role);
                setState(() => _currentIndex = 0);
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<UserRole>(
            dense: true,
            title: const Text('Gig Worker (User + Worker tabs)'),
            value: UserRole.gigWorker,
            groupValue: currentRole,
            onChanged: (role) {
              if (role != null) {
                ref.read(currentRoleProvider.notifier).setRole(role);
                setState(() => _currentIndex = 1);
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<UserRole>(
            dense: true,
            title: const Text('Admin (All 3 tabs: User, Worker, Admin)'),
            value: UserRole.admin,
            groupValue: currentRole,
            onChanged: (role) {
              if (role != null) {
                ref.read(currentRoleProvider.notifier).setRole(role);
                setState(() => _currentIndex = 2);
                Navigator.of(context).pop();
              }
            },
          ),
          const Divider(),

          // Navigation Links
          ListTile(
            leading: const Icon(Icons.home_repair_service_rounded),
            title: const Text('Browse Gig Services'),
            onTap: () {
              Navigator.of(context).pop();
              setState(() => _currentIndex = 0);
            },
          ),

          if (activeTicket != null)
            ListTile(
              leading: const Icon(Icons.navigation_rounded, color: AppColors.successGreenLight),
              title: const Text('Live Worker Wayfinding Track'),
              subtitle: Text('${activeTicket.serviceName} • ~${activeTicket.estimatedArrivalMinutes} min'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LiveTrackingScreen(ticketId: activeTicket.id),
                  ),
                );
              },
            ),

          ListTile(
            leading: const Icon(Icons.history_rounded, color: AppColors.primaryBlueLight),
            title: const Text('Activity & Audit History'),
            subtitle: const Text('View recorded logs, GPS breadcrumbs & receipts'),
            onTap: () {
              Navigator.of(context).pop();
              setState(() => _currentIndex = historyIndex);
            },
          ),

          ListTile(
            leading: const Icon(Icons.gavel_rounded, color: AppColors.accentGoldLight),
            title: const Text('Code on Social Security 2020'),
            subtitle: const Text('Statutory compliance & Section 114 details'),
            onTap: () {
              Navigator.of(context).pop();
              _showStatutoryModal(context);
            },
          ),

          // Settings item in menu with settings icon
          ListTile(
            leading: const Icon(Icons.settings_rounded, color: AppColors.primaryBlueLight),
            title: const Text('Settings & Preferences'),
            subtitle: const Text('Theme, Bhashini languages, DigiLocker, SOS'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.emergencyRedLight),
            title: const Text('Logout / Switch Account'),
            subtitle: Text('Signed in as ${currentUser.fullName}'),
            onTap: () {
              ref.read(currentUserProvider.notifier).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showStatutoryModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Code on Social Security 2020'),
        content: const Text(
          'Enforced on 21 Nov 2025. Sahakar is architected as the compliance-ready cooperative aggregator:\n\n'
          '• 1-2% platform turnover contributed to the statutory Social Security Fund.\n'
          '• Portable Aadhaar-linked e-Shram registration for every member.\n'
          '• Fair 88% direct wage pass-through with no surge price gouging.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
