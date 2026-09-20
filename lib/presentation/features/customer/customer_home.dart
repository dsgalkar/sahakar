import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import 'live_tracking_screen.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  String _selectedCategory = 'All';
  bool _isEmergencyMode = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Electrician',
    'Plumber',
    'Appliance',
    'Caregiver',
    'Cleaning',
    'Carpenter',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allServices = MockDataService.getAvailableServices();
    final tickets = ref.watch(activeTicketsProvider);
    final activeTicket = tickets.where((t) => t.status != TicketStatus.completed).firstOrNull;

    final filteredServices = allServices.where((s) {
      final matchesCategory = _selectedCategory == 'All' || s.category == _selectedCategory;
      final matchesSearch = _searchController.text.isEmpty ||
          s.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          s.category.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final currentUser = ref.watch(currentUserProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personalized Member Greeting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Namaste, ${currentUser.fullName} 🙏',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cooperative member • +91 ${currentUser.phone}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreenLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.successGreenLight.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, size: 14, color: AppColors.successGreenLight),
                    SizedBox(width: 4),
                    Text(
                      'VERIFIED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.successGreenLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Live Device Location Status Card (Real GPS / Physical Address)
          _buildLiveLocationCard(context, ref, isDark),
          const SizedBox(height: 14),

          // Active Ticket Notification Banner (Links directly to live tracking!)
          if (activeTicket != null) ...[
            _buildActiveTicketBanner(context, activeTicket, isDark),
            const SizedBox(height: 16),
          ],

          // Emergency Switch Banner
          _buildEmergencyHeader(isDark),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search emergency services (wiring, pipe burst, AC)...',
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
            ),
          ),
          const SizedBox(height: 16),

          // Category Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    }
                  },
                  selectedColor: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Services Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Cooperative Gigs (${filteredServices.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              Text(
                'Fair Price Guarantee',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Services Grid/List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredServices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = filteredServices[index];
              return _buildServiceCard(context, service, isDark);
            },
          ),

          const SizedBox(height: 24),

          // Co-op Statutory Social Security Transparency Card
          _buildStatutoryTransparencyCard(isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActiveTicketBanner(
      BuildContext context, TicketRequest ticket, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF132D5E), const Color(0xFF1A3870)]
              : [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlueLight.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.successGreenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          ticket.serviceName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlueLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ETA ~${ticket.estimatedArrivalMinutes} MIN',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Worker: ${ticket.assignedWorker?.name ?? "Assigned"} (${ticket.assignedWorker?.societyName ?? "Cooperative"})',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LiveTrackingScreen(ticketId: ticket.id),
                ),
              );
            },
            icon: const Icon(Icons.map_rounded, size: 18),
            label: const Text('TRACK GIG WORKER LIVE ON MAP'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlueLight,
              minimumSize: const Size.fromHeight(40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isEmergencyMode
            ? (isDark ? const Color(0xFF3B1214) : Colors.red.shade50)
            : (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEmergencyMode
              ? AppColors.emergencyRedLight
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: _isEmergencyMode ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (_isEmergencyMode ? AppColors.emergencyRed : AppColors.accentGold)
                  .withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isEmergencyMode ? Icons.warning_rounded : Icons.flash_on_rounded,
              color: _isEmergencyMode ? AppColors.emergencyRedLight : AppColors.accentGold,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEmergencyMode ? 'EMERGENCY MODE ACTIVE' : 'Instant Priority Dispatch',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _isEmergencyMode
                        ? AppColors.emergencyRedLight
                        : (isDark ? Colors.white : AppColors.lightTextPrimary),
                  ),
                ),
                Text(
                  _isEmergencyMode
                      ? 'Guaranteed <5 min worker matching SLA'
                      : 'Toggle for instant breakdown & short circuit support',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isEmergencyMode,
            activeColor: AppColors.emergencyRedLight,
            onChanged: (val) {
              setState(() {
                _isEmergencyMode = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, GigService service, bool isDark) {
    IconData iconData = Icons.construction_rounded;
    switch (service.category) {
      case 'Electrician':
        iconData = Icons.bolt_rounded;
        break;
      case 'Plumber':
        iconData = Icons.water_drop_rounded;
        break;
      case 'Appliance':
        iconData = Icons.ac_unit_rounded;
        break;
      case 'Caregiver':
        iconData = Icons.elderly_rounded;
        break;
      case 'Cleaning':
        iconData = Icons.cleaning_services_rounded;
        break;
      case 'Carpenter':
        iconData = Icons.handyman_rounded;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLight.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: AppColors.primaryBlueLight, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.apartment_rounded,
                            size: 13,
                            color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              service.cooperativeSociety,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${service.basePrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.primaryBlue,
                      ),
                    ),
                    Text(
                      '~${service.estMinutes} mins',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              service.description,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreenLight.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_rounded, size: 13, color: AppColors.successGreenLight),
                      SizedBox(width: 4),
                      Text(
                        '88% Direct Worker Wage',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.successGreenLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _showBookingModal(context, service),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Book Instant Gig'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingModal(BuildContext context, GigService service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final breakdown = FairPriceBreakdown.calculate(service.basePrice);
    final currentLoc = ref.read(userLocationProvider);
    final addressCtrl = TextEditingController(text: currentLoc.address);
    final noteCtrl = TextEditingController();

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confirm Gig Booking',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(),
              Text(
                service.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Text(
                'Endorsed by: ${service.cooperativeSociety}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  prefixIcon: Icon(Icons.location_on_rounded),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Specific issue notes (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Fair Price Breakdown table
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkSurface : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _priceRow('Base Service Wage (To Member Worker 88%)', '₹${breakdown.workerWage.toStringAsFixed(0)}'),
                    _priceRow('Co-op Operations & Platform Maintenance (7%)', '₹${breakdown.operationsFee.toStringAsFixed(0)}'),
                    _priceRow('Statutory Social Security Fund (Sec 114)', '₹${breakdown.socialSecurityFund.toStringAsFixed(0)}'),
                    const Divider(height: 16),
                    _priceRow('Total Payable (No Surge Surcharge)', '₹${breakdown.total.toStringAsFixed(0)}', isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  ref.read(activeTicketsProvider.notifier).createTicket(
                        service: service,
                        notes: noteCtrl.text,
                        isEmergency: _isEmergencyMode,
                        customerAddress: addressCtrl.text,
                        latitude: currentLoc.latitude,
                        longitude: currentLoc.longitude,
                      );
                  Navigator.of(ctx).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.successGreen,
                      content: Text('🎉 Instant Ticket Raised! Worker dispatched en-route.'),
                    ),
                  );

                  // Open live tracking screen immediately!
                  final tickets = ref.read(activeTicketsProvider);
                  if (tickets.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LiveTrackingScreen(ticketId: tickets.first.id),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.primaryBlueLight,
                ),
                child: const Text('DISPATCH NEAREST CO-OP WORKER'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold ? AppColors.accentGoldLight : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatutoryTransparencyCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const Row(
            children: [
              Icon(Icons.gavel_rounded, size: 18, color: AppColors.accentGoldLight),
              SizedBox(width: 8),
              Text(
                'Statutory Compliance & Fair Practice',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unlike private aggregators taking 25-30% commissions, Sahakar operates under the Code on Social Security 2020 (in force 21 Nov 2025). Workers retain 88% of earnings with statutory accident insurance and e-Shram portability.',
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

  Widget _buildLiveLocationCard(BuildContext context, WidgetRef ref, bool isDark) {
    final userLocation = ref.watch(userLocationProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue).withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLight.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: AppColors.primaryBlueLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'CURRENT DEVICE LOCATION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.primaryBlueLight,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successGreenLight.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LIVE GPS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.successGreenLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  userLocation.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${userLocation.latitude.toStringAsFixed(4)}, ${userLocation.longitude.toStringAsFixed(4)} • Local Circle Active',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Recalibrate Live GPS Location',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Detecting physical device coordinates...'),
                  duration: Duration(seconds: 1),
                ),
              );
              await ref.read(userLocationProvider.notifier).refreshLocation();
            },
          ),
        ],
      ),
    );
  }
}
