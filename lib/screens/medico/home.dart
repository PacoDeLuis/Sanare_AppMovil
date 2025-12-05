import 'package:flutter/material.dart';
// Importaciones requeridas
import 'package:sanare/screens/medico/consultorio.dart';
import 'package:sanare/services/auth_service.dart';
import 'package:sanare/screens/splash_wrapper.dart';
import 'package:sanare/services/clinica_service.dart';
import 'package:sanare/screens/medico/perfil.dart';
import 'package:sanare/themes/app_colors.dart';
import 'package:sanare/themes/app_styles.dart';
import 'package:sanare/themes/app_text.dart';


// ----------------------------------------------------------------------
// --- 1. MODELO DE DATOS: Clinica (SIN CAMBIOS) ---
// ----------------------------------------------------------------------

class Clinica {
  final int id;
  final String nombre;
  final String descripcion;
  final String ubicacion;
  final String horaApertura;
  final String horaCierre;
  final String? imagen;
  final double rating;

  Clinica({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    required this.horaApertura,
    required this.horaCierre,
    this.imagen,
    this.rating = 0.0,
  });

  factory Clinica.fromJson(Map<String, dynamic> json) {
    return Clinica(
      id: json['id'] as int,
      nombre: json['nombre'] as String? ?? 'Clínica Desconocida',
      descripcion: json['descripcion'] as String? ?? 'Sin descripción',
      ubicacion: json['ubicacion'] as String? ?? 'N/A',
      horaApertura: json['hora_apertura'] as String? ?? 'No definido',
      horaCierre: json['hora_cierre'] as String? ?? 'No definido',
      imagen: json['imagen'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ----------------------------------------------------------------------
// --- 2. WIDGET: ConsultorioDetailCard (REDISENADO) ---
// ----------------------------------------------------------------------

class ConsultorioDetailCard extends StatelessWidget {
  final Clinica clinic;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ConsultorioDetailCard({
    super.key,
    required this.clinic,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatTime(String time) {
    if (time.contains(':')) {
      return time.split(':').take(2).join(':');
    }
    return time;
  }

  // Helper para construir las filas de detalle con estilo de tarjeta
  Widget _buildDetailRow({required IconData icon, required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22), 
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.small.copyWith(
                    color: AppColors.textLight.withOpacity(0.8), // Título en color claro
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.bold, // Valor en negrita
                    color: AppColors.textDark, 
                  ), 
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.card.copyWith( 
        borderRadius: BorderRadius.circular(25), // Bordes más grandes y redondeados
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Imagen Grande con Sombra Interior
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            child: Stack(
              children: [
                clinic.imagen != null && clinic.imagen!.isNotEmpty
                    ? Image.network(
                        clinic.imagen!,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 220,
                            color: AppColors.primaryLight.withOpacity(0.3),
                            child: Center(
                              child: Icon(Icons.medical_services_rounded, color: AppColors.primary, size: 80),
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 220,
                        color: AppColors.primaryLight.withOpacity(0.3),
                        child: Center(
                          child: Icon(Icons.medical_services_rounded, color: AppColors.primary, size: 80),
                        ),
                      ),
                // Gradiente para el título sobre la imagen (opcional)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.textDark.withOpacity(0.8), Colors.transparent],
                      ),
                    ),
                    child: Text(
                      clinic.nombre,
                      style: AppText.h1.copyWith(fontSize: 24, color: Colors.white, height: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 2. Contenido del Consultorio
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // Rating y Descripción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        clinic.descripcion,
                        style: AppText.body.copyWith(color: AppColors.textLight, fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          clinic.rating.toStringAsFixed(1),
                          style: AppText.h2.copyWith(color: AppColors.textDark), 
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                const Divider(color: AppColors.background, height: 1), 
                const SizedBox(height: 20),

                // Lista de detalles organizada
                _buildDetailRow(
                  icon: Icons.bookmark_border,
                  title: 'Especialidad Principal',
                  value: clinic.descripcion.split(' y ').first,
                ),
                _buildDetailRow(
                  icon: Icons.pin_drop_outlined,
                  title: 'Ubicación Exacta',
                  value: clinic.ubicacion,
                ),
                _buildDetailRow(
                  icon: Icons.schedule_outlined,
                  title: 'Horario de Atención',
                  value: '${_formatTime(clinic.horaApertura)} - ${_formatTime(clinic.horaCierre)}',
                ),

                const SizedBox(height: 30),

                // Botones (Editar y Eliminar) - Usando FilledButton y OutlinedButton
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 20),
                        label: Text('Editar', style: AppText.button), 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, 
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_forever, size: 20),
                        label: Text('Eliminar', style: AppText.button.copyWith(color: AppColors.danger)), 
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.danger, width: 2),
                          foregroundColor: AppColors.danger,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// --- 3. WIDGET: ClinicCard (REDISENADO - Para lista) ---
// ----------------------------------------------------------------------

class ClinicCard extends StatelessWidget {
  final Clinica clinic;
  final VoidCallback onEdit;
  final VoidCallback onDelete;


  const ClinicCard({
    super.key,
    required this.clinic,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatTime(String time) {
    if (time.contains(':')) {
      return time.split(':').take(2).join(':');
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    // Usamos InkWell para que toda la tarjeta sea clickable
    return InkWell(
      onTap: onEdit, // Usar onEdit como acción principal de la tarjeta
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: AppStyles.card.copyWith( 
          borderRadius: BorderRadius.circular(15), 
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.5)), // Borde sutil
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Imagen/Placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: clinic.imagen != null && clinic.imagen!.isNotEmpty
                  ? Image.network(
                      clinic.imagen!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.apartment_outlined, color: AppColors.primary, size: 30),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.apartment_outlined, color: AppColors.primary, size: 30),
                    ),
            ),
            const SizedBox(width: 15),
            
            // Sección de Detalles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          clinic.nombre,
                          style: AppText.h2.copyWith(color: AppColors.primary, fontSize: 16), 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                           ...List.generate(5, (index) {
                            return Icon(
                              index < clinic.rating.floor()
                                  ? Icons.star
                                  : (index < clinic.rating ? Icons.star_half : Icons.star_border),
                              color: Colors.amber,
                              size: 14,
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Descripción/Especialidad
                  Text(
                    clinic.descripcion,
                    style: AppText.small.copyWith(color: AppColors.textLight), 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Ubicación y Horario
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: AppColors.primaryLight, size: 16),
                          const SizedBox(width: 5),
                          Text(clinic.ubicacion,
                              style: AppText.small.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time_outlined, color: AppColors.primaryLight, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            '${_formatTime(clinic.horaApertura)} - ${_formatTime(clinic.horaCierre)}',
                            style: AppText.small.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Sección de Acciones (Trailing)
            Column(
              children: [
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                  ),
                ),
                const SizedBox(height: 5),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// --- 4. VISTAS: ConsultorioView (REDISENADO) ---
// ----------------------------------------------------------------------

class ConsultorioView extends StatefulWidget {
  final VoidCallback onCreateNewConsultorio;

  const ConsultorioView({super.key, required this.onCreateNewConsultorio});

  @override
  State<ConsultorioView> createState() => _ConsultorioViewState();
}

class _ConsultorioViewState extends State<ConsultorioView> {
  final ClinicaService _clinicaService = ClinicaService();
  List<Clinica> _myClinicas = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController(); // Nuevo controlador

  @override
  void initState() {
    super.initState();
    _fetchClinicas();
  }
  
  // Se deja la función _fetchClinicas sin cambios
  Future<void> _fetchClinicas() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Map<String, dynamic>> data = await _clinicaService.getMyClinicas();

      if (!mounted) return;
      setState(() {
        _myClinicas = data.map((json) => Clinica.fromJson(json)).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Error al cargar consultorios: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onEdit(Clinica clinic) async {
    final bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultorioScreen(
          initialData: {
            'id': clinic.id,
            'nombre': clinic.nombre,
            'descripcion': clinic.descripcion,
            'ubicacion': clinic.ubicacion,
            'hora_apertura': clinic.horaApertura,
            'hora_cierre': clinic.horaCierre,
          },
        ),
      ),
    );
    if (updated == true) {
      _fetchClinicas();
    }
  }

  void _onDelete(Clinica clinic) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Confirmar Eliminación', style: AppText.h2.copyWith(color: AppColors.danger)),
        content: Text('¿Estás seguro de que quieres eliminar "${clinic.nombre}"?', style: AppText.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: TextStyle(color: AppColors.primary)), 
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _clinicaService.deleteClinica(clinic.id);
        _fetchClinicas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Consultorio eliminado con éxito.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
          );
        }
      }
    }
  }

  // BARRRA DE BÚSQUEDA REDISEÑADA
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.background, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textLight.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _searchController,
        style: AppText.body.copyWith(color: AppColors.textDark), 
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o ubicación...',
          hintStyle: AppText.body.copyWith(color: AppColors.textLight), 
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: AppColors.primaryLight), 
          suffixIcon: IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primary),
            onPressed: () {
              // TODO: Implementar un modal o bottom sheet para filtros avanzados
            },
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
  
  // WIDGET PARA EL BOTÓN DE AGREGAR CONSULTORIO (más prominente)
  Widget _buildAddButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: widget.onCreateNewConsultorio,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white), 
        label: Text(
          'Agregar Nuevo Consultorio',
          style: AppText.button, 
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title;
    
    if (_isLoading) {
      title = 'Cargando Consultorios...';
    } else if (_myClinicas.length == 0) {
      title = '¡Bienvenido!';
    } else if (_myClinicas.length == 1) {
      title = 'Mi Consultorio';
    } else {
      title = 'Mis Consultorios (${_myClinicas.length})';
    }

    Widget content;

    if (_isLoading) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: CircularProgressIndicator(color: AppColors.primary), 
        ),
      );
    } else if (_errorMessage != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            _errorMessage!,
            style: AppText.body.copyWith(color: AppColors.danger), 
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (_myClinicas.isEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0),
          child: Column(
            children: [
              Icon(Icons.apartment_outlined, size: 80, color: AppColors.textLight.withOpacity(0.5)),
              const SizedBox(height: 15),
              Text(
                'Aún no tienes consultorios registrados.\nCrea tu primer consultorio ahora.',
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(color: AppColors.textLight), 
              ),
            ],
          ),
        ),
      );
    } else if (_myClinicas.length == 1) {
      // Mostrar la tarjeta de detalle para un solo consultorio
      content = ConsultorioDetailCard(
        clinic: _myClinicas.first,
        onEdit: () => _onEdit(_myClinicas.first),
        onDelete: () => _onDelete(_myClinicas.first),
      );
    } else {
      // Mostrar la lista para más de un consultorio
      content = Column(
        children: _myClinicas.map((clinica) => ClinicCard(
            clinic: clinica,
            onEdit: () => _onEdit(clinica),
            onDelete: () => _onDelete(clinica),
          )).toList(),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchClinicas,
      color: AppColors.primary, 
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 80.0), // Padding inferior extra por el Bottom Bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botón de Agregar Consultorio siempre visible en la parte superior
            _buildAddButton(),
            const SizedBox(height: 30),
            
            // Título
            Text(
              title,
              style: AppText.h1.copyWith(color: AppColors.textDark, fontSize: 28), 
            ),
            const SizedBox(height: 10),

            // Barra de búsqueda (solo si hay más de 1 consultorio)
            if (_myClinicas.length > 1) ...[
              _buildSearchBar(),
              const SizedBox(height: 20),
            ],
            
            // Contenido principal
            content,
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// --- 5. VISTAS: NotificacionesView (REDISENADO) ---
// ----------------------------------------------------------------------

class NotificacionesView extends StatelessWidget {
  const NotificacionesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_active_outlined, size: 60, color: AppColors.primary),
            ),
            const SizedBox(height: 30),
            Text(
              'Bandeja de Notificaciones',
              style: AppText.h1.copyWith(color: AppColors.textDark), 
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Recibirás alertas sobre citas, mensajes y recordatorios importantes de la plataforma.',
              style: AppText.body.copyWith(color: AppColors.textLight), 
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Un botón de ejemplo o acción
            TextButton.icon(
              onPressed: () {
                // Acción de ir a configuración de notificaciones
              },
              icon: Icon(Icons.settings_outlined, color: AppColors.primary),
              label: Text('Ajustar Preferencias', style: AppText.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// --- 6. WIDGET PRINCIPAL: MedicoHomeScreen (REDISENADO) ---
// ----------------------------------------------------------------------

class MedicoHomeScreen extends StatefulWidget {
  const MedicoHomeScreen({super.key});

  @override
  State<MedicoHomeScreen> createState() => _MedicoHomeScreenState();
}

class _MedicoHomeScreenState extends State<MedicoHomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final GlobalKey<_ConsultorioViewState> _consultorioViewKey = GlobalKey<_ConsultorioViewState>();
  
  // Función de callback para crear nuevo consultorio
  void _onCreateNewConsultorio() async {
    final bool? registered = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConsultorioScreen()),
    );
    if (registered == true) {
      _consultorioViewKey.currentState?._fetchClinicas();
    }
  }

  // LISTA DE VISTAS 
  late final List<Widget> _views = <Widget>[
    ConsultorioView(
      key: _consultorioViewKey,
      onCreateNewConsultorio: _onCreateNewConsultorio,
    ), 
    const NotificacionesView(), 
    const MedicoProfileScreen(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Función para obtener el título de la App Bar
  String _getAppBarTitleText() {
    return 'SANARE';
  }

  void _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashWrapper()),
        (route) => false,
      );
    }
  }

  List<Widget> _getAppBarActions(BuildContext context) {
    return [
      PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'logout') _handleLogout();
        },
        // Icono de perfil más grande y prominentemente en la esquina
        icon: const Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Icon(Icons.person_pin, color: Colors.white, size: 30),
        ),
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.exit_to_app, color: AppColors.danger), 
                const SizedBox(width: 8),
                Text('Cerrar Sesión', style: AppText.body.copyWith(color: AppColors.danger)),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // APP BAR - Mejor branding
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary, 
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
            children: [
              // LOGO DE LA APP (Asumiendo que logo_sanare.png tiene fondo transparente)
              Image.asset(
                'assets/logo_sanare.png', 
                height: 35, 
              ),
              const SizedBox(width: 10), 
              // TÍTULO DE LA APP
              Text(
                _getAppBarTitleText(),
                style: AppText.h2.copyWith(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
            ],
          ),
        ),
        actions: [
          // Botón de Perfil/Logout
          ..._getAppBarActions(context),
        ],
      ),
      
      body: SafeArea(
        child: _views.elementAt(_selectedIndex),
      ),
      
      // BARRA DE NAVEGACIÓN INFERIOR (BottomNavigationBar) - Estilo mejorado
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.apartment_outlined),
              activeIcon: Icon(Icons.apartment),
              label: 'Consultorios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Alertas', // Etiqueta más concisa
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primary, 
          unselectedItemColor: AppColors.textLight.withOpacity(0.8), // Gris más sutil
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent, // Transparente para usar el color del Container
          elevation: 0, // La elevación viene del Container
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: AppText.small.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppText.small,
        ),
      ),
    );
  }
}