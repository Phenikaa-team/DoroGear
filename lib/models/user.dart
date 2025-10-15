import '../helpers/enums/user_role.dart';
import 'model_interfaces.dart';

class User implements IModel {
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? phoneNumber;

  User({
    required this.name,
    required this.email,
    required this.password,
    this.role = UserRole.customer,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'customer'),
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? password,
    String? phoneNumber,
    UserRole? role,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'role': role.name,
    'phoneNumber': phoneNumber,
  };
}