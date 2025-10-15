enum UserRole {
  customer,
  employee,
  admin;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
          (e) => e.name == role.toLowerCase(),
      orElse: () => UserRole.customer,
    );
  }
}