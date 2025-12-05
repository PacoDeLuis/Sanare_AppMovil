// lib/services/clinica_service.dart (COMPLETO)

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sanare/services/auth_service.dart';

// IMPORTANTE: Reemplaza con la URL base real de tu API
const String _baseUrl = 'http://10.0.2.2:8000/api';

class ClinicaService {
  // Instanciar AuthService
  final AuthService _authService = AuthService();

  // Obtener token de autorización
  Future<String> _getAuthToken() async {
    final token = await _authService.getAuthToken();
    if (token == null) {
      throw Exception('Usuario no autenticado. Token no disponible.');
    }
    return token;
  }

  // -------------------------------------------------------------------
  // OBTENER TODAS LAS CLÍNICAS (Paciente)
  // -------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getAllClinicas() async {
    final token = await _getAuthToken();
    final url = Uri.parse('$_baseUrl/clinicas/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse =
            json.decode(utf8.decode(response.bodyBytes));
        return jsonResponse
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        throw Exception('Error al cargar clínicas: ${errorBody.toString()}');
      }
    } catch (e) {
      throw Exception('Falló la conexión con el servidor: $e');
    }
  }

  // -------------------------------------------------------------------
  // OBTENER MIS CLÍNICAS (Médico)
  // -------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getMyClinicas() async {
    final token = await _getAuthToken();
    final url = Uri.parse('$_baseUrl/clinicas/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse =
            json.decode(utf8.decode(response.bodyBytes));
        return jsonResponse
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        throw Exception('Error al cargar clínicas: ${errorBody.toString()}');
      }
    } catch (e) {
      throw Exception('Falló la conexión con el servidor: $e');
    }
  }

  // -------------------------------------------------------------------
  // REGISTRAR UNA NUEVA CLÍNICA (POST - Multipart)
  // -------------------------------------------------------------------
  Future<bool> registerClinica({
    required String nombre,
    required String descripcion,
    required String ubicacion,
    required String horaApertura,
    required String horaCierre,
    required List<int> diasHabiles,
    File? imagen,
  }) async {
    final token = await _getAuthToken();
    final url = Uri.parse('$_baseUrl/clinicas/');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['nombre'] = nombre
      ..fields['descripcion'] = descripcion
      ..fields['ubicacion'] = ubicacion
      ..fields['hora_apertura'] = horaApertura
      ..fields['hora_cierre'] = horaCierre;

    for (var dia in diasHabiles) {
      request.fields.addAll({'dias_habiles': dia.toString()});
    }

    if (imagen != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'imagen',
          imagen.path,
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Error al registrar clínica: $responseBody');
    }
  }

  // -------------------------------------------------------------------
  // ACTUALIZAR CLÍNICA (PATCH - Multipart)
  // -------------------------------------------------------------------
  Future<void> updateClinica({
    required int id,
    required String nombre,
    required String descripcion,
    required String ubicacion,
    required String horaApertura,
    required String horaCierre,
    required List<int> diasHabiles,
    File? imagen,
  }) async {
    final token = await _getAuthToken();
    final url = Uri.parse('$_baseUrl/clinicas/$id/');

    final request = http.MultipartRequest('PATCH', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['nombre'] = nombre
      ..fields['descripcion'] = descripcion
      ..fields['ubicacion'] = ubicacion
      ..fields['hora_apertura'] = horaApertura
      ..fields['hora_cierre'] = horaCierre;

    for (var dia in diasHabiles) {
      request.fields.addAll({'dias_habiles': dia.toString()});
    }

    if (imagen != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'imagen',
          imagen.path,
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(
        'Error al actualizar clínica (Código ${response.statusCode}): $responseBody',
      );
    }
  }

  // -------------------------------------------------------------------
  // 🗑️ ELIMINAR CLÍNICA (DELETE) 🗑️
  // -------------------------------------------------------------------
  /// Envía una solicitud HTTP DELETE a la API para eliminar una clínica por su ID.
  Future<void> deleteClinica(int clinicaId) async {
    final token = await _getAuthToken();
    // Construir la URL con el ID de la clínica
    final url = Uri.parse('$_baseUrl/clinicas/$clinicaId/'); 

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Los códigos de éxito comunes para DELETE son 204 (No Content) o 200 (OK).
      if (response.statusCode == 204 || response.statusCode == 200) {
        return; 
      } else {
        // Si hay un error, decodificamos el cuerpo para un mensaje más informativo.
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(
          'Fallo al eliminar el consultorio (Código ${response.statusCode}): ${errorBody.toString()}',
        );
      }
    } catch (e) {
      // Manejo de errores de conexión o excepciones.
      throw Exception('Falló la conexión con el servidor al intentar eliminar: $e');
    }
  }
}