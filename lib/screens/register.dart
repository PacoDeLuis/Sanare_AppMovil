import 'package:flutter/material.dart';
import 'package:sanare/screens/login.dart';
import 'package:sanare/services/auth_service.dart';

// Definiciones de Roles y Colores
enum UserRole { medico, paciente }

const Color sanareBlue = Color(0xFF4A688A);
const Color sanareLightBlue = Color(0xFF8DAAC1);
const Color sanareDarkText = Color(0xFF333333);
const Color sanareBackground = Color(0xFFF7F9FB); // Fondo ligero para contraste

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores y Estado (Funcionalidad NO ALTERADA)
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();

  UserRole _currentRole = UserRole.paciente;
  String? _selectedGender;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  void _setRole(UserRole newRole) {
    if (_currentRole != newRole) {
      if (newRole == UserRole.paciente) {
        _licenseController.clear();
        _specialtyController.clear();
      }
      setState(() {
        _currentRole = newRole;
      });
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : sanareBlue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating, // Estilo más moderno
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 18));

    try {
      final parts = _dobController.text.split('/');
      if (parts.length == 3) {
        initialDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (_) {}

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: sanareBlue,
              onPrimary: Colors.white,
              onSurface: sanareDarkText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: sanareBlue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      _showMessage('Por favor, completa todos los campos requeridos con formato correcto.');
      return;
    }

    if (_selectedGender == null) {
      _showMessage('Por favor, selecciona tu sexo.');
      return;
    }

    if (_currentRole == UserRole.medico &&
        (_licenseController.text.isEmpty || _specialtyController.text.isEmpty)) {
      _showMessage('Como médico, debes completar la Cédula Profesional y la Especialidad.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Las contraseñas no coinciden.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String password = _passwordController.text;
      final String password2 = _confirmPasswordController.text;

      if (_currentRole == UserRole.paciente) {
        await _authService.registerPaciente(
          username: _usernameController.text,
          email: _emailController.text,
          password: password,
          password2: password2,
          first_name: _firstNameController.text,
          last_name: _lastNameController.text,
          fecha_nacimiento: _dobController.text,
          sexo: _selectedGender!,
          phone: _phoneController.text,
        );
      } else {
        await _authService.registerMedico(
          username: _usernameController.text,
          email: _emailController.text,
          password: password,
          password2: password2,
          first_name: _firstNameController.text,
          last_name: _lastNameController.text,
          fecha_nacimiento: _dobController.text,
          sexo: _selectedGender!,
          phone: _phoneController.text,
          cedula: _licenseController.text,
          especialidad: _specialtyController.text,
        );
      }

      _showMessage(
        'Registro exitoso como ${_currentRole.name}. Redirigiendo al inicio de sesión...',
        isError: false,
      );

      await Future.delayed(const Duration(milliseconds: 2000));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      String error = e.toString().contains('TimeoutException')
          ? 'Error de conexión. Inténtalo más tarde.'
          : e.toString().replaceFirst('Exception: ', 'Error de Registro: ');
      _showMessage(error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- WIDGETS REFACTORIZADOS Y MEJORADOS ---

  Widget _buildTopLogo() {
    // Logo en color blanco para que contraste con el fondo azul de la pantalla de login/register
    // Reemplazamos el placeholder de Icon/Text por una imagen de asset
    return Image.asset(
      'assets/logo_sanare.png', // IMPORTANTE: Reemplaza 'assets/logo.png' con la ruta real de tu logo y asegúrate de declararlo en pubspec.yaml
      height: 60, // Ajusta la altura según sea necesario
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 6.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          color: sanareDarkText,
          fontWeight: FontWeight.w600, // Más énfasis en el label
        ),
      ),
    );
  }

  Widget _buildInputField({
    String hintText = '',
    bool isPassword = false,
    TextInputType? keyboardType,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    IconData? prefixIcon, // Nuevo: Soporte para iconos
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator ??
          (value) => (value == null || value.isEmpty) ? 'Campo obligatorio.' : null,
      style: const TextStyle(color: sanareDarkText, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: sanareLightBlue.withOpacity(0.6), fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        isDense: true,
        // Nuevo: Icono a la izquierda
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: sanareLightBlue.withOpacity(0.8), size: 20)
            : null,
        // Estilo de borde mejorado con esquinas más suaves y foco en azul principal
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Esquinas más suaves
          borderSide: const BorderSide(color: sanareLightBlue, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: sanareLightBlue, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: sanareBlue, width: 2.0), // Borde más grueso al enfocar
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: sanareLightBlue, width: 1.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          hint: Text(
            'Selecciona tu sexo',
            style: TextStyle(color: sanareLightBlue.withOpacity(0.6), fontSize: 16),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: sanareBlue),
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
          items: const [
            DropdownMenuItem(value: 'M', child: Text('Masculino', style: TextStyle(color: sanareDarkText))),
            DropdownMenuItem(value: 'F', child: Text('Femenino', style: TextStyle(color: sanareDarkText))),
            DropdownMenuItem(value: 'O', child: Text('Otro', style: TextStyle(color: sanareDarkText))),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleToggle() {
    final isMedicoActive = _currentRole == UserRole.medico;
    final isPacienteActive = _currentRole == UserRole.paciente;

    // Widget para un botón de rol (estilo más limpio y moderno)
    Widget buildRoleButton(UserRole role, String label, bool isActive) {
      return Expanded(
        child: InkWell(
          onTap: () => _setRole(role),
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? sanareBlue : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isActive ? sanareBlue : sanareLightBlue, width: 1.5),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: sanareBlue.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : sanareBlue,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildRoleButton(UserRole.paciente, 'Soy Paciente', isPacienteActive),
          const SizedBox(width: 15),
          buildRoleButton(UserRole.medico, 'Soy Médico', isMedicoActive),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isMedico = _currentRole == UserRole.medico;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de Credenciales
          _buildTextFieldLabel('Nombre de Usuario *'),
          _buildInputField(
            hintText: 'Define tu nombre de usuario',
            controller: _usernameController,
            prefixIcon: Icons.person_outline,
          ),
          _buildTextFieldLabel('Correo electrónico *'),
          _buildInputField(
            hintText: 'ejemplo@correo.com',
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Correo obligatorio.';
              if (!emailRegex.hasMatch(value)) return 'Formato de correo inválido.';
              return null;
            },
          ),
          // Nombres
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldLabel('Nombre *'),
                    _buildInputField(controller: _firstNameController, prefixIcon: Icons.badge_outlined),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldLabel('Apellido *'),
                    _buildInputField(controller: _lastNameController, prefixIcon: Icons.badge_outlined),
                  ],
                ),
              ),
            ],
          ),
          // Fecha de nacimiento y Sexo
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Alineación para Dropdown
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldLabel('Fecha de nacimiento *'),
                    _buildInputField(
                      hintText: 'dd/mm/aaaa',
                      keyboardType: TextInputType.datetime,
                      controller: _dobController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      prefixIcon: Icons.calendar_today,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Fecha obligatoria.';
                        if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                          return 'Formato DD/MM/AAAA.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldLabel('Sexo *'),
                    _buildGenderDropdown(),
                  ],
                ),
              ),
            ],
          ),
          // Teléfono
          _buildTextFieldLabel('Teléfono *'),
          _buildInputField(
            hintText: 'Tu número de teléfono',
            keyboardType: TextInputType.phone,
            controller: _phoneController,
            prefixIcon: Icons.phone_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Teléfono obligatorio.';
              if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                return 'Debe ser un número válido (10 dígitos).';
              }
              return null;
            },
          ),
          // Contraseñas
          _buildTextFieldLabel('Contraseña *'),
          _buildInputField(
            hintText: 'Mínimo 6 caracteres',
            isPassword: true,
            controller: _passwordController,
            prefixIcon: Icons.lock_outline,
            validator: (value) {
              if (value == null || value.length < 6) return 'Mínimo 6 caracteres.';
              return null;
            },
          ),
          _buildTextFieldLabel('Confirmar Contraseña *'),
          _buildInputField(
            hintText: 'Repite tu contraseña',
            isPassword: true,
            controller: _confirmPasswordController,
            prefixIcon: Icons.lock_reset_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Confirmación obligatoria.';
              if (value != _passwordController.text) return 'Las contraseñas no coinciden.';
              return null;
            },
          ),
          // Campos de Médico
          if (isMedico) _buildDoctorFields(),
        ],
      ),
    );
  }

  Widget _buildDoctorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFieldLabel('Cédula Profesional *'),
        _buildInputField(
          hintText: 'Ej. 123456',
          keyboardType: TextInputType.number,
          controller: _licenseController,
          prefixIcon: Icons.local_hospital_outlined,
          validator: (value) {
            if (_currentRole == UserRole.medico && (value == null || value.isEmpty)) {
              return 'Cédula es obligatoria para médicos.';
            }
            return null;
          },
        ),
        _buildTextFieldLabel('Especialidad *'),
        _buildInputField(
          hintText: 'Ej. Cardiología',
          controller: _specialtyController,
          prefixIcon: Icons.medical_services_outlined,
          validator: (value) {
            if (_currentRole == UserRole.medico && (value == null || value.isEmpty)) {
              return 'Especialidad es obligatoria para médicos.';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sanareBlue, // 1. Fondo principal azul
      appBar: null, // Eliminamos el AppBar
      body: SafeArea(
        child: SingleChildScrollView(
          // 2. Quitamos el padding global, se pondrá en el Container interior
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Logo en el Fondo Azul ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 35.0),
                child: Center(child: _buildTopLogo()), // Logo ahora blanco
              ),
              // --- Contenedor Blanco Principal (la "tarjeta") ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0), // Bordes superiores redondeados
                    topRight: Radius.circular(30.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0), // Padding interior para el contenido
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Título y Subtítulo ---
                    const Center(
                      child: Text(
                        'Crea tu Cuenta Sanare',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: sanareDarkText,
                            height: 1.2),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Text(
                        'Completa los campos para unirte a la plataforma.',
                        style: TextStyle(fontSize: 16, color: sanareDarkText.withOpacity(0.7)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- Tabs de Navegación (Login/Register) ---
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: sanareLightBlue, // Cambiado para ser más discreto
                              side: const BorderSide(color: sanareLightBlue),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {}, // Se mantiene vacío para indicar la pestaña activa
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sanareBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 4,
                            ),
                            child: const Text('Registrarse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    // Eliminamos el Divider y lo reemplazamos por espacio
                    const SizedBox(height: 25),

                    // --- Selector de Rol ---
                    _buildRoleToggle(),

                    // --- Formulario de Registro ---
                    _buildRegistrationForm(),

                    // --- Botón de Registro Principal ---
                    const SizedBox(height: 40),
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: sanareBlue)
                          : ElevatedButton(
                              onPressed: _handleRegister,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 55), // Usar todo el ancho disponible
                                backgroundColor: sanareBlue,
                                foregroundColor: Colors.white,
                                elevation: 8, // Mayor sombra para efecto CTA
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Esquinas más redondas
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              child: const Text('Siguiente'),
                            ),
                    ),
                    const SizedBox(height: 30), // Espacio al final
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}