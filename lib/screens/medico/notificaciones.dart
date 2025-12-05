import 'package:flutter/material.dart';
// Asegúrate de que esta ruta sea correcta
import 'package:sanare/services/notificacion_service.dart'; 
// Asumo que Notificacion y NotificacionService están disponibles en este path

// Colores
const Color sanareBlue = Color(0xFF4A688A); // Azul principal
const Color sanareLightBlue = Color(0xFF8DAAC1); // Azul claro/secundario
const Color sanareDarkText = Color(0xFF333333); // Texto oscuro
const Color sanareLightGray = Color(0xFFF3F4F6); // Fondo de la pantalla
const Color sanareWhite = Colors.white;

// Función de utilidad para formatear la duración
String formatDuration(DateTime date) {
  final duration = DateTime.now().difference(date);

  if (duration.inDays > 0) {
    return 'Hace ${duration.inDays} ${duration.inDays == 1 ? 'día' : 'días'}';
  } else if (duration.inHours > 0) {
    return 'Hace ${duration.inHours} ${duration.inHours == 1 ? 'hora' : 'horas'}';
  } else if (duration.inMinutes > 0) {
    return 'Hace ${duration.inMinutes} ${duration.inMinutes == 1 ? 'minuto' : 'minutos'}';
  } else {
    return 'Ahora mismo';
  }
}

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  // Se inicializa como 'late' y se asigna en initState
  late Future<List<Notificacion>> _notificacionesFuture;
  final NotificacionService _notificacionService = NotificacionService();

  @override
  void initState() {
    super.initState();
    _fetchNotificaciones();
  }

  // Carga la lista de notificaciones y actualiza el estado (setState)
  void _fetchNotificaciones() {
    setState(() {
      _notificacionesFuture = _notificacionService.getMyNotifications();
    });
  }

  // Maneja el toque en la tarjeta para marcar como leída
  void _handleTap(Notificacion notificacion) async {
    // Si la notificación no está leída, intentamos marcarla como tal
    if (!notificacion.leida) {
      try {
        await _notificacionService.markAsRead(notificacion.id);
        // Si tiene éxito, recargamos la lista para actualizar la UI
        _fetchNotificaciones();
      } catch (e) {
        // Mostramos el error si el contexto está montado
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al marcar como leída: $e')),
          );
        }
      }
    }
  }

  // Card mejorado con un indicador visual de no leído y mejor espaciado
  Widget _buildNotificationCard(Notificacion notif) {
    // El indicador principal para el estado de lectura
    final bool isUnread = !notif.leida;
    final mainTitle = notif.mensaje;

    // Placeholder de Imagen con mejor integración al card
    final Widget imagePlaceholder = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        height: 140, // Altura ligeramente reducida para un look más compacto
        width: double.infinity,
        color: sanareLightGray,
        child: Image.network(
          'https://d1csarkz8obe9u.cloudfront.net/poster-thumbnails/Clinic_Building_1.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.local_hospital, color: sanareLightBlue, size: 40),
          ),
        ),
      ),
    );

    return InkWell(
      onTap: () => _handleTap(notif),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: sanareWhite,
          borderRadius: BorderRadius.circular(16),
          border: isUnread 
              ? Border.all(color: sanareBlue.withOpacity(0.5), width: 1.5) // Borde para no leído
              : null,
          boxShadow: [
            BoxShadow(
              color: isUnread ? sanareBlue.withOpacity(0.15) : Colors.black12.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imagePlaceholder,
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Punto de "No Leído"
                      if (isUnread)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red, // Rojo para un contraste fuerte
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          mainTitle,
                          style: TextStyle(
                            fontSize: 18,
                            // Negrita si NO está leída
                            fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                            color: sanareDarkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Usamos el nuevo Widget de fila de detalles con iconos
                  _buildDetailRow(Icons.business, 'Clínica', notif.clinicaNombre, !isUnread),
                  _buildDetailRow(Icons.calendar_today, 'Fecha', notif.fechaCita, !isUnread),
                  _buildDetailRow(Icons.access_time, 'Hora', notif.horaCita, !isUnread),
                  const Divider(height: 25, thickness: 1, color: sanareLightGray),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(notif.fechaCreacion),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      // Chip de estado (Nuevo o Leído)
                      if (isUnread)
                        _buildStatusChip('Nuevo', sanareBlue, sanareWhite)
                      else
                        _buildStatusChip('Leído', sanareLightGray, Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fila de detalles mejorada con un Icono a la izquierda
  Widget _buildDetailRow(IconData icon, String label, String value, bool isRead) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono dinámico
          Icon(
            icon,
            size: 18,
            color: isRead ? Colors.grey.shade400 : sanareBlue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      fontSize: 15,
                      color: sanareDarkText.withOpacity(0.7),
                      fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 15,
                      color: sanareDarkText,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20), // Más redondeado
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sanareLightGray,
      appBar: AppBar(
        title: const Text(
          'Mis Notificaciones', // Título ligeramente modificado
          style: TextStyle(fontWeight: FontWeight.w900, color: sanareDarkText, fontSize: 24),
        ),
        backgroundColor: sanareWhite,
        foregroundColor: sanareDarkText,
        // Eliminamos la elevación para un aspecto más plano y moderno
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: sanareBlue, size: 28),
            onPressed: _fetchNotificaciones,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
            child: Text(
              'Alertas y Recordatorios', // Título de sección más descriptivo
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: sanareDarkText,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Notificacion>>(
              future: _notificacionesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: sanareBlue),
                  );
                } else if (snapshot.hasError) {
                  // Muestra el error de conexión o autenticación
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 80, color: Colors.redAccent),
                          const SizedBox(height: 20),
                          const Text(
                            '¡Error de conexión!',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: sanareDarkText),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${snapshot.error}', // Muestra el mensaje de la excepción
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _fetchNotificaciones,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: sanareBlue, foregroundColor: sanareWhite),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Muestra el mensaje de lista vacía
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_none, size: 80, color: sanareLightBlue),
                          const SizedBox(height: 20),
                          const Text(
                            'No tienes notificaciones.',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: sanareDarkText),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Toda tu actividad y alertas importantes aparecerán aquí.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // Muestra la lista de notificaciones
                  final notificaciones = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    itemCount: notificaciones.length,
                    itemBuilder: (context, index) {
                      final notif = notificaciones[index];
                      return _buildNotificationCard(notif);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}