import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserService {
  static const String _userKey = 'app_users';
  static User? _currentUser;

  static final Map<String, User> _users = {};
  static bool _isInitialized = false;

  static const String adminEmail = 'admin@doro.com';
  static const String adminPassword = 'admin';
  static const String adminName = 'Doro Gear Admin';

  static User? get currentUser => _currentUser;
  static bool get isGuest => _currentUser == null;

  static Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final userListJson = _users.values.map((user) => user.toJson()).toList();
    await prefs.setString(_userKey, json.encode(userListJson));
  }

  static Future<bool> deleteUser() async {
    if (isGuest) return false;

    final userEmail = _currentUser!.email.toLowerCase();
    final isRemoved = _users.remove(userEmail) != null;

    if (isRemoved) {
      signOut();
      await _saveUsers();
    }

    return isRemoved;
  }

  static Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final userListString = prefs.getString(_userKey);

    if (userListString != null) {
      final List<dynamic> userListJson = json.decode(userListString);
      _users.clear();
      for (var json in userListJson) {
        final user = User.fromJson(json);
        _users[user.email.toLowerCase()] = user;
      }
    }
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadUsers();

    if (!_users.containsKey(adminEmail)) {
      _users[adminEmail] = User(
        name: adminName,
        email: adminEmail,
        password: adminPassword,
        isAdmin: true,
      );
    }
    await _saveUsers();

    _isInitialized = true;
  }

  static bool isEmailRegistered(String email) {
    return _users.containsKey(email.toLowerCase());
  }

  static bool registerUser({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) {
    final lowerEmail = email.toLowerCase();
    if (isEmailRegistered(lowerEmail)) {
      return false;
    }

    final newUser = User(
      name: name,
      email: lowerEmail,
      phoneNumber: phoneNumber,
      password: password,
      isAdmin: false,
    );

    _users[lowerEmail] = newUser;
    _saveUsers();

    return true;
  }

  static User? signIn(String email, String password) {
    final lowerEmail = email.toLowerCase();
    final user = _users[lowerEmail];

    if (user != null && user.password == password) {
      _currentUser = user;
      return user;
    }
    return null;
  }

  static void signOut() {
    _currentUser = null;
  }

  static bool isUserAdmin(User user) {
    return user.isAdmin;
  }

  static Future<bool> updateUser({
    required String oldEmail,
    String? newName,
    String? newEmail,
    String? newPhoneNumber,
  }) async {
    final lowerOldEmail = oldEmail.toLowerCase();
    User? user = _users[lowerOldEmail];

    if (user == null) return false;

    String targetEmail = newEmail?.toLowerCase() ?? lowerOldEmail;

    if (targetEmail != lowerOldEmail && _users.containsKey(targetEmail)) {
      return false;
    }

    if (targetEmail != lowerOldEmail) {
      _users.remove(lowerOldEmail);
    }

    final updatedUser = user.copyWith(
      name: newName,
      email: targetEmail,
      phoneNumber: newPhoneNumber,
    );

    _users[targetEmail] = updatedUser;
    _currentUser = updatedUser;
    await _saveUsers();

    return true;
  }
}