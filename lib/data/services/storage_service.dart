import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Token Management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }

  // User Management
  Future<void> saveUser(User user) async {
    await init();
    final userJson = jsonEncode(user.toJson());
    await _prefs!.setString(AppConstants.userKey, userJson);
    await _prefs!.setString(AppConstants.roleKey, user.role);
  }

  Future<User?> getUser() async {
    await init();
    final userJson = _prefs!.getString(AppConstants.userKey);
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    }
    return null;
  }

  Future<String?> getUserRole() async {
    await init();
    return _prefs!.getString(AppConstants.roleKey);
  }

  Future<void> deleteUser() async {
    await init();
    await _prefs!.remove(AppConstants.userKey);
    await _prefs!.remove(AppConstants.roleKey);
  }

  // Clear all data
  Future<void> clearAll() async {
    await init();
    await _secureStorage.deleteAll();
    await _prefs!.clear();
  }

  // Generic Methods
  Future<void> saveString(String key, String value) async {
    await init();
    await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await init();
    return _prefs!.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await init();
    await _prefs!.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    await init();
    return _prefs!.getBool(key);
  }

  Future<void> remove(String key) async {
    await init();
    await _prefs!.remove(key);
  }
}
