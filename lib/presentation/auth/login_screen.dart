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
              const SizedBox(height: 12),

              // Create Account Button
              OutlinedButton.icon(
                onPressed: () => _showCreateAccountModal(context, isDark),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: Text(
                  'Create New ${_selectedRole.label} Account',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(
                    color: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Secondary Quick Text Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "New to Sahakar? ",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showCreateAccountModal(context, isDark),
                    child: Text(
                      'Register Here',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.accentGoldLight : AppColors.primaryBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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

  void _showCreateAccountModal(BuildContext context, bool isDark) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: _phoneController.text);
    final userLocation = ref.read(userLocationProvider);
    final addressCtrl = TextEditingController(text: userLocation.address);
    final tradeCtrl = TextEditingController(text: 'Certified Electrician');
    final uanCtrl = TextEditingController(text: '1009-8834-5512');
    final societyCtrl = TextEditingController(text: 'Maharashtra Shramik Sahakari Sanstha');
    final designationCtrl = TextEditingController(text: 'District Cooperative Registrar');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primaryBlueLight),
                        const SizedBox(width: 8),
                        Text(
                          'Create ${_selectedRole.label} Account',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
                  _selectedRole == UserRole.user
                      ? 'Register for transparent, fair-wage instant gig support with statutory protection.'
                      : _selectedRole == UserRole.gigWorker
                          ? 'Join the national cooperative network with 88% direct wage pass-through & e-Shram benefits.'
                          : 'Register as a statutory monitoring and governance administrator.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Name Input
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Legal Name',
                    prefixIcon: Icon(Icons.badge_rounded),
                    hintText: 'Enter your full name',
                  ),
                ),
                const SizedBox(height: 12),

                // Phone Input
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    prefixIcon: Icon(Icons.phone_android_rounded),
                    prefixText: '+91 ',
                  ),
                ),
                const SizedBox(height: 12),

                // Role-Specific Fields
                if (_selectedRole == UserRole.user) ...[
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Primary Address (Live Location Prefilled)',
                      prefixIcon: Icon(Icons.location_on_rounded),
                    ),
                  ),
                ] else if (_selectedRole == UserRole.gigWorker) ...[
                  TextField(
                    controller: tradeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Primary Trade & Skill',
                      prefixIcon: Icon(Icons.construction_rounded),
                      hintText: 'Electrician, Plumber, Carpenter...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: uanCtrl,
                    decoration: const InputDecoration(
                      labelText: 'e-Shram UAN / DigiLocker ID',
                      prefixIcon: Icon(Icons.verified_user_rounded),
                      hintText: '12-digit e-Shram UAN',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: societyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Endorsing Cooperative Society',
                      prefixIcon: Icon(Icons.apartment_rounded),
                    ),
                  ),
                ] else if (_selectedRole == UserRole.admin) ...[
                  TextField(
                    controller: designationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Administrative Designation',
                      prefixIcon: Icon(Icons.shield_rounded),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Statutory notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkSurface : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded, size: 16, color: AppColors.successGreenLight),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Protected under Code on Social Security 2020. Data safeguarded by cooperative federations.',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    final registeredName = nameCtrl.text.trim().isNotEmpty
                        ? nameCtrl.text.trim()
                        : (_selectedRole == UserRole.user
                            ? 'Ananya Sharma'
                            : _selectedRole == UserRole.gigWorker
                                ? 'Aakash Verma'
                                : 'Cooperative Governance Officer');

                    ref.read(currentRoleProvider.notifier).setRole(_selectedRole);

                    // Log registration activity
                    ref.read(activityHistoryProvider.notifier).logActivity(
                          AppActivity(
                            id: 'REG-${DateTime.now().millisecondsSinceEpoch % 100000}',
                            userRole: _selectedRole,
                            userName: registeredName,
                            type: ActivityType.kycAudited,
                            title: 'Account Created & Registered',
                            description:
                                'New ${_selectedRole.label} account created with verified cooperative credentials.',
                            timestamp: DateTime.now(),
                            locationAddress: userLocation.address,
                            latitude: userLocation.latitude,
                            longitude: userLocation.longitude,
                            status: 'Verified',
                          ),
                        );

                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.successGreen,
                        content: Text('🎉 Welcome $registeredName! Account created successfully.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const AppShell()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                  ),
                  child: Text(
                    'Complete Registration as ${_selectedRole.label}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
