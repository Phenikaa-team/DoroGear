import 'package:doro_gear/localization/app_localizations.dart';
import 'package:doro_gear/services/geocoding_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
  final TextEditingController _searchController = TextEditingController();

  LatLng _selectedLocation = const LatLng(21.0285, 105.8542); // Hanoi
  String _addressText = "";
  bool _isLoadingAddress = false;
  bool _isInitialLocationSet = false;
  List<LocationResult> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _selectedLocation = LatLng(
        widget.initialPosition!.latitude,
        widget.initialPosition!.longitude,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_addressText.isEmpty) {
      _addressText = AppLocalizations.of(context)!.translate('tapToSelectLocation');
    }
  }

  Future<void> _setInitialLocation(AppLocalizations t) async {
    LatLng locationToUse;

    if (widget.initialPosition != null) {
      locationToUse = LatLng(
        widget.initialPosition!.latitude,
        widget.initialPosition!.longitude,
      );
    } else {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _showSnackbar(t.translate('locationServiceDisabled'));
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            _showSnackbar(t.translate('locationPermissionDenied'));
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          _showSnackbar(t.translate('locationPermissionPermanentlyDenied'));
          return;
        }

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        locationToUse = LatLng(position.latitude, position.longitude);
      } catch (e) {
        _showSnackbar(t.translate('failedToGetCurrentLocation').replaceAll('{error}', e.toString()));
        locationToUse = _selectedLocation;
      }
    }

    setState(() {
      _selectedLocation = locationToUse;
    });

    _mapController.move(locationToUse, 15.0);
    await _getAddressFromLatLng(locationToUse, t);
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _getAddressFromLatLng(LatLng latLng, AppLocalizations t) async {
    if (!mounted) return;

    setState(() {
      _isLoadingAddress = true;
      _addressText = t.translate('searchingForAddress');
      _selectedLocation = latLng;
    });

    try {
      final address = await GeocodingService.getAddressFromCoordinates(latLng);

      if (mounted) {
        setState(() {
          _addressText = address;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _addressText = 'Tọa độ: ${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
          _isLoadingAddress = false;
        });
        _showSnackbar(t.translate('geocodingError').replaceAll('{error}', e.toString()));
      }
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await GeocodingService.searchLocation(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        _showSnackbar('Không thể tìm kiếm: $e');
      }
    }
  }

  void _selectSearchResult(LocationResult result) {
    setState(() {
      _selectedLocation = result.location;
      _addressText = result.displayName;
      _searchResults = [];
      _searchController.clear();
    });
    _mapController.move(result.location, 15.0);
  }

  void _confirmSelection() {
    if (_isLoadingAddress) return;

    String finalAddress = _addressText;
    if (finalAddress.isEmpty ||
        finalAddress == AppLocalizations.of(context)!.translate('tapToSelectLocation')) {
      finalAddress = 'Tọa độ: ${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}';
    }

    Navigator.pop(context, {
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'fullAddress': finalAddress,
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
            onPressed: () => _setInitialLocation(t),
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
              onTap: (tapPosition, latLng) => _getAddressFromLatLng(latLng, t),
              onMapReady: () {
                if (!_isInitialLocationSet) {
                  _setInitialLocation(t);
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
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm địa điểm...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                          : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                  if (_searchResults.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on, size: 20),
                            title: Text(
                              result.displayName,
                              style: const TextStyle(fontSize: 14),
                            ),
                            onTap: () => _selectSearchResult(result),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 8.0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          t.translate('selectedLocation'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _isLoadingAddress
                        ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                        : Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _addressText,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, Lon: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoadingAddress ? null : _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor: Colors.grey[300],
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