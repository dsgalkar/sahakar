enum UserRole {
  user,
  gigWorker,
  admin,
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.user:
        return 'Customer';
      case UserRole.gigWorker:
        return 'Gig Worker';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get shortTag {
    switch (this) {
      case UserRole.user:
        return 'USER';
      case UserRole.gigWorker:
        return 'WORKER';
      case UserRole.admin:
        return 'ADMIN';
    }
  }
}

enum TicketStatus {
  requested,
  matching,
  accepted,
  enRoute,
  arrived,
  inProgress,
  completed,
  cancelled,
}

extension TicketStatusExtension on TicketStatus {
  String get displayName {
    switch (this) {
      case TicketStatus.requested:
        return 'Ticket Raised';
      case TicketStatus.matching:
        return 'Matching Nearest Society Worker';
      case TicketStatus.accepted:
        return 'Worker Assigned';
      case TicketStatus.enRoute:
        return 'Worker En Route';
      case TicketStatus.arrived:
        return 'Worker Arrived';
      case TicketStatus.inProgress:
        return 'Job In Progress';
      case TicketStatus.completed:
        return 'Job Completed & Settled';
      case TicketStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class FairPriceBreakdown {
  final double workerWage; // 85-92%
  final double operationsFee; // 5-8%
  final double socialSecurityFund; // Statutory 1-2% under SS Code 2020 s.114
  final double total;

  const FairPriceBreakdown({
    required this.workerWage,
    required this.operationsFee,
    required this.socialSecurityFund,
    required this.total,
  });

  factory FairPriceBreakdown.calculate(double basePrice) {
    final worker = (basePrice * 0.88).roundToDouble();
    final ops = (basePrice * 0.07).roundToDouble();
    final ssFund = (basePrice * 0.05).roundToDouble();
    final sum = worker + ops + ssFund;
    return FairPriceBreakdown(
      workerWage: worker,
      operationsFee: ops,
      socialSecurityFund: ssFund,
      total: sum,
    );
  }
}

class GigService {
  final String id;
  final String name;
  final String category;
  final String description;
  final double basePrice;
  final int estMinutes;
  final String iconName;
  final String cooperativeSociety;

  const GigService({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.basePrice,
    required this.estMinutes,
    required this.iconName,
    required this.cooperativeSociety,
  });
}

class WorkerProfile {
  final String id;
  final String name;
  final String phone;
  final String trade;
  final int nsqfLevel; // Level 1 to 5 (NCCT / Skill India standard)
  final double rating;
  final int completedJobs;
  final String eShramUan;
  final bool isKycVerified;
  final String societyName;
  final String societyRegistrationNo;
  final double currentLat;
  final double currentLng;
  final String vehicleType;
  final bool activeInsuranceCover; // ₹5-10 per-job accident cover

  const WorkerProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.trade,
    required this.nsqfLevel,
    required this.rating,
    required this.completedJobs,
    required this.eShramUan,
    required this.isKycVerified,
    required this.societyName,
    required this.societyRegistrationNo,
    required this.currentLat,
    required this.currentLng,
    required this.vehicleType,
    required this.activeInsuranceCover,
  });

  WorkerProfile copyWith({
    double? currentLat,
    double? currentLng,
  }) {
    return WorkerProfile(
      id: id,
      name: name,
      phone: phone,
      trade: trade,
      nsqfLevel: nsqfLevel,
      rating: rating,
      completedJobs: completedJobs,
      eShramUan: eShramUan,
      isKycVerified: isKycVerified,
      societyName: societyName,
      societyRegistrationNo: societyRegistrationNo,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      vehicleType: vehicleType,
      activeInsuranceCover: activeInsuranceCover,
    );
  }
}

class TicketRequest {
  final String id;
  final String serviceName;
  final String category;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final double customerLat;
  final double customerLng;
  final WorkerProfile? assignedWorker;
  final TicketStatus status;
  final String startOtp;
  final DateTime requestedAt;
  final int estimatedArrivalMinutes;
  final String notes;
  final bool isEmergency;
  final FairPriceBreakdown fairPrice;

  const TicketRequest({
    required this.id,
    required this.serviceName,
    required this.category,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerLat,
    required this.customerLng,
    this.assignedWorker,
    required this.status,
    required this.startOtp,
    required this.requestedAt,
    required this.estimatedArrivalMinutes,
    required this.notes,
    required this.isEmergency,
    required this.fairPrice,
  });

  TicketRequest copyWith({
    WorkerProfile? assignedWorker,
    TicketStatus? status,
    int? estimatedArrivalMinutes,
  }) {
    return TicketRequest(
      id: id,
      serviceName: serviceName,
      category: category,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      customerLat: customerLat,
      customerLng: customerLng,
      assignedWorker: assignedWorker ?? this.assignedWorker,
      status: status ?? this.status,
      startOtp: startOtp,
      requestedAt: requestedAt,
      estimatedArrivalMinutes: estimatedArrivalMinutes ?? this.estimatedArrivalMinutes,
      notes: notes,
      isEmergency: isEmergency,
      fairPrice: fairPrice,
    );
  }
}
