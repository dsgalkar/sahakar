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

class UserLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final bool isLive;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    this.isLive = true,
  });

  String get shortLabel {
    if (city.isNotEmpty && state.isNotEmpty) {
      return '$city, $state';
    }
    return address.isNotEmpty ? address : '$latitude, $longitude';
  }

  UserLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    bool? isLive,
  }) {
    return UserLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      isLive: isLive ?? this.isLive,
    );
  }
}

enum ActivityType {
  serviceBooked,
  tripStarted,
  workerArrived,
  otpVerified,
  serviceCompleted,
  statutoryContribution,
  sosTriggered,
  locationUpdated,
  kycAudited,
  workerOnlineToggle,
}

class AppActivity {
  final String id;
  final UserRole userRole;
  final String userName;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String locationAddress;
  final double? latitude;
  final double? longitude;
  final String status;
  final double? amount;
  final String? ticketId;
  final Map<String, dynamic>? metadata;

  const AppActivity({
    required this.id,
    required this.userRole,
    required this.userName,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.locationAddress,
    this.latitude,
    this.longitude,
    required this.status,
    this.amount,
    this.ticketId,
    this.metadata,
  });
}

class AppUser {
  final String id;
  final String phone;
  final String fullName;
  final String email;
  final UserRole role;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final DateTime registeredAt;

  // Worker specific fields
  final String? trade;
  final String? eShramUan;
  final String? societyName;
  final int? nsqfLevel;
  final double? rating;
  final int? completedJobs;
  final bool isVerified;

  // Admin specific fields
  final String? designation;
  final String? jurisdictionCircle;

  const AppUser({
    required this.id,
    required this.phone,
    required this.fullName,
    this.email = '',
    required this.role,
    required this.address,
    this.city = 'Pune',
    this.state = 'Maharashtra',
    this.postalCode = '411001',
    required this.latitude,
    required this.longitude,
    required this.registeredAt,
    this.trade,
    this.eShramUan,
    this.societyName,
    this.nsqfLevel,
    this.rating,
    this.completedJobs,
    this.isVerified = true,
    this.designation,
    this.jurisdictionCircle,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'fullName': fullName,
      'email': email,
      'role': role.index,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'registeredAt': registeredAt.toIso8601String(),
      'trade': trade,
      'eShramUan': eShramUan,
      'societyName': societyName,
      'nsqfLevel': nsqfLevel,
      'rating': rating,
      'completedJobs': completedJobs,
      'isVerified': isVerified,
      'designation': designation,
      'jurisdictionCircle': jurisdictionCircle,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      phone: json['phone'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String? ?? '',
      role: UserRole.values[json['role'] as int],
      address: json['address'] as String,
      city: json['city'] as String? ?? 'Pune',
      state: json['state'] as String? ?? 'Maharashtra',
      postalCode: json['postalCode'] as String? ?? '411001',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      trade: json['trade'] as String?,
      eShramUan: json['eShramUan'] as String?,
      societyName: json['societyName'] as String?,
      nsqfLevel: json['nsqfLevel'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      completedJobs: json['completedJobs'] as int?,
      isVerified: json['isVerified'] as bool? ?? true,
      designation: json['designation'] as String?,
      jurisdictionCircle: json['jurisdictionCircle'] as String?,
    );
  }

  AppUser copyWith({
    String? fullName,
    String? email,
    UserRole? role,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? trade,
    String? eShramUan,
    String? societyName,
    int? nsqfLevel,
    double? rating,
    int? completedJobs,
    bool? isVerified,
    String? designation,
    String? jurisdictionCircle,
  }) {
    return AppUser(
      id: id,
      phone: phone,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      registeredAt: registeredAt,
      trade: trade ?? this.trade,
      eShramUan: eShramUan ?? this.eShramUan,
      societyName: societyName ?? this.societyName,
      nsqfLevel: nsqfLevel ?? this.nsqfLevel,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      isVerified: isVerified ?? this.isVerified,
      designation: designation ?? this.designation,
      jurisdictionCircle: jurisdictionCircle ?? this.jurisdictionCircle,
    );
  }
}
