import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:sanare/services/api_constants.dart';
import 'package:sanare/services/secure_storage_service.dart';

/// Tiempo máximo permitido para solicitudes API
const Duration _kApiTimeout = Duration(seconds: 20);

class AuthService {
  final SecureStorageService _storageService = SecureStorageService();

  // -------------------------------------------------------------------
  // ⭐ MÉTODO UTILIZADO POR OTROS SERVICIOS (Medico, Cita, Clinica)
  // -------------------------------------------------------------------
  Future<String?> getAuthToken() async {
    return _storageService.getAccessToken();
  }

  // ⭐ NUEVO MÉTODO REQUERIDO: Obtener el ID del usuario (paciente)
  // El ID se obtiene del storage (guardado durante el login)
  Future<int?> getCurrentUserId() async {
    final String? idStr = await _storageService.getUserId();
    if (idStr != null) {
      try {
        return int.parse(idStr);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // -------------------------------------------------------------------
  // ⭐ UTILIDAD: FORMATEAR FECHA (DD/MM/AAAA → YYYY-MM-DD)
  // -------------------------------------------------------------------
  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
    } catch (e) {
      print('Error al parsear fecha $dateString: $e');
    }

    if (dateString.contains('/')) {
      throw FormatException(
        'El formato de fecha $dateString no es válido. Se espera DD/MM/AAAA.',
      );
    }

    return dateString;
  }

  // -------------------------------------------------------------------
  // ⭐ REFRESH TOKEN (CON VALIDACIÓN Y LIMPIEZA CORRECTA)
  // -------------------------------------------------------------------
  Future<String?> refreshToken() async {
    final refreshToken = await _storageService.getRefreshToken();

    if (refreshToken == null) {
      await _storageService.clearAll();
      return null;
    }

    print('Intentando refrescar token...');

    try {
      final response = await http
          .post(
            Uri.parse(kRefreshTokenUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': refreshToken}),
          )
          .timeout(_kApiTimeout);

      final responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final newAccess = data['access'];

        if (newAccess == null) {
          throw Exception('El backend no devolvió un nuevo access token.');
        }

        await _storageService.saveAccessToken(newAccess);
        print('Token refrescado correctamente.');
        return newAccess;
      } else {
        await _storageService.clearAll();

        try {
          final errorJson = jsonDecode(responseBody);
          throw Exception(errorJson['detail'] ?? 'Sesión expirada.');
        } catch (_) {
          throw Exception('Error inesperado al refrescar token.');
        }
      }
    } catch (e) {
      await _storageService.clearAll();
      throw Exception('Fallo de conexión o sesión expirada: $e');
    }
  }

  // -------------------------------------------------------------------
  // ⭐ HANDLER PARA PETICIONES CON TOKEN + AUTO-REFRESH
  // -------------------------------------------------------------------
  Future<http.Response> _handleTokenRefreshAndRetry(
    Future<http.Response> Function(String token) apiCall,
  ) async {
    String? token = await _storageService.getAccessToken();

    if (token == null) throw Exception('No hay token. Inicia sesión.');

    http.Response response = await apiCall(token);

    if (response.statusCode == 401) {
      print('Token expirado, intentando refrescar...');
      final newToken = await refreshToken();

      if (newToken != null) {
        response = await apiCall(newToken);
      } else {
        throw Exception('Sesión expirada. Inicia sesión de nuevo.');
      }
    }

    return response;
  }

  // -------------------------------------------------------------------
  // ⭐ LOGIN (Modificado para guardar el user ID)
  // -------------------------------------------------------------------
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http
        .post(
          Uri.parse(kLoginUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(_kApiTimeout);

    final responseBody = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);

      final access = data['access'];
      final refresh = data['refresh'];

      if (access == null || refresh == null) {
        throw Exception('El backend no envió tokens de acceso/refresh.');
      }

      await _storageService.saveAccessToken(access);
      await _storageService.saveRefreshToken(refresh);

      final profile = await fetchUserProfile();
      
      // ⭐ MODIFICACIÓN CLAVE: Guardar el ID del usuario
      final int userId = profile['id'] as int;
      await _storageService.saveUserId(userId.toString()); 

      final role = profile['is_medico'] == true ? 'medico' : 'paciente';

      await _storageService.saveUserRole(role);

      return {
        'success': true,
        'message': 'Inicio de sesión exitoso',
        'role': role
      };
    } else {
      try {
        final errorJson = jsonDecode(responseBody);
        throw Exception(errorJson['detail'] ?? 'Credenciales inválidas.');
      } catch (_) {
        throw Exception('Error inesperado en el login.');
      }
    }
  }

  // -------------------------------------------------------------------
  // ⭐ PERFIL DE USUARIO
  // -------------------------------------------------------------------
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final apiCall = (String token) => http
        .get(
          Uri.parse(kProfileUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(_kApiTimeout);

    final response = await _handleTokenRefreshAndRetry(apiCall);

    final responseBody = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      await _storageService.clearAll();

      try {
        final errorJson = jsonDecode(responseBody);
        throw Exception('Error al obtener perfil: ${errorJson['detail']}');
      } catch (_) {
        throw Exception('Error inesperado al obtener perfil.');
      }
    }
  }

  // -------------------------------------------------------------------
  // ⭐ REGISTRO PACIENTE
  // -------------------------------------------------------------------
  Future<void> registerPaciente({
    required String username,
    required String email,
    required String password,
    required String password2,
    required String first_name,
    required String last_name,
    required String fecha_nacimiento,
    required String sexo,
    required String phone,
  }) async {
    final formattedDate = _formatDate(fecha_nacimiento);

    final response = await http
        .post(
          Uri.parse(kRegisterPacienteUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'email': email,
            'password': password,
            'password2': password2,
            'first_name': first_name,
            'last_name': last_name,
            'fecha_nacimiento': formattedDate,
            'sexo': sexo,
            'telefono': phone,
          }),
        )
        .timeout(_kApiTimeout);

    if (response.statusCode != 201) {
      final responseBody = utf8.decode(response.bodyBytes);
      final errorJson = jsonDecode(responseBody);

      String errorMessage = 'Error de registro.';

      if (errorJson['detail'] != null) {
        errorMessage = errorJson['detail'];
      } else if (errorJson.values.isNotEmpty) {
        final first = errorJson.values.first;
        errorMessage = first is List ? first.first : first.toString();
      }

      throw Exception(errorMessage);
    }
  }

  // -------------------------------------------------------------------
  // ⭐ REGISTRO MÉDICO
  // -------------------------------------------------------------------
  Future<void> registerMedico({
    required String username,
    required String email,
    required String password,
    required String password2,
    required String first_name,
    required String last_name,
    required String fecha_nacimiento,
    required String sexo,
    required String phone,
    required String cedula,
    required String especialidad,
  }) async {
    final formattedDate = _formatDate(fecha_nacimiento);

    final response = await http
        .post(
          Uri.parse(kRegisterMedicoUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'email': email,
            'password': password,
            'password2': password2,
            'first_name': first_name,
            'last_name': last_name,
            'fecha_nacimiento': formattedDate,
            'sexo': sexo,
            'telefono': phone,
            'cedula': cedula,
            'especialidad': especialidad,
          }),
        )
        .timeout(_kApiTimeout);

    if (response.statusCode != 201) {
      final responseBody = utf8.decode(response.bodyBytes);
      final errorJson = jsonDecode(responseBody);

      String errorMessage = 'Error de registro.';

      if (errorJson['detail'] != null) {
        errorMessage = errorJson['detail'];
      } else if (errorJson.values.isNotEmpty) {
        final first = errorJson.values.first;
        errorMessage = first is List ? first.first : first.toString();
      }

      throw Exception(errorMessage);
    }
  }

  // -------------------------------------------------------------------
  // ⭐ LOGOUT
  // -------------------------------------------------------------------
  Future<void> logout() async {
    await _storageService.clearAll();
  }
}