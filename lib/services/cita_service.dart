import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sanare/services/auth_service.dart';
import 'package:sanare/services/api_constants.dart';
import 'dart:io';

class CitaService {
  final AuthService _authService = AuthService();

  // -------------------------------------------------------------------
  // TOKEN Y ID DEL PACIENTE
  // -------------------------------------------------------------------

  Future<String> _getAuthToken() async {
    final token = await _authService.getAuthToken();
    if (token == null) {
      throw Exception('Usuario no autenticado. Token no disponible.');
    }
    return token;
  }

  Future<int> _getPacienteId() async {
    final pacienteId = await _authService.getCurrentUserId();
    if (pacienteId == null || pacienteId == 0) {
      throw Exception(
        'ID del paciente no disponible. Por favor, inicia sesión nuevamente.',
      );
    }
    return pacienteId;
  }

  // -------------------------------------------------------------------
  // 1. AGENDAR CITA (POST)
  // -------------------------------------------------------------------

  Future<void> scheduleCita(
    Map<String, dynamic> citaData, {
    required int medicoId,
  }) async {
    final token = await _getAuthToken();
    final pacienteId = await _getPacienteId();

    citaData['paciente_id'] = pacienteId;
    citaData['medico_id'] = medicoId;

    final path = 'medicos/$medicoId/agendar-cita/';
    final url = Uri.parse('$kBaseUrl/api/$path');

    print('DEBUG → POST a: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(citaData),
      );

      final responseBody = utf8.decode(response.bodyBytes);
      print('DEBUG Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        return;
      } else {
        String errorMessage = 'Error al agendar cita: ';

        try {
          final errorBody = json.decode(responseBody);

          if (errorBody.containsKey('detail') && errorBody['detail'] != null) {
            errorMessage += errorBody['detail'].toString();
          } else if (errorBody.containsKey('error') &&
              errorBody['error'] != null) {
            errorMessage += errorBody['error'].toString();
          } else {
            errorMessage += errorBody.toString();
          }
        } catch (_) {
          errorMessage +=
              'Respuesta inesperada del servidor (Status: ${response.statusCode}).';
        }

        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception(
        'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    } catch (e) {
      throw Exception('Error inesperado al agendar: ${e.toString()}');
    }
  }

  // -------------------------------------------------------------------
  // 2. OBTENER MIS CITAS (GET)
  // -------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getMyCitas() async {
    final token = await _getAuthToken();

    final path = 'citas/my/';
    final url = Uri.parse('$kBaseUrl/api/$path');

    print('DEBUG → GET a: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseBody = utf8.decode(response.bodyBytes);
      print('DEBUG Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(responseBody);
        return jsonList
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        try {
          final errorBody = json.decode(responseBody);
          throw Exception(
            'Error al cargar citas (Status: ${response.statusCode}): ${errorBody.toString()}',
          );
        } catch (_) {
          throw Exception(
            'Respuesta inesperada del servidor (Status: ${response.statusCode}).',
          );
        }
      }
    } on SocketException {
      throw Exception(
        'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    } catch (e) {
      throw Exception('No se pudo obtener las citas: $e');
    }
  }

  // -------------------------------------------------------------------
  // 3. OBTENER HORARIOS DISPONIBLES (GET)
  // -------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getHorariosDisponibles({
    required int clinicaId,
    required String fecha,
  }) async {
    final token = await _getAuthToken();

    final path = 'clinicas/$clinicaId/horarios_disponibles/';
    final url = Uri.parse('$kBaseUrl/api/$path')
        .replace(queryParameters: {'fecha': fecha});

    print('DEBUG → GET Horarios a: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseBody = utf8.decode(response.bodyBytes);
      print('DEBUG Status Horarios: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(responseBody);
        return jsonList.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception(
          'Error al cargar horarios: Respuesta inesperada del servidor (Status: ${response.statusCode}).',
        );
      }
    } on SocketException {
      throw Exception(
        'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    } catch (e) {
      throw Exception('Error al obtener horarios: ${e.toString()}');
    }
  }

  // -------------------------------------------------------------------
  // 4. CANCELAR CITA (PATCH)
  // -------------------------------------------------------------------

  Future<void> cancelarCita(int citaId) async {
    final token = await _getAuthToken();

    final path = 'citas/$citaId/';
    final url = Uri.parse('$kBaseUrl/api/$path');

    print('DEBUG → PATCH a: $url (Cancelando Cita $citaId)');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'estado': 'CANCELADA'}),
      );

      final responseBody = utf8.decode(response.bodyBytes);
      print('DEBUG Status Cancelar: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 202) {
        return;
      } else {
        String errorMessage = 'Error al cancelar la cita: ';

        try {
          final errorBody = json.decode(responseBody);

          if (errorBody.containsKey('detail') && errorBody['detail'] != null) {
            errorMessage += errorBody['detail'];
          } else if (errorBody.containsKey('error') &&
              errorBody['error'] != null) {
            errorMessage += errorBody['error'];
          } else {
            errorMessage += errorBody.toString();
          }
        } catch (_) {
          errorMessage +=
              'Respuesta inesperada del servidor (Status: ${response.statusCode}).';
        }

        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception(
        'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    } catch (e) {
      throw Exception('Error inesperado al cancelar cita: ${e.toString()}');
    }
  }
}
