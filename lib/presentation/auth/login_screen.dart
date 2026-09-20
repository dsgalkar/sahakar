import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/sahakar_logo.dart';
import '../shell/app_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _phoneController = TextEditingController(text: '9876543210');
  final TextEditingController _otpController = TextEditingController(text: '4829');
  bool _otpSent = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  UserRole get _selectedRole {
    switch (_tabController.index) {
      case 0:
        return UserRole.user;
      case 1:
        return UserRole.gigWorker;
      case 2:
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  void _handleLogin() {
    // Set active role
    ref.read(currentRoleProvider.notifier).setRole(_selectedRole);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with logo
              const SizedBox(height: 12),
              Center(
                child: Hero(
                  tag: 'app_logo',
                  child: SahakarLogo(
                    size: 72,
                    showBadgeBorder: true,
                    isCompact: true,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'SAHAKAR',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: isDark ? Colors.white : AppColors.primaryBlue,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Instant Gig Support • Cooperative Network',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3 Role Tabs
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.person_rounded, size: 18),
                      text: 'User',
                    ),
                    Tab(
                      icon: Icon(Icons.handyman_rounded, size: 18),
                      text: 'Gig Worker',
                    ),
                    Tab(
                      icon: Icon(Icons.admin_panel_settings_rounded, size: 18),
                      text: 'Admin',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Role summary and permissions explanation card
              _buildRoleInfoCard(isDark),
              const SizedBox(height: 20),

              // Phone & OTP inputs
              Text(
                'Mobile Verification',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  prefixText: '+91 ',
                  hintText: 'Enter 10-digit mobile number',
                  suffixIcon: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('OTP 4829 sent successfully via SMS gateway'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text('Get OTP'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_clock_rounded),
                  hintText: 'Enter 4-digit OTP',
                ),
              ),
              const SizedBox(height: 20),

              // Login Button
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enter as ${_selectedRole.label}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Demo quick switcher for SIH presentations
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkCard : Colors.blue.shade50)
                      .withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : Colors.blue.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.speed_rounded,
                          size: 16,
                          color: isDark ? AppColors.accentGoldLight : AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Quick Evaluation Profiles (1-Tap Test):',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.accentGoldLight : AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickChip(
                            label: 'User Demo',
                            roleIndex: 0,
                            onTap: () {
                              _tabController.animateTo(0);
                              _handleLogin();
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildQuickChip(
                            label: 'Worker Demo',
                            roleIndex: 1,
                            onTap: () {
                              _tabController.animateTo(1);
                              _handleLogin();
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildQuickChip(
                            label: 'Admin Demo',
                            roleIndex: 2,
                            onTap: () {
                              _tabController.animateTo(2);
                              _handleLogin();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleInfoCard(bool isDark) {
    String title = '';
    String desc = '';
    String accessScope = '';
    IconData icon = Icons.info_outline;
    Color accentColor = AppColors.primaryBlue;

    switch (_tabController.index) {
      case 0:
        title = 'Customer / User Account';
        desc =
            'Book instant emergency gig support (Electrician, Plumber, Appliance) with verified cooperative society workers.';
        accessScope = '🔒 App View: User services & live worker en-route tracker only.';
        icon = Icons.home_repair_service_rounded;
        accentColor = AppColors.primaryBlueLight;
        break;
      case 1:
        title = 'Sahakar Sathi (Gig Worker)';
        desc =
            'Receive instant ticket alerts, active ₹5 accident insurance, e-Shram portable benefits & 88% direct wage share.';
        accessScope = '🔓 App View: User Services Tab + Gig Worker Portal Tab.';
        icon = Icons.engineering_rounded;
        accentColor = AppColors.accentGoldLight;
        break;
      case 2:
        title = 'Apex Federation & Society Admin';
        desc =
            'Oversee Social Security Fund compliance (Sec 114 Code on Social Security 2020), worker KYC approval & demand heatmaps.';
        accessScope = '👑 App View: Full 3-Tab Access (User, Gig Worker & Admin).';
        icon = Icons.account_balance_rounded;
        accentColor = AppColors.successGreenLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      accessScope,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required int roleIndex,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
