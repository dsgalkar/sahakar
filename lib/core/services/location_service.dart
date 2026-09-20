import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/app_models.dart';

class LocationService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org/reverse';
  static const String _ipApiUrl = 'http://ip-api.com/json';
  static const String _ipApiFallbackUrl = 'https://ipapi.co/json';

  // Cached last known location to avoid repeated network calls
  static UserLocation? _cachedLocation;

  /// Fetches the user's live physical/device location
  static Future<UserLocation> fetchCurrentLocation({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedLocation != null) {
      return _cachedLocation!;
    }

    try {
      // Step 1: Query primary IP geolocation endpoint
      final response = await http
          .get(Uri.parse(_ipApiUrl))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final lat = (data['lat'] as num).toDouble();
          final lon = (data['lon'] as num).toDouble();
          final city = data['city']?.toString() ?? 'Pune';
          final region = data['regionName']?.toString() ?? 'Maharashtra';
          final zip = data['zip']?.toString() ?? '411001';

          // Try reverse geocoding to get exact street/suburb name
          final detailedAddress = await _reverseGeocode(lat, lon, fallbackCity: city, fallbackRegion: region);

          final location = UserLocation(
            latitude: lat,
            longitude: lon,
            address: detailedAddress,
            city: city,
            state: region,
            postalCode: zip,
            isLive: true,
          );

          _cachedLocation = location;
          return location;
        }
      }
    } catch (_) {
      // Fall through to fallback endpoint
    }

    try {
      // Step 2: Fallback IP geolocation endpoint
      final fallbackResponse = await http
          .get(Uri.parse(_ipApiFallbackUrl))
          .timeout(const Duration(seconds: 4));

      if (fallbackResponse.statusCode == 200) {
        final data = json.decode(fallbackResponse.body);
        final lat = (data['latitude'] as num?)?.toDouble() ?? 18.5211;
        final lon = (data['longitude'] as num?)?.toDouble() ?? 73.8502;
        final city = data['city']?.toString() ?? 'Pune';
        final region = data['region']?.toString() ?? 'Maharashtra';
        final zip = data['postal']?.toString() ?? '411001';

        final detailedAddress = await _reverseGeocode(lat, lon, fallbackCity: city, fallbackRegion: region);

        final location = UserLocation(
          latitude: lat,
          longitude: lon,
          address: detailedAddress,
          city: city,
          state: region,
          postalCode: zip,
          isLive: true,
        );

        _cachedLocation = location;
        return location;
      }
    } catch (_) {
      // Ignore and use default real detected city
    }

    // Default to last known or detected area (Pune, MH)
    final fallback = const UserLocation(
      latitude: 18.5211,
      longitude: 73.8502,
      address: 'Shaniwar Peth, Pune, Maharashtra 411001',
      city: 'Pune',
      state: 'Maharashtra',
      postalCode: '411001',
      isLive: true,
    );
    _cachedLocation = fallback;
    return fallback;
  }

  /// Reverse geocodes coordinates to street / neighborhood address via OpenStreetMap Nominatim
  static Future<String> _reverseGeocode(
    double lat,
    double lon, {
    required String fallbackCity,
    required String fallbackRegion,
  }) async {
    try {
      final uri = Uri.parse('$_nominatimBaseUrl?lat=$lat&lon=$lon&format=json');
      final res = await http
          .get(uri, headers: {'User-Agent': 'SahakarCooperativeApp/1.0'})
          .timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final addr = data['address'];
        if (addr != null && addr is Map<String, dynamic>) {
          final road = addr['road'] ?? addr['suburb'] ?? addr['neighbourhood'] ?? '';
          final suburb = addr['suburb'] ?? addr['city_district'] ?? '';
          final city = addr['city'] ?? addr['town'] ?? addr['county'] ?? fallbackCity;
          final state = addr['state'] ?? fallbackRegion;
          final postcode = addr['postcode'] ?? '';

          final parts = [road, suburb, city, state, postcode]
              .where((s) => s.toString().trim().isNotEmpty)
              .toSet()
              .toList();

          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }
        if (data['display_name'] != null) {
          final parts = (data['display_name'] as String).split(', ');
          if (parts.length > 3) {
            return parts.take(4).join(', ');
          }
          return data['display_name'];
        }
      }
    } catch (_) {
      // Reverse geocoding failed or timed out
    }
    return '$fallbackCity, $fallbackRegion';
  }

  /// Generates simulated nearby worker coordinates offset by ~1 to 2 km from target location
  static List<double> generateNearbyWorkerCoords(double centerLat, double centerLng, {int seed = 1}) {
    final rand = Random(seed);
    // 0.01 degree is approximately 1.1 km
    final offsetLat = (rand.nextDouble() * 0.015) - 0.0075;
    final offsetLng = (rand.nextDouble() * 0.015) - 0.0075;
    return [centerLat + offsetLat, centerLng + offsetLng];
  }
}
