import 'dart:convert';
import 'package:doro_gear/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/delivery_address.dart';

class AddressService {
  static const String _addressKey = 'app_delivery_addresses';
  static final Uuid _uuid = const Uuid();
  static final List<DeliveryAddress> _allAddresses = [];

  static Future<void> initialize() async {
    await _loadAddresses();
  }

  static Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressListJson = _allAddresses.map((addr) => addr.toJson()).toList();
    await prefs.setString(_addressKey, json.encode(addressListJson));
  }

  static Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressListString = prefs.getString(_addressKey);

    if (addressListString != null) {
      final List<dynamic> addressListJson = json.decode(addressListString);
      _allAddresses.clear();
      for (var json in addressListJson) {
        _allAddresses.add(DeliveryAddress.fromJson(json));
      }
    }
  }

  static List<DeliveryAddress> getAddressesForCurrentUser() {
    final userId = UserService.currentUser?.email;
    if (userId == null) return [];
    return _allAddresses.where((addr) => addr.userId == userId).toList();
  }

  static Future<DeliveryAddress> addAddress(DeliveryAddress newAddress) async {
    final userId = UserService.currentUser?.email;
    if (userId == null) throw Exception("User not logged in");

    DeliveryAddress addressToSave = newAddress.copyWith(
      id: _uuid.v4(),
      userId: userId,
    );

    if (addressToSave.isDefault) {
      _clearDefault(userId);
    } else if (getAddressesForCurrentUser().isEmpty) {
      addressToSave = addressToSave.copyWith(isDefault: true);
    }

    _allAddresses.add(addressToSave);
    await _saveAddresses();

    return addressToSave;
  }

  static Future<bool> updateAddress(DeliveryAddress updatedAddress) async {
    final index = _allAddresses.indexWhere((addr) => addr.id == updatedAddress.id);
    if (index == -1) return false;

    if (updatedAddress.isDefault) {
      _clearDefault(updatedAddress.userId, excludeId: updatedAddress.id);
    }

    _allAddresses[index] = updatedAddress;
    await _saveAddresses();
    return true;
  }

  static Future<bool> deleteAddress(String addressId) async {
    final initialLength = _allAddresses.length;
    //final deletedAddress = _allAddresses.firstWhere((addr) => addr.id == addressId);

    _allAddresses.removeWhere((addr) => addr.id == addressId);

    final remaining = getAddressesForCurrentUser();
    if (remaining.isNotEmpty && !remaining.any((addr) => addr.isDefault)) {
      final firstRemainingId = remaining.first.id;
      final indexToUpdate = _allAddresses.indexWhere((addr) => addr.id == firstRemainingId);

      if (indexToUpdate != -1) {
        _allAddresses[indexToUpdate] = _allAddresses[indexToUpdate].copyWith(isDefault: true);
      }
    }

    if (_allAddresses.length < initialLength) {
      await _saveAddresses();
      return true;
    }
    return false;
  }

  static void _clearDefault(String userId, {String? excludeId}) {
    final indicesToUpdate = <int>[];

    for (int i = 0; i < _allAddresses.length; i++) {
      var addr = _allAddresses[i];
      if (addr.userId == userId && addr.id != excludeId && addr.isDefault) {
        indicesToUpdate.add(i);
      }
    }

    for (var index in indicesToUpdate) {
      _allAddresses[index] = _allAddresses[index].copyWith(isDefault: false);
    }
  }
}