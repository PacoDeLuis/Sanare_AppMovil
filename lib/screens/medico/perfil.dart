import 'package:flutter/material.dart';
import 'package:sanare/services/auth_service.dart';

// Importaciones de estilos centralizados (ASUMIMOS QUE ESTAS RUTAS SON CORRECTAS)
import 'package:sanare/themes/app_colors.dart';
import 'package:sanare/themes/app_styles.dart';
import 'package:sanare/themes/app_text.dart';

// Import necesario para volver al login
import 'package:sanare/screens/login.dart'; 
import 'dart:math' as math; // Importamos math para la rotación del icono

class MedicoProfileScreen extends StatefulWidget {
  const MedicoProfileScreen({Key? key}) : super(key: key);

  @override
  State<MedicoProfileScreen> createState() => _MedicoProfileScreenState();
}

class _MedicoProfileScreenState extends State<MedicoProfileScreen> {
  final AuthService _authService = AuthService();
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _authService.fetchUserProfile();
  }

  // Función para manejar el cierre de sesión
  void _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Envolvemos todo en un Scaffold y aplicamos AppBar y fondo
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: AppText.h2.copyWith(color: AppColors.primaryDark),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppColors.primaryDark),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            // Manejo de errores con opción de reintentar
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error al cargar el perfil: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: AppText.body.copyWith(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _profileDataFuture = _authService.fetchUserProfile();
                        });
                      },
                      style: AppStyles.primaryButton,
                      child: const Text('Reintentar', style: AppText.button),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            final profile = snapshot.data!;
            // Extracción de datos y provisión de fallbacks ('N/A')
            return _buildProfileContent(
              firstName: profile['first_name'] ?? 'N/A',
              lastName: profile['last_name'] ?? 'N/A',
              email: profile['email'] ?? 'N/A',
              telefono: profile['telefono'] ?? 'N/A',
              fechaNacimiento: profile['fecha_nacimiento'] ?? 'N/A',
              sexo: profile['sexo'] ?? 'N/A',
              username: profile['username'] ?? 'N/A',
              cedula: profile['cedula'] ?? 'N/A',
              especialidad: profile['especialidad'] ?? 'N/A',
            );
          }

          return const Center(
            child: Text('No se pudo cargar la información del perfil.'),
          );
        },
      ),
    );
  }

  // 2. Widget para construir el contenido del perfil con el nuevo diseño
  Widget _buildProfileContent({
    required String firstName,
    required String lastName,
    required String email,
    required String telefono,
    required String fechaNacimiento,
    required String sexo,
    required String username,
    required String cedula,
    required String especialidad,
  }) {
    final String fullName = 'Dr(a). $firstName $lastName'; // Prefijo de Doctor/a

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sección de encabezado (Avatar y Nombre)
          Container(
            padding: const EdgeInsets.only(top: 30, bottom: 30, left: 20, right: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Contenedor para el avatar con borde
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary, // Borde primario
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                    // Uso de ClipOval para asegurar que el logo se recorte dentro del círculo
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo_sanare.png', // RUTA DEL LOGO (usando el archivo que subiste)
                        width: 110, // 2 * radius
                        height: 110, // 2 * radius
                        fit: BoxFit.cover, 
                        errorBuilder: (context, error, stackTrace) {
                           return Transform.rotate( // Ícono de médico rotado para estética
                            angle: -math.pi / 4,
                            child: Icon(Icons.medical_services, size: 70, color: AppColors.primaryDark),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  fullName,
                  style: AppText.h1.copyWith(color: AppColors.primaryDark, fontSize: 26),
                ),
                const SizedBox(height: 5),
                Text(
                  'Rol: Médico',
                  style: AppText.body.copyWith(
                    color: AppColors.textLight.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Sección de información detallada
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detalles Profesionales',
                    style: AppText.h1.copyWith(color: AppColors.textDark)),
                const SizedBox(height: 15),
                
                // Campos específicos del Médico
                _buildInfoCard(icon: Icons.star, title: 'Especialidad', value: especialidad),
                _buildInfoCard(icon: Icons.badge, title: 'Cédula Profesional', value: cedula),
                
                const SizedBox(height: 30),
                
                Text('Información de Contacto',
                    style: AppText.h1.copyWith(color: AppColors.textDark)),
                const SizedBox(height: 15),
                
                // Campos generales
                _buildInfoCard(icon: Icons.alternate_email, title: 'Nombre de Usuario', value: username),
                _buildInfoCard(icon: Icons.email, title: 'Correo Electrónico', value: email),
                _buildInfoCard(icon: Icons.phone, title: 'Teléfono', value: telefono),
                
                const SizedBox(height: 30),
                
                Text('Datos Personales',
                    style: AppText.h1.copyWith(color: AppColors.textDark)),
                const SizedBox(height: 15),
                
                // Campos personales
                _buildInfoCard(icon: Icons.cake, title: 'Fecha de Nacimiento', value: fechaNacimiento),
                _buildInfoCard(icon: Icons.wc, title: 'Sexo', value: sexo, isLast: true),

                const SizedBox(height: 40),
                
                // Botón de Cerrar Sesión (Estilizado)
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                      label: const Text('Cerrar Sesión', style: AppText.button),
                      style: AppStyles.primaryButton.copyWith(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFFD32F2F)), // Rojo fuerte
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 15),
                        ),
                        elevation: MaterialStateProperty.all(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Widget utilitario para las tarjetas de información (reutilizado del paciente)
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary, size: 24),
          title: Text(
            title,
            style: AppText.small.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w400,
            ),
          ),
          subtitle: Text(
            value,
            style: AppText.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
        ),
      ),
    );
  }
}