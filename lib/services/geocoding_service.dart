import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  static Future<String> getAddressFromCoordinates(LatLng location) async {
    try {
      final address = await _getAddressFromGeocodingPackage(location);
      if (address.isNotEmpty) {
        return address;
      }
    } catch (e) {
      debugPrint('Geocoding package failed: $e');
    }

    try {
      final address = await _getAddressFromNominatim(location);
      if (address.isNotEmpty) {
        return address;
      }
    } catch (e) {
      debugPrint('Nominatim API failed: $e');
    }

    return _formatCoordinatesAsAddress(location);
  }

  static Future<String> _getAddressFromGeocodingPackage(LatLng location) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      )
          .timeout(const Duration(seconds: 8));

      if (placemarks.isEmpty) {
        return '';
      }

      return _buildAddressFromPlacemark(placemarks.first);
    } catch (e) {
      return '';
    }
  }

  static Future<String> _getAddressFromNominatim(LatLng location) async {
    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'DoroGearApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _buildAddressFromNominatim(data);
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static String _buildAddressFromPlacemark(geocoding.Placemark place) {
    List<String> addressParts = [];

    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }

    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }

    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    } else if (place.subAdministrativeArea != null &&
        place.subAdministrativeArea!.isNotEmpty) {
      addressParts.add(place.subAdministrativeArea!);
    }

    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }

    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }

    return addressParts.isEmpty ? '' : addressParts.join(', ');
  }

  static String _buildAddressFromNominatim(Map<String, dynamic> data) {
    try {
      final address = data['address'] as Map<String, dynamic>?;
      if (address == null) {
        return data['display_name'] ?? '';
      }

      List<String> addressParts = [];

      if (address['house_number'] != null) {
        addressParts.add(address['house_number'].toString());
      }

      final road = address['road'] ?? address['street'] ?? address['highway'];
      if (road != null) {
        addressParts.add(road.toString());
      }

      final ward = address['suburb'] ??
          address['neighbourhood'] ??
          address['quarter'];
      if (ward != null) {
        addressParts.add(ward.toString());
      }

      final district = address['city_district'] ??
          address['district'] ??
          address['county'];
      if (district != null) {
        addressParts.add(district.toString());
      }

      final city = address['city'] ??
          address['town'] ??
          address['village'] ??
          address['state'];
      if (city != null) {
        addressParts.add(city.toString());
      }

      if (address['country'] != null) {
        addressParts.add(address['country'].toString());
      }

      if (addressParts.isEmpty && data['display_name'] != null) {
        return data['display_name'].toString();
      }

      return addressParts.join(', ');
    } catch (e) {
      return data['display_name']?.toString() ?? '';
    }
  }

  static String _formatCoordinatesAsAddress(LatLng location) {
    final lat = location.latitude.toStringAsFixed(6);
    final lon = location.longitude.toStringAsFixed(6);
    return 'Tọa độ: $lat, $lon';
  }

  static bool isValidAddress(String address) {
    if (address.isEmpty) return false;

    if (address.startsWith('Tọa độ:') ||
        address.contains(RegExp(r'^\d+\.\d+,\s*\d+\.\d+$'))) {
      return false;
    }

    return true;
  }

  static Future<List<LocationResult>> searchLocation(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/search?format=json&q=${Uri.encodeComponent(query)}&limit=5&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'DoroGearApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        return results.map((item) => LocationResult.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Search location failed: $e');
      return [];
    }
  }
}

class LocationResult {
  final String displayName;
  final double latitude;
  final double longitude;
  final String? type;
  final Map<String, dynamic>? address;

  LocationResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.type,
    this.address,
  });

  factory LocationResult.fromJson(Map<String, dynamic> json) {
    return LocationResult(
      displayName: json['display_name'] ?? '',
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      type: json['type'],
      address: json['address'],
    );
  }

  LatLng get location => LatLng(latitude, longitude);
}