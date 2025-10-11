import 'model_interfaces.dart';

class User implements IModel {
  final String name;
  final String email;
  final String password;
  final bool isAdmin;
  final String? phoneNumber;

  User({
    required this.name,
    required this.email,
    required this.password,
    this.isAdmin = false,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      isAdmin: json['isAdmin'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? password,
    String? phoneNumber,
    bool? isAdmin,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isAdmin: isAdmin ?? this.isAdmin,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'isAdmin': isAdmin,
    'phoneNumber': phoneNumber,
  };
}