import 'package:doro_gear/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  final Position? initialPosition;
  const MapPickerScreen({super.key, this.initialPosition});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();

  LatLng _selectedLocation = const LatLng(21.0285, 105.8542); // Hanoi
  String _addressText = "";
  bool _isLoadingAddress = true;
  bool _isInitialLocationSet = false;

  @override
  void initState() {
    super.initState();
    _addressText = "Tap the map to select a location...";
    //_setInitialLocation()
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoadingAddress) {
      _addressText = AppLocalizations.of(context)!.translate('tapToSelectLocation');
    }
  }

  Future<void> _setInitialLocation() async {
    LatLng locationToUse;
    if (widget.initialPosition != null) {
      locationToUse = LatLng(widget.initialPosition!.latitude, widget.initialPosition!.longitude);
    } else {
      locationToUse = _selectedLocation;
    }

    setState(() {
      _selectedLocation = locationToUse;
    });

    _mapController.move(locationToUse, 15.0);
    await _getAddressFromLatLng(locationToUse);
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    if (!mounted) return;
    final t = AppLocalizations.of(context)!;

    setState(() {
      _isLoadingAddress = true;
      _addressText = t.translate('searchingForAddress');
      _selectedLocation = latLng;
    });

    try {
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        _addressText = address.isNotEmpty ? address : t.translate('addressNotFound');
      } else {
        _addressText = t.translate('addressNotFound');
      }
    } catch (e) {
      _addressText = t.translate('geocodingError').replaceAll('{error}', e.toString());
    } finally {
      if(mounted) {
        setState(() => _isLoadingAddress = false);
      }
    }
  }

  void _confirmSelection() {
    Navigator.pop(context, {
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'fullAddress': _addressText,
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('chooseDeliveryLocation')),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _setInitialLocation,
            tooltip: t.translate('backToCurrentLocation'),
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
              onTap: (tapPosition, latLng) => _getAddressFromLatLng(latLng),
              onMapReady: () {
                if (!_isInitialLocationSet) {
                  _setInitialLocation();
                  _isInitialLocationSet = true;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.doro.gear',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Material(
              elevation: 8.0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(t.translate('selectedLocation'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    _isLoadingAddress
                        ? const Center(child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ))
                        : Text(_addressText, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoadingAddress ? null : _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(t.translate('confirmThisAddress')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}