import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/sahakar_logo.dart';
import '../auth/login_screen.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/customer/customer_home.dart';
import '../features/customer/live_tracking_screen.dart';
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
    final tickets = ref.watch(activeTicketsProvider);
    final activeTicket = tickets.where((t) => t.status != TicketStatus.completed).firstOrNull;

    // Build the screens list based on current role permissions
    List<Widget> availableScreens = [];
    List<BottomNavigationBarItem> navItems = [];

    switch (currentRole) {
      case UserRole.user:
        // User only sees the user section
        availableScreens = [const CustomerHomeScreen()];
        navItems = []; // No bottom tabs needed for single user view
        break;

      case UserRole.gigWorker:
        // Gig worker sees User and Gig Worker tabs
        availableScreens = [
          const CustomerHomeScreen(),
          const WorkerDashboard(),
        ];
        navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service_rounded),
            label: 'User Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handyman_rounded),
            label: 'Gig Worker Portal',
          ),
        ];
        break;

      case UserRole.admin:
        // Admin can use all three tabs from home screen
        availableScreens = [
          const CustomerHomeScreen(),
          const WorkerDashboard(),
          const AdminDashboard(),
        ];
        navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service_rounded),
            label: 'User Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handyman_rounded),
            label: 'Gig Worker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_rounded),
            label: 'Admin Governance',
          ),
        ];
        break;
    }

    // Safety check for index out of bounds when switching roles
    if (_currentIndex >= availableScreens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        // Home page button to all screens via SahakarLogo
        title: SahakarLogo(
          size: 32,
          showBadgeBorder: false,
          isCompact: false,
          onTap: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),
        actions: [
          // Role Indicator Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.accentGoldLight : AppColors.primaryBlue)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (isDark ? AppColors.accentGoldLight : AppColors.primaryBlue)
                    .withOpacity(0.4),
              ),
            ),
            child: Text(
              currentRole.shortTag,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: isDark ? AppColors.accentGoldLight : AppColors.primaryBlue,
              ),
            ),
          ),

          // Quick Theme Toggle (Sun / Moon)
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? AppColors.accentGoldLight : AppColors.primaryBlue,
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),

          // Settings Icon in header
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings & Menu',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),

      // Adaptive Side Navigation Drawer with all proper required options
      drawer: _buildAppDrawer(context, ref, currentRole, activeTicket, isDark),

      // Role-based Screen View
      body: availableScreens[_currentIndex],

      // Role-based Bottom Navigation Bar
      bottomNavigationBar: navItems.isNotEmpty
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              items: navItems,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
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
  ) {
    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with SahakarLogo
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF132042), const Color(0xFF1E3A8A)]
                    : [AppColors.primaryBlue, const Color(0xFF2563EB)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SahakarLogo(
                  size: 54,
                  showBadgeBorder: true,
                  isCompact: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() => _currentIndex = 0);
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sahakar : Instant Gig Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Active Mode: ${currentRole.label}',
                  style: const TextStyle(
                    color: AppColors.accentGoldLight,
                    fontSize: 12,
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
            title: const Text('Logout / Switch Login Tab'),
            onTap: () {
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
