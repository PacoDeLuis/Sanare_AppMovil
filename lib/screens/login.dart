import 'package:flutter/material.dart';

// Importaciones de rutas y servicios
import 'package:sanare/screens/register.dart';
import 'package:sanare/screens/medico/home.dart';
import 'package:sanare/screens/paciente/home.dart';
import 'package:sanare/services/auth_service.dart';
import 'package:sanare/services/secure_storage_service.dart';

// Importaciones de estilos centralizados
import 'package:sanare/themes/app_colors.dart';
import 'package:sanare/themes/app_styles.dart';
import 'package:sanare/themes/app_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final SecureStorageService _storageService = SecureStorageService();
  bool _isLoading = false;
  bool _obscureText = true; // Control de visibilidad de contraseña

  @override
  void initState() {
    super.initState();
    // Revisa el estado de autenticación al iniciar la pantalla
    _checkAuthStatus();
  }

  // Comprueba si ya existe una sesión activa y redirige al Home
  Future<void> _checkAuthStatus() async {
    final token = await _storageService.getAccessToken();
    final role = await _storageService.getUserRole();

    if (token != null && role != null) {
      if (!mounted) return;
      if (role == 'medico') {
        _navigateTo(const MedicoHomeScreen());
      } else if (role == 'paciente') {
        _navigateTo(const PacienteHomeScreen());
      }
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // Muestra mensajes de SnackBar con colores de estado
  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppText.body.copyWith(color: AppColors.card)),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Manejador de la lógica de inicio de sesión
  Future<void> _handleLogin() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) {
      _showMessage('Por favor, corrige los errores en el formulario.', isError: true);
      return;
    }

    final username = _usernameController.text;
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.login(username, password);
      // Obtener datos de perfil para determinar el rol
      final profileData = await _authService.fetchUserProfile();
      final bool isMedico = profileData['is_medico'] ?? false;
      final String userRole = isMedico ? 'medico' : 'paciente';

      await _storageService.saveUserRole(userRole);

      _showMessage('¡Bienvenido!', isError: false);

      if (!mounted) return;
      if (isMedico) {
        _navigateTo(const MedicoHomeScreen());
      } else {
        _navigateTo(const PacienteHomeScreen());
      }
    } catch (e) {
      // Manejo de errores de autenticación o API
      _showMessage(e.toString().replaceFirst('Exception: ', 'Error: '), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Widget para el campo de entrada de texto
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    IconData? icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(label, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscureText : false,
          keyboardType: label.toLowerCase().contains('usuario')
              ? TextInputType.emailAddress
              : TextInputType.text,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: AppColors.textLight) : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textLight,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            filled: true,
            fillColor: AppColors.card, // Usar color de tarjeta (blanco) como fondo de input
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tomamos la altura total de la pantalla para centrar el contenido verticalmente
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Usamos primaryLight como fondo general para un look más acogedor
      backgroundColor: AppColors.primaryLight,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Ocultar teclado al tocar fuera
        child: SafeArea(
          // Utilizamos un Stack para tener el fondo azulado y el contenido flotante
          child: Stack(
            children: [
              // 1. Fondo Superior Azulado (Opcional, para dar profundidad)
              Container(
                height: screenHeight * 0.4, // Cubre el 40% superior
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
              ),

              // 2. Contenido principal y scrollable
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Encabezado con Logo y Título (centrado en la parte superior azul)
                    _buildHeader(context),

                    const SizedBox(height: 50),

                    // Contenedor principal del formulario (reemplaza la Card)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card, // Fondo blanco para el formulario
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Títulos
                          Text(
                            'Bienvenido de vuelta',
                            style: AppText.h1.copyWith(color: AppColors.primaryDark),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Inicia sesión para acceder a tu cuenta',
                            style: AppText.small.copyWith(color: AppColors.textLight),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 30),

                          // Botones de Navegación (Login/Registro)
                          _buildAuthToggleButtons(context),

                          const SizedBox(height: 40),
                          
                          // Formulario de Login
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                // Campos de Formulario
                                _buildInputField(
                                  label: 'Nombre de Usuario',
                                  icon: Icons.person_outline,
                                  controller: _usernameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El nombre de usuario es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                                _buildInputField(
                                  label: 'Contraseña',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  controller: _passwordController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'La contraseña es obligatoria';
                                    }
                                    if (value.length < 6) {
                                      return 'Debe tener al menos 6 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                
                                // Botón de Olvidaste Contraseña
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // TODO: Implementar lógica de recuperación de contraseña
                                    },
                                    child: Text(
                                      '¿Olvidaste tu contraseña?',
                                      style: AppText.small.copyWith(
                                          color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 30),
                                
                                // Botón de Login
                                _isLoading
                                    ? Center(
                                          child: CircularProgressIndicator(color: AppColors.primary))
                                    : ElevatedButton(
                                        onPressed: _handleLogin,
                                        style: AppStyles.primaryButton,
                                        child: const Text('Iniciar Sesión', style: AppText.button),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para el encabezado con logo de Sanare
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Uso de Image.asset con fallback para el logo
        Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.only(right: 10),
          child: Image.asset(
            'assets/logo_sanare.png', // ⭐ RUTA DE TU LOGO
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback si la imagen no se encuentra
              return Icon(
                Icons.medical_services,
                color: AppColors.softPink, // Usamos un color más contrastante con el fondo azul
                size: 40,
              );
            },
          ),
        ),
        Text(
          'SANARE',
          style: AppText.h1.copyWith(
            color: Colors.white, // Texto blanco para contrastar con el fondo primary
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // Widget para los botones de toggle (Login/Registro)
  Widget _buildAuthToggleButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.background, // Fondo claro para el toggle
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: <Widget>[
          // Botón Iniciar Sesión (activo)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ]
              ),
              child: Center(
                child: Text(
                  'Iniciar Sesión',
                  style: AppText.body.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          // Botón Registrarse (inactivo/navegación)
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Registrarse',
                    style: AppText.body.copyWith(color: AppColors.textLight, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}