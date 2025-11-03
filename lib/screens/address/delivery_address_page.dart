import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../localization/app_localizations.dart';
import '../../models/delivery_address.dart';
import '../../services/address_service.dart';
import 'add_edit_address_page.dart';

class DeliveryAddressPage extends StatefulWidget {
  final bool isSelecting;

  const DeliveryAddressPage({
    super.key,
    this.isSelecting = false,
  });

  @override
  State<DeliveryAddressPage> createState() => _DeliveryAddressPageState();
}

class _DeliveryAddressPageState extends State<DeliveryAddressPage> {
  List<DeliveryAddress> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    await AddressService.initialize();
    setState(() {
      _addresses = AddressService.getAddressesForCurrentUser();
      _isLoading = false;
    });
  }

  Future<void> _navigateToAddEditAddress({DeliveryAddress? address}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressPage(address: address),
      ),
    );
    if (result == true) {
      _loadAddresses();
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await AddressService.deleteAddress(addressId);
      _loadAddresses();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa địa chỉ thành công.')),
      );
    }
  }

  Future<void> _setDefaultAddress(DeliveryAddress address) async {
    final updatedAddress = address.copyWith(isDefault: true);

    await AddressService.updateAddress(updatedAddress);
    _loadAddresses();
  }


  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isSelecting ? t.translate('selectAddress') : t.translate(
                'deliveryAddress')),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? _buildEmptyState(t)
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _addresses.length,
        itemBuilder: (context, index) =>
            _buildAddressCard(_addresses[index], t),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEditAddress(),
        icon: const Icon(Icons.add),
        label: Text(t.translate('addNewAddress')),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(t.translate('noAddresses'),
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAddressCard(DeliveryAddress address, AppLocalizations t) {
    return InkWell(
      // Yes sir
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        if (widget.isSelecting) {
          Navigator.pop(context, address);
        }
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: widget.isSelecting
                ? BorderSide(
                color: AppColors.primaryColor.withValues(alpha: 0.5), width: 1)
                : BorderSide.none
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    address.receiverName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.primaryColor),
                      ),
                      child: Text(
                        t.translate('default'),
                        style: TextStyle(color: AppColors.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  if (widget.isSelecting)
                    Icon(Icons.chevron_right, color: Colors.grey[400])
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(address.receiverPhone,
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
              const Divider(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${address.details.isNotEmpty ? "${address.details}, " : ""}${address.fullAddress}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!address.isDefault)
                    TextButton(
                      onPressed: () => _setDefaultAddress(address),
                      child: Text(t.translate('setDefault'),
                          style: TextStyle(color: Colors.blue)),
                    ),
                  TextButton(
                    onPressed: () =>
                        _navigateToAddEditAddress(address: address),
                    child: Text(t.translate('edit'),
                        style: TextStyle(color: AppColors.primaryColor)),
                  ),
                  TextButton(
                    onPressed: () => _deleteAddress(address.id),
                    child: Text(t.translate('delete'),
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],

          ),
        ),
      ),
    );
  }
}