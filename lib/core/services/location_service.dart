import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/app_models.dart';

class LocationService {
  static const String _ipWhoIsUrl = 'https://ipwho.is/';
  static const String _freeIpApiUrl = 'https://freeipapi.com/api/json';
  static const String _bigDataCloudUrl = 'https://api.bigdatacloud.net/data/reverse-geocode-client';
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org/reverse';

  // Cached last known location to avoid repeated network calls
  static UserLocation? _cachedLocation;

  /// Fetches the user's live physical/device location
  static Future<UserLocation> fetchCurrentLocation({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedLocation != null) {
      return _cachedLocation!;
    }

    // Step 1: Query primary IP geolocation endpoint (https://ipwho.is/ - HTTPS & CORS compliant)
    try {
      final response = await http
          .get(Uri.parse(_ipWhoIsUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final lat = (data['latitude'] as num).toDouble();
          final lon = (data['longitude'] as num).toDouble();
          final city = data['city']?.toString() ?? 'Pune';
          final region = data['region']?.toString() ?? 'Maharashtra';
          final zip = data['postal']?.toString() ?? '411001';

          final detailedAddress = await _reverseGeocode(
            lat,
            lon,
            fallbackCity: city,
            fallbackRegion: region,
          );

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
      // Fall through to secondary endpoint
    }

    // Step 2: Query secondary IP geolocation endpoint (https://freeipapi.com/api/json - HTTPS & CORS compliant)
    try {
      final fallbackResponse = await http
          .get(Uri.parse(_freeIpApiUrl))
          .timeout(const Duration(seconds: 5));

      if (fallbackResponse.statusCode == 200) {
        final data = json.decode(fallbackResponse.body);
        final lat = (data['latitude'] as num?)?.toDouble() ?? 18.5196;
        final lon = (data['longitude'] as num?)?.toDouble() ?? 73.8553;
        final city = data['cityName']?.toString() ?? 'Pune';
        final region = data['regionName']?.toString() ?? 'Maharashtra';
        final zip = data['zipCode']?.toString() ?? '411001';

        final detailedAddress = await _reverseGeocode(
          lat,
          lon,
          fallbackCity: city,
          fallbackRegion: region,
        );

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
      // Fall through to fallback
    }

    // Default to last known or detected area (Pune, MH)
    final fallback = const UserLocation(
      latitude: 18.5196,
      longitude: 73.8553,
      address: 'Kasba Peth / Shivaji Road, Pune, Maharashtra 411001',
      city: 'Pune',
      state: 'Maharashtra',
      postalCode: '411001',
      isLive: true,
    );
    _cachedLocation = fallback;
    return fallback;
  }

  /// Reverse geocodes coordinates to street / neighborhood address
  static Future<String> _reverseGeocode(
    double lat,
    double lon, {
    required String fallbackCity,
    required String fallbackRegion,
  }) async {
    // Attempt 1: BigDataCloud Client Reverse Geocoding (HTTPS & CORS friendly for Web)
    try {
      final uri = Uri.parse('$_bigDataCloudUrl?latitude=$lat&longitude=$lon&localityLanguage=en');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final locality = data['locality']?.toString() ?? '';
        final city = data['city']?.toString() ?? fallbackCity;
        final principalSub = data['principalSubdivision']?.toString() ?? fallbackRegion;
        final country = data['countryName']?.toString() ?? 'India';

        final parts = [locality, city, principalSub, country]
            .where((s) => s.trim().isNotEmpty)
            .toSet()
            .toList();

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
    } catch (_) {
      // Try next
    }

    // Attempt 2: OpenStreetMap Nominatim (browser safe, no unsafe headers)
    try {
      final uri = Uri.parse('$_nominatimUrl?lat=$lat&lon=$lon&format=json');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));

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
      // Return fallback
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
