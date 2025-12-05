import 'package:flutter/material.dart';
import 'package:sanare/themes/app_colors.dart';
import 'package:sanare/themes/app_text.dart';

// Importaciones de tus modelos y servicios
import 'package:sanare/screens/models/clinica.dart';
import 'package:sanare/screens/paciente/perfil.dart'; // Asume que existe
import 'package:sanare/screens/splash_wrapper.dart'; // Asume que existe
import 'package:sanare/services/auth_service.dart'; // Asume que existe
import 'package:sanare/services/clinica_service.dart'; // Asume que existe
import 'package:sanare/screens/paciente/agendar_cita.dart'; // Asume que existe
import 'package:sanare/screens/paciente/mis_citas.dart'; // Asume que existe

// ======================================================================
// 1. ClinicCard (Tarjeta de Clínica) - MEJORADA
// ======================================================================
class ClinicCard extends StatelessWidget {
  final Clinica clinic;
  final Function(Clinica) onSelectClinic;

  const ClinicCard({super.key, required this.clinic, required this.onSelectClinic});

  String _formatTime(String time) {
    // Maneja casos donde la hora puede no estar en formato HH:MM:SS
    return time.length >= 5 ? time.substring(0, 5) : time;
  }

  @override
  Widget build(BuildContext context) {
    // Envuelve el Container en un InkWell para hacerlo completamente cliqueable con efecto de ripple.
    return InkWell(
      onTap: () => onSelectClinic(clinic),
      borderRadius: BorderRadius.circular(15), // Mismo borde que el Container
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen con bordes redondeados
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    clinic.imagen ?? 'https://placehold.co/90x90/CCCCCC/000000?text=No+Img',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.apartment, color: AppColors.primary, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre de la Clínica
                      Text(
                        clinic.nombre,
                        style: AppText.h2.copyWith(color: AppColors.primaryDark, fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Descripción (Especialidad)
                      Text(
                        clinic.descripcion,
                        style: AppText.body.copyWith(fontSize: 13, color: AppColors.textDark.withOpacity(0.7)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Ubicación
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 16),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              clinic.ubicacion,
                              style: AppText.body.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
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
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.primaryLight),
            const SizedBox(height: 10),
            // Horario y Rating/Botón Agendar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Horarios
                Row(
                  children: [
                    const Icon(Icons.schedule, color: AppColors.primary, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      '${_formatTime(clinic.horaApertura)} - ${_formatTime(clinic.horaCierre)}',
                      style: AppText.body.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                // Rating y Botón Agendar (Alineado a la derecha)
                Row(
                  children: [
                    // Rating
                    ...List.generate(5, (index) {
                      return Icon(
                        index < clinic.rating.floor()
                            ? Icons.star
                            : (index < clinic.rating ? Icons.star_half : Icons.star_border),
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                    const SizedBox(width: 10),
                    // Botón Agendar
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () => onSelectClinic(clinic),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Agendar',
                          style: AppText.button.copyWith(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// 2. BuscarClinicasView (Vista de la pestaña de búsqueda) - MEJORADA
// ======================================================================
class BuscarClinicasView extends StatefulWidget {
  const BuscarClinicasView({super.key});

  @override
  State<BuscarClinicasView> createState() => _BuscarClinicasViewState();
}

class _BuscarClinicasViewState extends State<BuscarClinicasView> {
  final ClinicaService _clinicaService = ClinicaService();

  List<Clinica> _allClinicas = [];
  List<Clinica> _filteredClinicas = [];

  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAllClinicas();
    _searchController.addListener(_filterClinicas);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterClinicas);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllClinicas() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Map<String, dynamic>> rawData = await _clinicaService.getAllClinicas();

      if (!mounted) return;
      setState(() {
        _allClinicas = rawData.map((json) => Clinica.fromJson(json)).toList();
        _filteredClinicas = _allClinicas;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        if (errorMsg.contains('Network is unreachable') || errorMsg.contains('Failed host lookup')) {
          errorMsg = 'Fallo la conexión con el servidor.';
        }
        _errorMessage = 'Error al cargar consultorios: $errorMsg';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterClinicas() {
    final String searchTerm = _searchController.text.toLowerCase();

    setState(() {
      if (searchTerm.isEmpty) {
        _filteredClinicas = _allClinicas;
      } else {
        _filteredClinicas = _allClinicas.where((clinica) {
          final name = clinica.nombre.toLowerCase();
          final description = clinica.descripcion.toLowerCase();
          final location = clinica.ubicacion.toLowerCase();

          return name.contains(searchTerm) ||
              description.contains(searchTerm) ||
              location.contains(searchTerm);
        }).toList();
      }
    });
  }

  void _navigateToAgendarCita(Clinica clinic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgendarCitaScreen(selectedClinica: clinic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(80.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    } else if (_errorMessage != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.danger)),
        ),
      );
    } else if (_filteredClinicas.isEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0),
          child: Text(
            _searchController.text.isEmpty
                ? 'No hay consultorios disponibles para mostrar.'
                : 'No se encontraron resultados para "${_searchController.text}".',
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(color: AppColors.textDark),
          ),
        ),
      );
    } else {
      content = Column(
        children: _filteredClinicas
            .map((clinica) => ClinicCard(
                  clinic: clinica,
                  onSelectClinic: _navigateToAgendarCita,
                ))
            .toList(),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAllClinicas,
      color: AppColors.primary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de Búsqueda (TextFormField) con estilo Outlined/Pill
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar médicos o especialidades...',
                hintStyle: AppText.body.copyWith(color: AppColors.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none, // Opcional: para quitar el borde si usas fillColor
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2), // Borde más visible al enfocar
                ),
                filled: true,
                fillColor: AppColors.card, // Color de fondo del campo de búsqueda
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
            const SizedBox(height: 30),
            // Título de Sección
            Text(
              'Consultorios Disponibles',
              style: AppText.h2.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 20),
            content,
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// 3. PacienteHomeScreen (Página principal con navegación inferior) - MODIFICADA para usar assets
// ======================================================================
class PacienteHomeScreen extends StatefulWidget {
  const PacienteHomeScreen({super.key});

  @override
  State<PacienteHomeScreen> createState() => _PacienteHomeScreenState();
}

class _PacienteHomeScreenState extends State<PacienteHomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  late final List<Widget> _views = const <Widget>[
    BuscarClinicasView(),
    MisCitasScreen(),
    PerfilPacienteScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashWrapper()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // Define tu logo personalizado usando Image.asset
  final Widget myCustomLogo = ClipRRect(
    borderRadius: BorderRadius.circular(5.0),
    child: Image.asset(
      'assets/logo_sanare.png', // <--- ¡ASEGÚRATE DE REEMPLAZAR ESTA RUTA CON LA RUTA REAL DE TU LOGO!
      height: 30, // Ajusta el tamaño según sea necesario
      width: 30,
      fit: BoxFit.cover,
      // Opcional: añade un errorBuilder si la imagen no se carga
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error, color: Colors.white);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // AppBar con la modificación de alineación
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Logo cargado desde assets
            myCustomLogo,
            const SizedBox(width: 8),
            Text(
              'Sanare',
              style: AppText.h2.copyWith(color: Colors.white, fontSize: 20),
            ),
            // Esto empujará el contenido ligeramente a la izquierda
            const SizedBox(width: 20),
          ],
        ),
        leading: const SizedBox.shrink(),
        actions: const [
          SizedBox(width: 0),
        ],
      ),
      body: SafeArea(
        child: _views.elementAt(_selectedIndex),
      ),
      // ... El resto del BottomNavigationBar se mantiene igual
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Mis Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: AppText.small.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppText.small,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        backgroundColor: AppColors.card,
        onTap: _onItemTapped,
      ),
    );
  }
}