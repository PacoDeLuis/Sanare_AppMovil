// lib/services/notificacion_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sanare/services/auth_service.dart';
// Asegúrate de que esta ruta sea correcta


// --- Modelo de Datos ---
class Notificacion {
  final int id;
  final String mensaje;
  final bool leida;
  final DateTime fechaCreacion;
  // Campos para el contexto
  final String pacienteNombre;
  final String clinicaNombre;
  final String fechaCita;
  final String horaCita;

  Notificacion({
    required this.id,
    required this.mensaje,
    required this.leida,
    required this.fechaCreacion,
    required this.pacienteNombre,
    required this.clinicaNombre,
    required this.fechaCita,
    required this.horaCita,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'],
      mensaje: json['mensaje'],
      leida: json['leida'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      // Los campos extra pueden ser nulos si la notificación no tiene contexto de cita
      pacienteNombre: json['paciente_nombre'] ?? 'N/A',
      clinicaNombre: json['clinica_nombre'] ?? 'N/A',
      fechaCita: json['fecha_cita'] ?? 'N/A',
      horaCita: json['hora_cita'] ?? 'N/A',
    );
  }
}

class NotificacionService {
  // 🚨 RECUERDA: Cambia '10.0.2.2' por la IP real de tu PC si usas un dispositivo físico.
  // Debe ser '10.0.2.2' para el emulador de Android.
  static const String _baseUrl = 'http://10.0.2.2:8000/api/'; 
  final AuthService _authService = AuthService();

  // Función para obtener las notificaciones
  Future<List<Notificacion>> getMyNotifications() async {
    final String? token = await _authService.getAuthToken();
    if (token == null) {
      throw Exception('Usuario no autenticado. Inicie sesión.');
    }

    final url = Uri.parse('${_baseUrl}notificaciones/my/');
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      // Ordenamos por fecha de creación descendente para asegurar que lo más nuevo esté arriba
      final notificaciones = jsonList.map((json) => Notificacion.fromJson(json)).toList();
      notificaciones.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      return notificaciones;
    } else {
      // 💡 Mejorado: Incluimos el código de estado para la depuración
      print('Error ${response.statusCode} al cargar notificaciones: ${response.body}');
      throw Exception('Fallo al cargar las notificaciones. Código de estado: ${response.statusCode}');
    }
  }
  
  // Función para marcar como leída
  Future<void> markAsRead(int id) async {
    final String? token = await _authService.getAuthToken();
    if (token == null) return; 

    final url = Uri.parse('${_baseUrl}notificaciones/$id/leer/'); 
    
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // Puedes enviar un body vacío si tu API lo requiere, o omitirlo si solo con PATCH es suficiente.
      // body: json.encode({}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      print('Error al marcar como leída Notif ID $id (Status ${response.statusCode}): ${response.body}');
      throw Exception('No se pudo marcar la notificación como leída');
    }
  }
}