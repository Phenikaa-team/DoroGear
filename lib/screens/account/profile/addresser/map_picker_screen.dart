import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();

  LatLng? _initialLocation;

  LatLng _selectedLocation = const LatLng(21.0285, 105.8542);
  String _addressText = "Chạm vào bản đồ để chọn vị trí...";

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _initialLocation = currentLatLng;
        _selectedLocation = currentLatLng;
      });

      _mapController.move(currentLatLng, 15.0);

      _getAddressFromLatLng(currentLatLng);

    } catch (e) {
      _initialLocation = _selectedLocation;
      _getAddressFromLatLng(_selectedLocation);
    }
  }

  void _backToCurrentLocation() {
    if (_initialLocation != null) {
      _mapController.move(_initialLocation!, 15.0);

      _getAddressFromLatLng(_initialLocation!);
      _addressText = "Vị trí hiện tại của thiết bị.";
    } else {
      _getAddressFromLatLng(_selectedLocation);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    if (!mounted) return;
    setState(() {
      _addressText = "Đang tìm địa chỉ...";
      _selectedLocation = latLng;
    });

    try {
      List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        if (!mounted) return;
        final place = placemarks.first;
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          _addressText = address;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _addressText = "Không tìm thấy địa chỉ cho vị trí này.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _addressText = "Lỗi Geocoding: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn Địa Chỉ Giao Hàng"),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _initialLocation == null ? null : _backToCurrentLocation,
            tooltip: 'Quay lại vị trí hiện tại',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              onTap: (tapPosition, latLng) {
                _getAddressFromLatLng(latLng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.your_app_name.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Vị trí đã chọn:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_addressText),
                  const SizedBox(height: 8),
                  Text("Tọa độ: ${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'latitude': _selectedLocation.latitude,
                        'longitude': _selectedLocation.longitude,
                        'fullAddress': _addressText, // Có thể cần phân tích chuỗi này chi tiết hơn
                      });
                    },
                    child: const Text("Xác nhận Địa chỉ này"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}