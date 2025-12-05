import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanare/services/cita_service.dart';

// Colores de Sanare (Definiciones consolidadas)
const Color sanareBlue = Color(0xFF4A688A);
const Color sanareAccent = Color(0xFF26C6DA);
const Color sanareLightGray = Color(0xFFF5F5F5);
const Color sanareDarkText = Color(0xFF333333);
const Color statusPending = Color(0xFFFFC107);
const Color statusCompleted = Color(0xFF4CAF50);
const Color statusCancelled = Color(0xFFF44336);

class MisCitasScreen extends StatefulWidget {
  const MisCitasScreen({super.key});

  @override
  State<MisCitasScreen> createState() => _MisCitasScreenState();
}

class _MisCitasScreenState extends State<MisCitasScreen> {
  final CitaService _citaService = CitaService();
  late Future<List<Map<String, dynamic>>> _citasFuture;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'es';
    _citasFuture = _citaService.getMyCitas();
  }

  void _refreshCitas() {
    setState(() {
      _citasFuture = _citaService.getMyCitas();
    });
  }

  // --- Lógica de Estado de Cita ---
  Map<String, dynamic> _getStatus(Map<String, dynamic> citaData) {
    final bool isCompleted = citaData['completada'] == true;
    final String? estadoRaw = citaData['estado']?.toString();

    if (isCompleted) {
      return {
        'text': 'Completada',
        'color': statusCompleted,
        'icon': Icons.check_circle
      };
    }

    if (estadoRaw != null) {
      switch (estadoRaw.toUpperCase()) {
        case 'PENDIENTE':
          return {
            'text': 'Pendiente',
            'color': statusPending,
            'icon': Icons.schedule
          };
        case 'CANCELADA':
          return {
            'text': 'Cancelada',
            'color': statusCancelled,
            'icon': Icons.cancel
          };
        case 'COMPLETADA':
          return {
            'text': 'Completada',
            'color': statusCompleted,
            'icon': Icons.check_circle
          };
      }
    }

    return {'text': 'Pendiente', 'color': statusPending, 'icon': Icons.schedule};
  }

  // --- Lógica de Cancelación ---
  void _cancelarCita(int citaId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cancelación'),
        content: const Text(
          '¿Estás seguro de que quieres cancelar esta cita? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No, Mantener', style: TextStyle(color: sanareBlue)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: statusCancelled),
            child: const Text('Sí, Cancelar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cancelando cita $citaId...'),
        backgroundColor: sanareBlue,
      ),
    );

    try {
      await _citaService.cancelarCita(citaId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita cancelada con éxito.'),
          backgroundColor: statusCompleted,
        ),
      );

      _refreshCitas();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cancelar: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: statusCancelled,
        ),
      );
    }
  }

  // --- Widget Principal ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sanareLightGray,
      appBar: AppBar(
        title: const Text(
          'Mis Citas Agendadas',
          style: TextStyle(
            color: sanareDarkText,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: sanareAccent),
            onPressed: _refreshCitas,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshCitas(),
        color: sanareAccent,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _citasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: sanareAccent),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Error al cargar citas: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: sanareDarkText),
                  ),
                ),
              );
            }

            final citas = snapshot.data!;
            if (citas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.event_busy, size: 80, color: sanareBlue),
                    SizedBox(height: 10),
                    Text(
                      'No tienes citas agendadas.',
                      style: TextStyle(fontSize: 18, color: sanareDarkText),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '¡Busca un médico para comenzar!',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: citas.length,
              itemBuilder: (context, index) {
                final cita = citas[index];
                final statusData = _getStatus(cita);

                DateTime fechaHora;
                try {
                  final fechaStr = cita['fecha_hora'] as String?;
                  fechaHora = fechaStr != null
                      ? DateTime.parse(fechaStr).toLocal()
                      : DateTime.now();
                } catch (_) {
                  fechaHora = DateTime.now();
                }

                final fecha = DateFormat('EEEE, d MMMM', 'es').format(fechaHora);
                final hora = DateFormat('hh:mm a').format(fechaHora);

                final doctor = cita['medico_nombre'] ?? 'Dr. Médico no asignado';
                final especialidad =
                    cita['medico']?['especialidad_nombre'] ?? 'General';

                final clinica = cita['clinica'] ?? {};
                final clinicName = clinica['nombre'] ?? 'Clínica desconocida';
                final ubicacion =
                    clinica['ubicacion'] ?? 'Ubicación no disponible';

                return _buildCitaCard(
                  context,
                  fecha: fecha,
                  hora: hora,
                  doctor: doctor,
                  especialidad: especialidad,
                  clinica: clinicName,
                  ubicacion: ubicacion,
                  estado: statusData['text'],
                  estadoColor: statusData['color'],
                  estadoIcon: statusData['icon'],
                  citaId: cita['id'] ?? 0,
                );
              },
            );
          },
        ),
      ),
    );
  }

  // --- Tarjeta de Cita ---
  Widget _buildCitaCard(
    BuildContext context, {
    required String fecha,
    required String hora,
    required String doctor,
    required String especialidad,
    required String clinica,
    required String ubicacion,
    required String estado,
    required Color estadoColor,
    required IconData estadoIcon,
    required int citaId,
  }) {
    final bool canCancel = estado == 'Pendiente';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: sanareBlue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: sanareLightGray,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: Border(
                bottom: BorderSide(
                  color: sanareBlue.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time,
                          color: sanareBlue, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '$fecha | $hora',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(estadoIcon, color: estadoColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        estado,
                        style: TextStyle(
                          color: estadoColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // CUERPO
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.person_pin,
                        color: sanareAccent, size: 35),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. $doctor',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: sanareBlue,
                          ),
                        ),
                        Text(
                          'Especialidad: $especialidad',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.apartment,
                        color: sanareBlue, size: 35),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clinica,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: sanareDarkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: sanareAccent.withOpacity(0.8),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  ubicacion,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // FOOTER DE CANCELAR
          if (canCancel)
            Container(
              decoration: BoxDecoration(
                color: sanareLightGray.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _cancelarCita(citaId),
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text(
                      'Cancelar Cita',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: statusCancelled,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
