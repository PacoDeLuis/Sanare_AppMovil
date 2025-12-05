import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Inicializamos FlutterSecureStorage para el almacenamiento seguro
  final _storage = const FlutterSecureStorage();

  // Claves de almacenamiento
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userRoleKey = 'user_role';
  static const _userIdKey = 'user_id'; // ⭐ CLAVE AÑADIDA

  // --- MÉTODOS DE GUARDADO ---

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  // ⭐ NUEVO MÉTODO DE GUARDADO: Guardar el ID del usuario
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  // --- MÉTODOS DE LECTURA ---

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  // ⭐ NUEVO MÉTODO DE LECTURA: Obtener el ID del usuario
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // --- MÉTODO DE LIMPIEZA ---

  // Limpia todos los datos almacenados (útil para el Logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}