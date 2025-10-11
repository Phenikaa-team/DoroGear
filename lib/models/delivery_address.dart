import 'model_interfaces.dart';

class DeliveryAddress implements IModel {
  final String id;
  final String userId;

  String receiverName;
  String receiverPhone;
  String fullAddress;
  String details;
  double latitude;
  double longitude;
  bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.userId,
    required this.receiverName,
    required this.receiverPhone,
    required this.fullAddress,
    required this.details,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      receiverName: json['receiverName'] as String,
      receiverPhone: json['receiverPhone'] as String,
      fullAddress: json['fullAddress'] as String,
      details: json['details'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDefault: json['isDefault'] as bool,
    );
  }

  DeliveryAddress copyWith({
    String? id,
    String? userId,
    String? receiverName,
    String? receiverPhone,
    String? fullAddress,
    String? details,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      fullAddress: fullAddress ?? this.fullAddress,
      details: details ?? this.details,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'receiverName': receiverName,
    'receiverPhone': receiverPhone,
    'fullAddress': fullAddress,
    'details': details,
    'latitude': latitude,
    'longitude': longitude,
    'isDefault': isDefault,
  };
}