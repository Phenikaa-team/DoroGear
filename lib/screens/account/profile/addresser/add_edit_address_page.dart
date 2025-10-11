import 'package:doro_gear/models/delivery_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../constants/app_colors.dart';
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
  final user = UserService.currentUser!;

  final MapController _mapController = MapController();

  static const LatLng _kDefaultLocation = LatLng(21.028511, 105.804817);

  LatLng _selectedLocation = _kDefaultLocation;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _detailsController;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final isEdit = widget.address != null;

    _nameController = TextEditingController(text: isEdit ? widget.address!.receiverName : user.name);
    _phoneController = TextEditingController(text: isEdit ? widget.address!.receiverPhone : user.phoneNumber ?? '');
    _addressController = TextEditingController(text: isEdit ? widget.address!.fullAddress : '');
    _detailsController = TextEditingController(text: isEdit ? widget.address!.details : '');
    _isDefault = isEdit ? widget.address!.isDefault : false;

    if (isEdit) {
      _selectedLocation = LatLng(widget.address!.latitude, widget.address!.longitude);
    }
    if (isEdit) {
      _reverseGeocode(_selectedLocation);
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

  Future<void> _reverseGeocode(LatLng position) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );

      if (placemarks.isNotEmpty) {
        final geocoding.Placemark first = placemarks.first;
        final addressLine = [
          first.street,
          first.subLocality,
          first.locality,
          first.administrativeArea,
          first.country
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        _addressController.text = addressLine;
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
      _addressController.text = 'Không thể tìm thấy tên đường cho vị trí này.';
    }
  }

  void _updateLocation(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });

    _mapController.move(position, 16.0);

    _reverseGeocode(position);
  }

  Future<void> _navigateToMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapPickerScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final LatLng newLocation = LatLng(result['latitude'] as double, result['longitude'] as double);
      final String newAddress = result['fullAddress'] as String;

      setState(() {
        _selectedLocation = newLocation;
        _addressController.text = newAddress;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar('Dịch vụ định vị đã bị tắt.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar('Quyền truy cập vị trí đã bị từ chối.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackbar('Quyền bị từ chối vĩnh viễn. Vui lòng bật thủ công trong Cài đặt.');
      return;
    }

    try {
      _showSnackbar('Đang lấy vị trí hiện tại...');
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      _updateLocation(newLocation);

    } catch (e) {
      _showSnackbar('Không thể lấy vị trí hiện tại: $e');
      debugPrint('Error getting current location: $e');
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == _kDefaultLocation && widget.address == null) {
        _showSnackbar('Vui lòng chọn vị trí trên bản đồ.');
        return;
      }

      final newAddressData = DeliveryAddress(
        id: widget.address?.id ?? '',
        userId: user.email,
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
        final updatedAddress = widget.address!.copyWith(
          receiverName: newAddressData.receiverName,
          receiverPhone: newAddressData.receiverPhone,
          fullAddress: newAddressData.fullAddress,
          details: newAddressData.details,
          latitude: newAddressData.latitude,
          longitude: newAddressData.longitude,
          isDefault: newAddressData.isDefault,
        );
        await AddressService.updateAddress(updatedAddress);
      }

      if (!mounted) return;
      _showSnackbar(widget.address == null ? 'Thêm địa chỉ thành công!' : 'Cập nhật địa chỉ thành công!');
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Thêm địa chỉ mới' : 'Chỉnh sửa địa chỉ'),
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
              _buildMapSection(),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _addressController,
                label: 'Địa chỉ (Tên đường, Phường/Xã, Quận/Huyện, Tỉnh/Thành phố)',
                icon: Icons.map_outlined,
                readOnly: true,
                validator: (value) => value!.trim().isEmpty ? 'Vui lòng chọn vị trí' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _detailsController,
                label: 'Chi tiết địa chỉ (Số nhà, Tầng, ...)',
                icon: Icons.home_work_outlined,
              ),
              const SizedBox(height: 30),
              const Text('Thông tin người nhận', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildTextField(
                controller: _nameController,
                label: 'Tên người nhận',
                icon: Icons.person_outline,
                validator: (value) => value!.trim().isEmpty ? 'Vui lòng nhập tên người nhận' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _phoneController,
                label: 'Số điện thoại người nhận',
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
                  if (value.length < 10) return 'SĐT phải có ít nhất 10 số';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildDefaultCheckbox(),
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
                  child: Text(widget.address == null ? 'Thêm địa chỉ' : 'Lưu địa chỉ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn vị trí giao hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: _navigateToMapPicker,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, color: AppColors.primaryColor, size: 30),
                const SizedBox(width: 10),
                Text(
                  _selectedLocation == _kDefaultLocation && widget.address == null
                      ? 'Chạm để mở bản đồ chọn vị trí'
                      : 'Đã chọn vị trí (${_selectedLocation.latitude.toStringAsFixed(2)}, ...)',
                  style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Vị trí hiện tại: Lat: ${_selectedLocation.latitude.toStringAsFixed(4)}, Lon: ${_selectedLocation.longitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location, size: 20),
              label: const Text('Vị trí hiện tại'),
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
        suffixIcon: readOnly ? const Icon(Icons.location_city, color: Colors.grey) : null,
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildDefaultCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isDefault,
          onChanged: (value) {
            setState(() {
              _isDefault = value ?? false;
            });
          },
          activeColor: AppColors.primaryColor,
        ),
        const Text('Đặt làm địa chỉ mặc định', style: TextStyle(fontSize: 14)),
      ],
    );
  }
}