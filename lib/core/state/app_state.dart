import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../services/location_service.dart';
import '../services/mock_data_service.dart';
import '../services/user_database_service.dart';

// Theme mode controller (Dark / Light)
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// Active user role controller (Customer, Gig Worker, Admin)
class CurrentRoleNotifier extends Notifier<UserRole> {
  @override
  UserRole build() => UserRole.user;

  void setRole(UserRole role) {
    state = role;
  }
}

final currentRoleProvider = NotifierProvider<CurrentRoleNotifier, UserRole>(CurrentRoleNotifier.new);

// Persistent Authenticated User Controller
class CurrentUserNotifier extends Notifier<AppUser> {
  @override
  AppUser build() {
    // Pre-initialize UserDatabaseService
    UserDatabaseService.init().then((_) {
      final saved = UserDatabaseService.getSavedSession();
      if (saved != null) {
        state = saved;
        ref.read(currentRoleProvider.notifier).setRole(saved.role);
      }
    });

    final cached = UserDatabaseService.getUserByPhone('9876543210');
    if (cached != null) return cached;

    return AppUser(
      id: 'USR-9876543210',
      phone: '9876543210',
      fullName: 'Ananya Sharma',
      email: 'ananya.sharma@sahakar.coop',
      role: UserRole.user,
      address: 'Chandrashekhar Agashe Road, Shaniwar Peth, Pune, Maharashtra 411001',
      latitude: 18.5211,
      longitude: 73.8502,
      registeredAt: DateTime.now(),
    );
  }

  Future<void> loginWithPhone({
    required String phone,
    required UserRole role,
  }) async {
    final user = await UserDatabaseService.authenticate(
      phone: phone,
      role: role,
      defaultAddress: ref.read(userLocationProvider).address,
      latitude: ref.read(userLocationProvider).latitude,
      longitude: ref.read(userLocationProvider).longitude,
    );
    state = user;
    ref.read(currentRoleProvider.notifier).setRole(user.role);
  }

  Future<void> register(AppUser newUser) async {
    final saved = await UserDatabaseService.registerUser(newUser);
    state = saved;
    ref.read(currentRoleProvider.notifier).setRole(saved.role);
  }

  void logout() {
    UserDatabaseService.clearSession();
  }
}

final currentUserProvider =
    NotifierProvider<CurrentUserNotifier, AppUser>(CurrentUserNotifier.new);

// User physical / device location controller
class UserLocationNotifier extends Notifier<UserLocation> {
  @override
  UserLocation build() {
    // Initial known fallback while live request resolves
    const initial = UserLocation(
      latitude: 18.5211,
      longitude: 73.8502,
      address: 'Chandrashekhar Agashe Road, Shaniwar Peth, Pune, Maharashtra 411001',
      city: 'Pune',
      state: 'Maharashtra',
      postalCode: '411001',
      isLive: true,
    );

    // Asynchronously resolve precise device/IP location
    _detectLocation();

    return initial;
  }

  Future<void> _detectLocation({bool forceRefresh = false}) async {
    try {
      final loc = await LocationService.fetchCurrentLocation(forceRefresh: forceRefresh);
      state = loc;

      // Automatically sync live coordinates with current user profile if on initial default
      final user = ref.read(currentUserProvider);
      if (user.address.contains('Chandrashekhar Agashe Road') || user.latitude == 18.5211) {
        ref.read(currentUserProvider.notifier).register(
          user.copyWith(
            address: loc.address,
            city: loc.city,
            state: loc.state,
            postalCode: loc.postalCode,
            latitude: loc.latitude,
            longitude: loc.longitude,
          ),
        );
      }
    } catch (_) {
      // Retain fallback
    }
  }

  Future<void> refreshLocation() async {
    await _detectLocation(forceRefresh: true);
    // Log location update activity
    ref.read(activityHistoryProvider.notifier).logActivity(
      AppActivity(
        id: 'LOC-${DateTime.now().millisecondsSinceEpoch % 100000}',
        userRole: ref.read(currentRoleProvider),
        userName: _getRoleUserName(ref.read(currentRoleProvider)),
        type: ActivityType.locationUpdated,
        title: 'Device GPS Location Updated',
        description: 'Physical position recalibrated to ${state.address}',
        timestamp: DateTime.now(),
        locationAddress: state.address,
        latitude: state.latitude,
        longitude: state.longitude,
        status: 'GPS Locked',
      ),
    );
  }
}

final userLocationProvider =
    NotifierProvider<UserLocationNotifier, UserLocation>(UserLocationNotifier.new);

// Selected Bhashini Language
class BhashiniLanguageNotifier extends Notifier<String> {
  @override
  String build() => 'en';

  void setLanguage(String code) {
    state = code;
  }
}

final bhashiniLanguageProvider =
    NotifierProvider<BhashiniLanguageNotifier, String>(BhashiniLanguageNotifier.new);

// Worker Online / Available status
class WorkerOnlineNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setStatus(bool online) {
    state = online;
    ref.read(activityHistoryProvider.notifier).logActivity(
      AppActivity(
        id: 'WRK-${DateTime.now().millisecondsSinceEpoch % 100000}',
        userRole: UserRole.gigWorker,
        userName: 'Aakash Verma (Worker)',
        type: ActivityType.workerOnlineToggle,
        title: online ? 'Worker Status: ONLINE' : 'Worker Status: OFFLINE',
        description: online
            ? 'Available to accept cooperative dispatch jobs in current zone.'
            : 'Turned off dispatch duty. Social Security tally preserved.',
        timestamp: DateTime.now(),
        locationAddress: ref.read(userLocationProvider).address,
        latitude: ref.read(userLocationProvider).latitude,
        longitude: ref.read(userLocationProvider).longitude,
        status: online ? 'Active' : 'Offline',
      ),
    );
  }
}

final workerOnlineStatusProvider =
    NotifierProvider<WorkerOnlineNotifier, bool>(WorkerOnlineNotifier.new);

// Selected ticket ID for live tracking
class SelectedTicketIdNotifier extends Notifier<String?> {
  @override
  String? build() => 'TCK-2026-9041';

  void selectTicket(String? id) {
    state = id;
  }
}

final selectedTicketIdProvider =
    NotifierProvider<SelectedTicketIdNotifier, String?>(SelectedTicketIdNotifier.new);

// Activity History Controller (Multi-User, Role-Aware, Persistent within session)
class ActivityHistoryNotifier extends Notifier<List<AppActivity>> {
  @override
  List<AppActivity> build() {
    final now = DateTime.now();
    return [
      // Current Customer Activity
      AppActivity(
        id: 'ACT-9041',
        userRole: UserRole.user,
        userName: 'Ananya Sharma',
        type: ActivityType.serviceBooked,
        title: 'Emergency Electrical Short-Circuit',
        description: 'Instant ticket raised with ₹249 fair transparent pricing (no surge).',
        timestamp: now.subtract(const Duration(minutes: 6)),
        locationAddress: 'Chandrashekhar Agashe Road, Shaniwar Peth, Pune, Maharashtra 411001',
        latitude: 18.5211,
        longitude: 73.8502,
        status: 'En Route',
        amount: 249.0,
        ticketId: 'TCK-2026-9041',
      ),
      // Worker Activity
      AppActivity(
        id: 'ACT-9040',
        userRole: UserRole.gigWorker,
        userName: 'Aakash Verma',
        type: ActivityType.tripStarted,
        title: 'Dispatched on Gig Wayfinding',
        description: 'En-route to Shaniwar Peth, Pune. Verified direct payout share ₹219.00 (88%).',
        timestamp: now.subtract(const Duration(minutes: 5)),
        locationAddress: 'Shaniwar Peth, Pune, Maharashtra',
        latitude: 18.5211,
        longitude: 73.8502,
        status: 'Dispatched',
        amount: 219.0,
        ticketId: 'TCK-2026-9041',
      ),
      // Statutory Social Security Contribution
      AppActivity(
        id: 'ACT-9039',
        userRole: UserRole.gigWorker,
        userName: 'Aakash Verma',
        type: ActivityType.statutoryContribution,
        title: 'Sec 114 Social Security Reserve Credited',
        description: '₹12.45 statutory platform turnover allocation escrowed for worker pension & medical fund.',
        timestamp: now.subtract(const Duration(hours: 3)),
        locationAddress: 'Pune Cooperative Cluster',
        latitude: 18.5204,
        longitude: 73.8567,
        status: 'Escrowed',
        amount: 12.45,
      ),
      // Customer Previous Job Completed
      AppActivity(
        id: 'ACT-9038',
        userRole: UserRole.user,
        userName: 'Ananya Sharma',
        type: ActivityType.serviceCompleted,
        title: 'Ceiling Fan & Capacitor Replacement',
        description: 'Service completed successfully. OTP verified and payment cleared without platform gouging.',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        locationAddress: 'Chandrashekhar Agashe Road, Shaniwar Peth, Pune',
        latitude: 18.5211,
        longitude: 73.8502,
        status: 'Completed',
        amount: 199.0,
      ),
      // Admin Audit
      AppActivity(
        id: 'ACT-9037',
        userRole: UserRole.admin,
        userName: 'Apex Cooperative Governance Officer',
        type: ActivityType.kycAudited,
        title: 'DigiLocker & e-Shram Batch Verification',
        description: 'Verified statutory compliance for 24 local technicians under Code on Social Security 2020.',
        timestamp: now.subtract(const Duration(days: 2)),
        locationAddress: 'Maharashtra State Cooperative Federation, Pune',
        latitude: 18.5300,
        longitude: 73.8470,
        status: 'Audit Approved',
      ),
    ];
  }

  void logActivity(AppActivity activity) {
    state = [activity, ...state];
  }

  void clearHistoryForRole(UserRole role) {
    state = state.where((act) => act.userRole != role).toList();
  }
}

final activityHistoryProvider =
    NotifierProvider<ActivityHistoryNotifier, List<AppActivity>>(ActivityHistoryNotifier.new);

// Active Tickets management state
class ActiveTicketsNotifier extends Notifier<List<TicketRequest>> {
  Timer? _movementSimulationTimer;

  @override
  List<TicketRequest> build() {
    _startLocationSimulation();
    ref.onDispose(() {
      _movementSimulationTimer?.cancel();
    });

    final initialLoc = ref.read(userLocationProvider);
    final worker = MockDataService.getCooperativeWorkers().first;
    final workerCoords = LocationService.generateNearbyWorkerCoords(
      initialLoc.latitude,
      initialLoc.longitude,
      seed: 42,
    );

    final initialTicket = TicketRequest(
      id: 'TCK-2026-9041',
      serviceName: 'Emergency Electrical Short-Circuit',
      category: 'Electrician',
      customerName: 'Ananya Sharma',
      customerPhone: '+91 98711 02938',
      customerAddress: initialLoc.address,
      customerLat: initialLoc.latitude,
      customerLng: initialLoc.longitude,
      assignedWorker: worker.copyWith(
        currentLat: workerCoords[0],
        currentLng: workerCoords[1],
      ),
      status: TicketStatus.enRoute,
      startOtp: '4829',
      requestedAt: DateTime.now().subtract(const Duration(minutes: 6)),
      estimatedArrivalMinutes: 5,
      notes: 'MCB tripping repeatedly in main circuit box.',
      isEmergency: true,
      fairPrice: FairPriceBreakdown.calculate(249.0),
    );

    return [initialTicket];
  }

  void createTicket({
    required GigService service,
    required String notes,
    required bool isEmergency,
    required String customerAddress,
    double? latitude,
    double? longitude,
  }) {
    final currentLoc = ref.read(userLocationProvider);
    final finalLat = latitude ?? currentLoc.latitude;
    final finalLng = longitude ?? currentLoc.longitude;
    final finalAddress = customerAddress.trim().isNotEmpty ? customerAddress : currentLoc.address;

    final worker = MockDataService.getCooperativeWorkers().first;
    final workerCoords = LocationService.generateNearbyWorkerCoords(
      finalLat,
      finalLng,
      seed: DateTime.now().millisecond,
    );

    final ticketId = 'TCK-2026-${DateTime.now().millisecondsSinceEpoch % 10000}';
    final breakdown = FairPriceBreakdown.calculate(service.basePrice);
    final otp = '${1000 + (DateTime.now().millisecond * 9) % 9000}';
    final currentUser = ref.read(currentUserProvider);
    final customerName = currentUser.fullName.isNotEmpty ? currentUser.fullName : 'Ananya Sharma';
    final customerPhone = '+91 ${currentUser.phone}';

    final newTicket = TicketRequest(
      id: ticketId,
      serviceName: service.name,
      category: service.category,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: finalAddress,
      customerLat: finalLat,
      customerLng: finalLng,
      assignedWorker: worker.copyWith(
        currentLat: workerCoords[0],
        currentLng: workerCoords[1],
      ),
      status: TicketStatus.enRoute,
      startOtp: otp,
      requestedAt: DateTime.now(),
      estimatedArrivalMinutes: isEmergency ? 4 : 7,
      notes: notes.isNotEmpty ? notes : 'Immediate assistance requested.',
      isEmergency: isEmergency,
      fairPrice: breakdown,
    );

    state = [newTicket, ...state];

    // Log Activity for Customer
    ref.read(activityHistoryProvider.notifier).logActivity(
      AppActivity(
        id: 'ACT-${DateTime.now().millisecondsSinceEpoch % 100000}',
        userRole: UserRole.user,
        userName: customerName,
        type: ActivityType.serviceBooked,
        title: '${service.name} Booked',
        description: 'Instant ticket $ticketId raised. Worker ${worker.name} dispatched with OTP $otp.',
        timestamp: DateTime.now(),
        locationAddress: finalAddress,
        latitude: finalLat,
        longitude: finalLng,
        status: 'En Route',
        amount: breakdown.total,
        ticketId: ticketId,
      ),
    );

    // Log Activity for Worker
    ref.read(activityHistoryProvider.notifier).logActivity(
      AppActivity(
        id: 'ACT-${(DateTime.now().millisecondsSinceEpoch + 1) % 100000}',
        userRole: UserRole.gigWorker,
        userName: worker.name,
        type: ActivityType.tripStarted,
        title: 'Assigned Gig: ${service.name}',
        description: 'New service order accepted for $finalAddress. Guaranteed pass-through: ₹${breakdown.workerWage.toStringAsFixed(0)}.',
        timestamp: DateTime.now(),
        locationAddress: finalAddress,
        latitude: finalLat,
        longitude: finalLng,
        status: 'Dispatched',
        amount: breakdown.workerWage,
        ticketId: ticketId,
      ),
    );
  }

  void updateTicketStatus(String ticketId, TicketStatus newStatus) {
    state = state.map((ticket) {
      if (ticket.id == ticketId) {
        int arrival = ticket.estimatedArrivalMinutes;
        if (newStatus == TicketStatus.arrived) arrival = 0;
        if (newStatus == TicketStatus.completed) arrival = 0;

        // Log corresponding activity
        _logStatusActivity(ticket, newStatus);

        return ticket.copyWith(status: newStatus, estimatedArrivalMinutes: arrival);
      }
      return ticket;
    }).toList();
  }

  void _logStatusActivity(TicketRequest ticket, TicketStatus status) {
    final now = DateTime.now();
    final history = ref.read(activityHistoryProvider.notifier);

    switch (status) {
      case TicketStatus.arrived:
        history.logActivity(
          AppActivity(
            id: 'ACT-${now.millisecondsSinceEpoch % 100000}',
            userRole: UserRole.gigWorker,
            userName: ticket.assignedWorker?.name ?? 'Worker',
            type: ActivityType.workerArrived,
            title: 'Worker Arrived Outside Customer Location',
            description: 'Reached ${ticket.customerAddress}. Awaiting Customer OTP verification.',
            timestamp: now,
            locationAddress: ticket.customerAddress,
            latitude: ticket.customerLat,
            longitude: ticket.customerLng,
            status: 'Arrived',
            ticketId: ticket.id,
          ),
        );
        break;

      case TicketStatus.inProgress:
        history.logActivity(
          AppActivity(
            id: 'ACT-${now.millisecondsSinceEpoch % 100000}',
            userRole: UserRole.gigWorker,
            userName: ticket.assignedWorker?.name ?? 'Worker',
            type: ActivityType.otpVerified,
            title: 'OTP Verified & Job Started',
            description: 'Customer verified OTP (${ticket.startOtp}). Service work is active.',
            timestamp: now,
            locationAddress: ticket.customerAddress,
            latitude: ticket.customerLat,
            longitude: ticket.customerLng,
            status: 'In Progress',
            ticketId: ticket.id,
          ),
        );
        break;

      case TicketStatus.completed:
        history.logActivity(
          AppActivity(
            id: 'ACT-${now.millisecondsSinceEpoch % 100000}',
            userRole: UserRole.user,
            userName: ticket.customerName,
            type: ActivityType.serviceCompleted,
            title: 'Job Completed & Settled: ${ticket.serviceName}',
            description: 'Service completed. ₹${ticket.fairPrice.total.toStringAsFixed(0)} settled directly to cooperative wallet.',
            timestamp: now,
            locationAddress: ticket.customerAddress,
            latitude: ticket.customerLat,
            longitude: ticket.customerLng,
            status: 'Settled',
            amount: ticket.fairPrice.total,
            ticketId: ticket.id,
          ),
        );

        // Social security fund statutory entry
        history.logActivity(
          AppActivity(
            id: 'ACT-${(now.millisecondsSinceEpoch + 1) % 100000}',
            userRole: UserRole.gigWorker,
            userName: ticket.assignedWorker?.name ?? 'Worker',
            type: ActivityType.statutoryContribution,
            title: 'Statutory Social Security Fund Allocated',
            description: '₹${ticket.fairPrice.socialSecurityFund.toStringAsFixed(0)} credited to worker welfare fund under Sec 114 Code on Social Security 2020.',
            timestamp: now,
            locationAddress: ticket.customerAddress,
            latitude: ticket.customerLat,
            longitude: ticket.customerLng,
            status: 'Statutory Escrow',
            amount: ticket.fairPrice.socialSecurityFund,
            ticketId: ticket.id,
          ),
        );
        break;

      default:
        break;
    }
  }

  void logSosAlert({required String ticketId, required String note}) {
    final ticket = state.firstWhere((t) => t.id == ticketId, orElse: () => state.first);
    final now = DateTime.now();

    ref.read(activityHistoryProvider.notifier).logActivity(
      AppActivity(
        id: 'SOS-${now.millisecondsSinceEpoch % 100000}',
        userRole: UserRole.user,
        userName: ticket.customerName,
        type: ActivityType.sosTriggered,
        title: 'EMERGENCY SOS ALERT BROADCAST',
        description: 'SOS Beacon triggered at exact GPS coordinates (${ticket.customerLat.toStringAsFixed(4)}, ${ticket.customerLng.toStringAsFixed(4)}). Dispatch and nearest cooperative patrol alerted: $note',
        timestamp: now,
        locationAddress: ticket.customerAddress,
        latitude: ticket.customerLat,
        longitude: ticket.customerLng,
        status: 'EMERGENCY',
        ticketId: ticket.id,
      ),
    );
  }

  void _startLocationSimulation() {
    _movementSimulationTimer?.cancel();
    _movementSimulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      state = state.map((ticket) {
        if (ticket.status == TicketStatus.enRoute && ticket.assignedWorker != null) {
          final worker = ticket.assignedWorker!;
          final targetLat = ticket.customerLat;
          final targetLng = ticket.customerLng;

          // Interpolate coordinate closer to user
          final dLat = (targetLat - worker.currentLat) * 0.15;
          final dLng = (targetLng - worker.currentLng) * 0.15;
          final newLat = worker.currentLat + dLat;
          final newLng = worker.currentLng + dLng;

          final newEta = (ticket.estimatedArrivalMinutes > 1)
              ? ticket.estimatedArrivalMinutes - 1
              : 1;

          return ticket.copyWith(
            assignedWorker: worker.copyWith(currentLat: newLat, currentLng: newLng),
            estimatedArrivalMinutes: newEta,
          );
        }
        return ticket;
      }).toList();
    });
  }
}

final activeTicketsProvider =
    NotifierProvider<ActiveTicketsNotifier, List<TicketRequest>>(ActiveTicketsNotifier.new);

// Currently selected ticket instance
final activeTrackedTicketProvider = Provider<TicketRequest?>((ref) {
  final tickets = ref.watch(activeTicketsProvider);
  final id = ref.watch(selectedTicketIdProvider);
  if (id == null) return tickets.isNotEmpty ? tickets.first : null;
  return tickets.firstWhere(
    (t) => t.id == id,
    orElse: () => tickets.isNotEmpty ? tickets.first : MockDataService.createSampleActiveTicket(),
  );
});

String _getRoleUserName(UserRole role) {
  switch (role) {
    case UserRole.user:
      return 'Ananya Sharma';
    case UserRole.gigWorker:
      return 'Aakash Verma';
    case UserRole.admin:
      return 'Apex Governance Admin';
  }
}
