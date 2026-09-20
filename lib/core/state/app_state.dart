import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../services/mock_data_service.dart';

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

// Active Tickets management state
class ActiveTicketsNotifier extends Notifier<List<TicketRequest>> {
  Timer? _movementSimulationTimer;

  @override
  List<TicketRequest> build() {
    _startLocationSimulation();
    ref.onDispose(() {
      _movementSimulationTimer?.cancel();
    });
    return [MockDataService.createSampleActiveTicket()];
  }

  void createTicket({
    required GigService service,
    required String notes,
    required bool isEmergency,
    required String customerAddress,
  }) {
    final worker = MockDataService.getCooperativeWorkers().first;
    final newTicket = TicketRequest(
      id: 'TCK-2026-${DateTime.now().millisecondsSinceEpoch % 10000}',
      serviceName: service.name,
      category: service.category,
      customerName: 'Ananya Sharma',
      customerPhone: '+91 98711 02938',
      customerAddress: customerAddress.isNotEmpty
          ? customerAddress
          : 'Flat 402, Kaveri Apartments, Sector 4, Connaught Place, New Delhi',
      customerLat: 28.6290,
      customerLng: 77.2180,
      assignedWorker: worker,
      status: TicketStatus.enRoute,
      startOtp: '${(1000 + (DateTime.now().millisecond * 9) % 9000)}',
      requestedAt: DateTime.now(),
      estimatedArrivalMinutes: isEmergency ? 4 : 7,
      notes: notes.isNotEmpty ? notes : 'Immediate resolution requested.',
      isEmergency: isEmergency,
      fairPrice: FairPriceBreakdown.calculate(service.basePrice),
    );

    state = [newTicket, ...state];
  }

  void updateTicketStatus(String ticketId, TicketStatus newStatus) {
    state = state.map((ticket) {
      if (ticket.id == ticketId) {
        int arrival = ticket.estimatedArrivalMinutes;
        if (newStatus == TicketStatus.arrived) arrival = 0;
        if (newStatus == TicketStatus.completed) arrival = 0;
        return ticket.copyWith(status: newStatus, estimatedArrivalMinutes: arrival);
      }
      return ticket;
    }).toList();
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
