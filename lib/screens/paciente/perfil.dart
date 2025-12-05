import 'package:flutter/material.dart';
import 'package:sanare/services/auth_service.dart';

// Importaciones de estilos centralizados
import 'package:sanare/themes/app_colors.dart';
import 'package:sanare/themes/app_styles.dart';
import 'package:sanare/themes/app_text.dart';

// Import necesario para volver al login
import 'package:sanare/screens/login.dart';

class PerfilPacienteScreen extends StatefulWidget {
  const PerfilPacienteScreen({super.key});

  @override
  State<PerfilPacienteScreen> createState() => _PerfilPacienteScreenState();
}

class _PerfilPacienteScreenState extends State<PerfilPacienteScreen> {
  final AuthService _authService = AuthService();
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _authService.fetchUserProfile();
  }

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
            return _buildProfileContent(
              firstName: profile['first_name'] ?? 'N/A',
              lastName: profile['last_name'] ?? 'N/A',
              email: profile['email'] ?? 'N/A',
              telefono: profile['telefono'] ?? 'N/A',
              fechaNacimiento: profile['fecha_nacimiento'] ?? 'N/A',
              sexo: profile['sexo'] ?? 'N/A',
              username: profile['username'] ?? 'N/A',
            );
          }

          return const Center(
            child: Text('No se pudo cargar la información del perfil.'),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent({
    required String firstName,
    required String lastName,
    required String email,
    required String telefono,
    required String fechaNacimiento,
    required String sexo,
    required String username,
  }) {
    final String fullName = '$firstName $lastName';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 30,
              bottom: 30,
              left: 20,
              right: 20,
            ),
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
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                    // ⭐ CORRECCIÓN: Usamos ClipOval para asegurar que el logo se recorte 
                    // dentro del círculo y definimos el tamaño y fit: BoxFit.cover para llenarlo.
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo_sanare.png', // Ruta del logo que subiste
                        width: 110, // 2 * radius
                        height: 110, // 2 * radius
                        fit: BoxFit.cover, // Para llenar el espacio
                        // Fallback en caso de que el asset no cargue
                        errorBuilder: (context, error, stackTrace) {
                           return Icon(Icons.person, size: 70, color: AppColors.primaryDark);
                        },
                      ),
                    ),
                    // FIN DE CORRECCIÓN
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  fullName,
                  style: AppText.h1.copyWith(color: AppColors.primaryDark, fontSize: 26),
                ),
                const SizedBox(height: 5),
                Text(
                  'Rol: Paciente',
                  style: AppText.body.copyWith(
                    color: AppColors.textLight.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Información Personal',
                    style: AppText.h1.copyWith(color: AppColors.textDark)),
                const SizedBox(height: 15),
                _buildInfoCard(icon: Icons.alternate_email, title: 'Nombre de Usuario', value: username),
                _buildInfoCard(icon: Icons.email, title: 'Correo Electrónico', value: email),
                _buildInfoCard(icon: Icons.phone, title: 'Teléfono', value: telefono),
                _buildInfoCard(icon: Icons.cake, title: 'Fecha de Nacimiento', value: fechaNacimiento),
                _buildInfoCard(icon: Icons.wc, title: 'Sexo', value: sexo, isLast: true),
                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                      label: const Text('Cerrar Sesión', style: AppText.button),
                      style: AppStyles.primaryButton.copyWith(
                        backgroundColor: MaterialStateProperty.all(Color(0xFFD32F2F)),
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