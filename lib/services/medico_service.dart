import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sanare/services/api_constants.dart';
import 'package:sanare/services/auth_service.dart';

// No es necesario, pero lo mantenemos para referencia si lo usabas en otras partes.
// const String _medicoEndpoint = '/clinicas/'; 

class MedicoService {
  final AuthService _authService = AuthService(); 

  Future<String> _getAuthToken() async {
    final token = await _authService.getAuthToken(); 
    
    if (token == null) {
      throw Exception('Usuario no autenticado. Token no disponible.');
    }
    return token;
  }

  // --- OTRAS FUNCIONES ---

  // 1. getDoctorsByClinic (Anulada)
  // Dejar esta función como estaba, ya que no es la que causa el error.
  Future<List<Map<String, dynamic>>> getDoctorsByClinic(int clinicaId, {required String fecha}) async {
    throw Exception('La función getDoctorsByClinic no aplica para el agendamiento con fecha. Use getAvailableTimeSlots.');
  }


  // 2. getAvailableTimeSlots (Función para cargar horarios)
  Future<List<String>> getAvailableTimeSlots(int clinicaId, {required String fecha}) async {
    final token = await _getAuthToken(); 
    
    // ⭐⭐ SOLUCIÓN AL ERROR 404 ⭐⭐
    // Se construye la URL para asegurar que incluye el prefijo '/api/' antes de '/clinicas/'.
    // Esto coincide con el endpoint de Django: /api/clinicas/<id>/horarios_disponibles/
    final url = Uri.parse(
        '$kBaseUrl/api/clinicas/$clinicaId/horarios_disponibles/?fecha=$fecha',
    ); 

    try {
      final response = await http.get(
          url,
          headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
          },
      );
      
      final responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
          final List<dynamic> jsonResponse = json.decode(responseBody);
          return jsonResponse.cast<String>(); 
          
      } else {
          String errorMessage = 'Error ${response.statusCode}: ';
          try {
              final errorJson = json.decode(responseBody);
              // Capturamos el mensaje de error si está en el campo 'error' o 'detail'
              errorMessage += errorJson['error'] ?? errorJson['detail'] ?? 'Respuesta inesperada.';
          } catch (_) {
              errorMessage += 'Respuesta inesperada del servidor.';
          }
          // El error original era: Error 404: Respuesta inesperada del servidor
          throw Exception(errorMessage);
      }
    } on Exception {
        rethrow;
    } catch (e) {
        throw Exception('Error desconocido al cargar horarios: ${e.toString()}');
    }
  }
}