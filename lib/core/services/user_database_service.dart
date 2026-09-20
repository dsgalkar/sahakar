import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class UserDatabaseService {
  static const String _usersKey = 'sahakar_users_db_v1';
  static const String _sessionKey = 'sahakar_active_session_phone';

  static SharedPreferences? _prefs;
  static final Map<String, AppUser> _usersCache = {};
  static bool _initialized = false;

  /// Initialize the user database and pre-seed initial role accounts
  static Future<void> init() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      final rawData = _prefs?.getString(_usersKey);

      if (rawData != null && rawData.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(rawData);
        for (final item in jsonList) {
          final user = AppUser.fromJson(item as Map<String, dynamic>);
          _usersCache[user.phone] = user;
        }
      } else {
        _seedDefaultUsers();
        await _persistUsers();
      }
    } catch (_) {
      // In case of platform channel delay or storage exception on web
      if (_usersCache.isEmpty) {
        _seedDefaultUsers();
      }
    }

    _initialized = true;
  }

  static void _seedDefaultUsers() {
    final now = DateTime.now().subtract(const Duration(days: 30));

    final defaultCustomer = AppUser(
      id: 'USR-9876543210',
      phone: '9876543210',
      fullName: 'Ananya Sharma',
      email: 'ananya.sharma@sahakar.coop',
      role: UserRole.user,
      address: 'Chandrashekhar Agashe Road, Shaniwar Peth, Pune, Maharashtra 411001',
      city: 'Pune',
      state: 'Maharashtra',
      postalCode: '411001',
      latitude: 18.5211,
      longitude: 73.8502,
      registeredAt: now,
    );

    final defaultWorker = AppUser(
      id: 'WRK-9876543211',
      phone: '9876543211',
      fullName: 'Aakash Verma',
      email: 'aakash.verma@sahakar.coop',
      role: UserRole.gigWorker,
      address: 'Near Shaniwar Wada, Pune, Maharashtra 411030',
      city: 'Pune',
      state: 'Maharashtra',
      postalCode: '411030',
      latitude: 18.5196,
      longitude: 73.8553,
      registeredAt: now,
      trade: 'Certified Senior Electrician',
      eShramUan: '1009-4428-9912',
      societyName: 'Shramik Kalyan Sahakari Mandali',
      nsqfLevel: 4,
      rating: 4.9,
      completedJobs: 342,
      isVerified: true,
    );

    final defaultAdmin = AppUser(
      id: 'ADM-9876543212',
      phone: '9876543212',
      fullName: 'Rajesh Patil',
      email: 'rajesh.patil@sahakar.gov.in',
      role: UserRole.admin,
      address: 'Apex Cooperative Federation Headquarters, Pune, Maharashtra 411001',
      city: 'Pune',
      state: 'Maharashtra',
      postalCode: '411001',
      latitude: 18.5204,
      longitude: 73.8567,
      registeredAt: now,
      designation: 'District Cooperative Registrar & Compliance Auditor',
      jurisdictionCircle: 'Pune Metropolitan Circle',
    );

    _usersCache[defaultCustomer.phone] = defaultCustomer;
    _usersCache[defaultWorker.phone] = defaultWorker;
    _usersCache[defaultAdmin.phone] = defaultAdmin;
  }

  static Future<void> _persistUsers() async {
    try {
      if (_prefs == null) return;
      final List<Map<String, dynamic>> rawList =
          _usersCache.values.map((u) => u.toJson()).toList();
      await _prefs!.setString(_usersKey, json.encode(rawList));
    } catch (_) {}
  }

  /// Get all registered users in database
  static List<AppUser> getAllUsers() {
    return _usersCache.values.toList();
  }

  /// Get users by their role
  static List<AppUser> getUsersByRole(UserRole role) {
    return _usersCache.values.where((u) => u.role == role).toList();
  }

  /// Get user by phone number
  static AppUser? getUserByPhone(String phone) {
    final cleanPhone = _cleanPhone(phone);
    return _usersCache[cleanPhone];
  }

  /// Register or update user in database
  static Future<AppUser> registerUser(AppUser user) async {
    await init();
    final cleanPhone = _cleanPhone(user.phone);
    final userWithCleanPhone = AppUser(
      id: user.id.isNotEmpty ? user.id : 'USR-$cleanPhone',
      phone: cleanPhone,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
      address: user.address,
      city: user.city,
      state: user.state,
      postalCode: user.postalCode,
      latitude: user.latitude,
      longitude: user.longitude,
      registeredAt: user.registeredAt,
      trade: user.trade,
      eShramUan: user.eShramUan,
      societyName: user.societyName,
      nsqfLevel: user.nsqfLevel,
      rating: user.rating,
      completedJobs: user.completedJobs,
      isVerified: user.isVerified,
      designation: user.designation,
      jurisdictionCircle: user.jurisdictionCircle,
    );

    _usersCache[cleanPhone] = userWithCleanPhone;
    await _persistUsers();
    await saveSession(userWithCleanPhone);
    return userWithCleanPhone;
  }

  /// Authenticate with phone, role, and OTP
  static Future<AppUser> authenticate({
    required String phone,
    required UserRole role,
    String? defaultAddress,
    double? latitude,
    double? longitude,
  }) async {
    await init();
    final cleanPhone = _cleanPhone(phone);

    // If user exists for this phone, return it
    if (_usersCache.containsKey(cleanPhone)) {
      var existing = _usersCache[cleanPhone]!;
      // Update role if changed
      if (existing.role != role) {
        existing = existing.copyWith(role: role);
        _usersCache[cleanPhone] = existing;
        await _persistUsers();
      }
      await saveSession(existing);
      return existing;
    }

    // Auto-create new user account with detected coordinates
    final newUser = AppUser(
      id: 'USR-$cleanPhone',
      phone: cleanPhone,
      fullName: role == UserRole.user
          ? 'Sahakar User ($cleanPhone)'
          : role == UserRole.gigWorker
              ? 'Co-op Worker ($cleanPhone)'
              : 'Governance Admin ($cleanPhone)',
      role: role,
      address: defaultAddress ?? 'Chandrashekhar Agashe Road, Shaniwar Peth, Pune',
      latitude: latitude ?? 18.5211,
      longitude: longitude ?? 73.8502,
      registeredAt: DateTime.now(),
      trade: role == UserRole.gigWorker ? 'Certified Technician' : null,
      eShramUan: role == UserRole.gigWorker ? '1009-8822-0044' : null,
      societyName: role == UserRole.gigWorker ? 'District Cooperative Society' : null,
      designation: role == UserRole.admin ? 'Cooperative Officer' : null,
    );

    _usersCache[cleanPhone] = newUser;
    await _persistUsers();
    await saveSession(newUser);
    return newUser;
  }

  /// Save active user session
  static Future<void> saveSession(AppUser user) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_sessionKey, user.phone);
    } catch (_) {}
  }

  /// Get active user session
  static AppUser? getSavedSession() {
    try {
      final phone = _prefs?.getString(_sessionKey);
      if (phone != null && _usersCache.containsKey(phone)) {
        return _usersCache[phone];
      }
    } catch (_) {}
    return null;
  }

  /// Logout and clear session
  static Future<void> clearSession() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.remove(_sessionKey);
    } catch (_) {}
  }

  static String _cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
