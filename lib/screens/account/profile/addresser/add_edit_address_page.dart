import 'package:doro_gear/models/delivery_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../constants/app_colors.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../models/user.dart';
import '../../../../services/address_service.dart';
import '../../../../services/user_service.dart';
import 'map_picker_screen.dart';

class AddEditAddressPage extends StatefulWidget {
  final DeliveryAddress? address;
  const AddEditAddressPage({super.key, this.address});

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late final User _user;

  static const LatLng _kDefaultLocation = LatLng(21.0285, 105.8542);
  LatLng _selectedLocation = _kDefaultLocation;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _detailsController;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    _user = UserService.currentUser!;
    final isEdit = widget.address != null;

    _nameController = TextEditingController(text: isEdit ? widget.address!.receiverName : _user.name);
    _phoneController = TextEditingController(text: isEdit ? widget.address!.receiverPhone : _user.phoneNumber ?? '');
    _addressController = TextEditingController(text: isEdit ? widget.address!.fullAddress : '');
    _detailsController = TextEditingController(text: isEdit ? widget.address!.details : '');
    _isDefault = isEdit ? widget.address!.isDefault : false;

    if (isEdit) {
      _selectedLocation = LatLng(widget.address!.latitude, widget.address!.longitude);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _navigateToMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = LatLng(result['latitude'] as double, result['longitude'] as double);
        _addressController.text = result['fullAddress'] as String;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    final t = AppLocalizations.of(context)!;
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

    try {
      _showSnackbar(t.translate('gettingCurrentLocation'));
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(builder: (context) => MapPickerScreen(initialPosition: position)),
      );

      if (result != null) {
        setState(() {
          _selectedLocation = LatLng(result['latitude'] as double, result['longitude'] as double);
          _addressController.text = result['fullAddress'] as String;
        });
      }

    } catch (e) {
      _showSnackbar(t.translate('failedToGetCurrentLocation').replaceAll('{error}', e.toString()));
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveAddress() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final t = AppLocalizations.of(context)!;

    if (_addressController.text.isEmpty) {
      _showSnackbar(t.translate('selectLocationPrompt'));
      return;
    }

    final newAddressData = DeliveryAddress(
      id: widget.address?.id ?? '',
      userId: _user.email,
      receiverName: _nameController.text.trim(),
      receiverPhone: _phoneController.text.trim(),
      fullAddress: _addressController.text.trim(),
      details: _detailsController.text.trim(),
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
      isDefault: _isDefault,
    );

    if (widget.address == null) {
      await AddressService.addAddress(newAddressData);
    } else {
      await AddressService.updateAddress(newAddressData);
    }

    if (!mounted) return;
    _showSnackbar(widget.address == null ? t.translate('addSuccess') : t.translate('updateAddressSuccess'));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isEditMode = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? t.translate('editAddress') : t.translate('addNewAddress')),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMapSection(t),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _addressController,
                label: t.translate('deliveryAddress'),
                icon: Icons.map_outlined,
                readOnly: true,
                validator: (value) => (value?.trim().isEmpty ?? true) ? t.translate('addressRequired') : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _detailsController,
                label: t.translate('addressDetails'),
                icon: Icons.home_work_outlined,
              ),
              const SizedBox(height: 30),
              Text(t.translate('receiverInfo'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildTextField(
                controller: _nameController,
                label: t.translate('receiverName'),
                icon: Icons.person_outline,
                validator: (value) => (value?.trim().isEmpty ?? true) ? t.translate('pleaseEnterReceiverName') : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _phoneController,
                label: t.translate('receiverPhone'),
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return t.translate('pleaseEnterReceiverPhone');
                  if (value.length < 10) return t.translate('phoneInvalid');
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildDefaultCheckbox(t),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isEditMode ? t.translate('saveAddress') : t.translate('addAddress'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection(AppLocalizations t) {
    bool isLocationSelected = _addressController.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.translate('chooseDeliveryLocation'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        InkWell(
          onTap: _navigateToMapPicker,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, color: AppColors.primaryColor, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isLocationSelected ? t.translate('locationSelected') : t.translate('tapToOpenMap'),
                    style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Lat: ${_selectedLocation.latitude.toStringAsFixed(4)}, Lon: ${_selectedLocation.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location, size: 20),
              label: Text(t.translate('getCurrentLocation')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        suffixIcon: readOnly ? const Icon(Icons.arrow_drop_down, color: Colors.grey) : null,
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildDefaultCheckbox(AppLocalizations t) {
    return InkWell(
      onTap: () => setState(() => _isDefault = !_isDefault),
      child: Row(
        children: [
          Checkbox(
            value: _isDefault,
            onChanged: (value) => setState(() => _isDefault = value ?? false),
            activeColor: AppColors.primaryColor,
          ),
          Text(t.translate('setDefaultAddress'), style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}