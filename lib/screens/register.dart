import 'package:flutter/material.dart';

void main() {
  runApp(const SanareApp());
}

// Definiciones Globales

// Enumeración de Rol de Usuario
enum UserRole {
  medico,
  paciente
}

// Definición de colores de la marca
const Color sanareBlue = Color(0xFF4A688A);
const Color sanareLightBlue = Color(0xFF8DAAC1);
const Color sanareDarkText = Color(0xFF333333);

// Aplicación Principal
class SanareApp extends StatelessWidget {
  const SanareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sanare Register & Login',
      theme: ThemeData(
        primaryColor: sanareBlue,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: sanareLightBlue),
        // Se asume que la fuente 'Inter' está configurada en el proyecto
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const RegisterScreen(),
    );
  }
}

// Pantalla de Login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    // Simulación de autenticación
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inicio de sesión simulado exitoso para ${_usernameController.text}'),
          backgroundColor: sanareBlue,
          duration: const Duration(seconds: 2),
        ),
      );
      // Aquí podrías navegar a MedicoHomeScreen o PatientHomeScreen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa tu usuario y contraseña.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTopLogo() {
    return const Row(
      children: [
        Icon(
            Icons.medical_services_outlined,
            color: sanareBlue,
            size: 30,
        ),
        SizedBox(width: 8),
        Text(
          'SANARE',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: sanareBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          color: sanareDarkText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  // Widget de campo de texto reutilizable
  Widget _buildInputField({
    String hintText = '',
    bool isPassword = false,
    TextInputType? keyboardType,
    required TextEditingController controller,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: sanareDarkText),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: sanareLightBlue.withOpacity(0.7)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: sanareLightBlue, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: sanareLightBlue, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: sanareBlue, width: 2),
          ),
        ),
      ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: _buildTopLogo(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Botones de alternancia Iniciar Sesión / Registrarse
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {}, // No hace nada, ya está seleccionado
                      style: OutlinedButton.styleFrom(
                        backgroundColor: sanareBlue,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: sanareBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                      ),
                      child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Navega a la pantalla de Registro
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: sanareBlue,
                        side: const BorderSide(color: sanareLightBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Registrarse', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Contenido de la vista de Login
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      'Bienvenido de vuelta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: sanareBlue,
                      ),
                    ),
                  ),
                  const Divider(color: sanareLightBlue, height: 40, thickness: 1),

                  _buildTextFieldLabel('Nombre de Usuario'),
                  _buildInputField(
                    hintText: 'Tu nombre de usuario',
                    controller: _usernameController,
                  ),

                  _buildTextFieldLabel('Contraseña'),
                  _buildInputField(
                    hintText: 'Tu contraseña',
                    isPassword: true,
                    controller: _passwordController,
                  ),

                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Función de recuperación de contraseña aún no implementada.')),
                          );
                      },
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: sanareBlue, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botón Iniciar Sesión
                  Center(
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(180, 50),
                        backgroundColor: sanareBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantalla de Registro
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();


  UserRole _currentRole = UserRole.paciente;
  String? _selectedGender;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _licenseController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  void _setRole(UserRole newRole) {
    if (_currentRole != newRole) {
      setState(() {
        _currentRole = newRole;
      });
    }
  }

  void _handleRegister() {
    // 1. Lógica de validación simple
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _firstNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos obligatorios.')),
      );
      return;
    }

    // 2. Simulación de registro - La lógica real de backend iría aquí.

    // 3. Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registro simulado exitoso como ${_currentRole.name}. Navegando a Login.'),
        backgroundColor: sanareBlue,
        duration: const Duration(seconds: 2),
      ),
    );

    // 4. Navegar al Login después del feedback
    Future.delayed(const Duration(milliseconds: 1500), () {
        if(mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
    });
  }
  
  // Selector de fecha (Calendario)
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate;
    try {
      final parts = _dobController.text.split('/');
      if (parts.length == 3) {
        selectedDate = DateTime.tryParse("${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}");
      }
    } catch (e) {
      // Ignorar errores de parseo
    }

    DateTime initialDate = selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)); 

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365)),
      builder: (context, child) {
        // Estilo del DatePicker para que coincida con el tema Sanare
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: sanareBlue,
              onPrimary: Colors.white,
              onSurface: sanareDarkText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: sanareBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }


  Widget _buildTopLogo() {
    return const Row(
      children: [
        Icon(
            Icons.medical_services_outlined,
            color: sanareBlue,
            size: 30,
        ),
        SizedBox(width: 8),
        Text(
          'SANARE',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: sanareBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          color: sanareDarkText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Widget de campo de texto reutilizable
  Widget _buildInputField({
    String hintText = '',
    bool isPassword = false,
    TextInputType? keyboardType,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(color: sanareDarkText),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: sanareLightBlue.withOpacity(0.7)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: sanareLightBlue, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: sanareLightBlue, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: sanareBlue, width: 2),
          ),
        ),
      ),
    );
  }

  // Widget de selección de género (Dropdown)
  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: sanareLightBlue, width: 1.5),
      ),
      child: DropdownButton<String>(
        value: _selectedGender,
        hint: const Text('Selecciona tu sexo', style: TextStyle(color: Color(0xAA8DAAC1))),
        icon: const Icon(Icons.arrow_drop_down, color: sanareBlue),
        isExpanded: true,
        underline: const SizedBox(),

        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },

        items: const <DropdownMenuItem<String>>[
          DropdownMenuItem<String>(
            value: 'Masculino',
            child: Text('Masculino', style: TextStyle(color: sanareDarkText)),
          ),
          DropdownMenuItem<String>(
            value: 'Femenino',
            child: Text('Femenino', style: TextStyle(color: sanareDarkText)),
          ),
          DropdownMenuItem<String>(
            value: 'Otro',
            child: Text('Otro', style: TextStyle(color: sanareDarkText)),
          ),
        ],
      ),
    );
  }

  // Widget de Formulario de Registro
  Widget _buildRegistrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTextFieldLabel('Nombre de Usuario'),
        _buildInputField(
          hintText: 'Define tu nombre de usuario',
          controller: _usernameController,
        ),

        _buildTextFieldLabel('Correo electrónico'),
        _buildInputField(
          hintText: 'ejemplo@correo.com',
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
        ),

        // Fila de Nombre y Apellido
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel('Nombre'),
                  _buildInputField(hintText: '', controller: _firstNameController),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel('Apellido'),
                  _buildInputField(hintText: '', controller: _lastNameController),
                ],
              ),
            ),
          ],
        ),

        // Fila de Fecha de Nacimiento y Sexo
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel('Fecha de nacimiento'),
                  _buildInputField(
                    hintText: 'dd/mm/aaaa',
                    keyboardType: TextInputType.datetime,
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel('Selecciona tu sexo'),
                  _buildGenderDropdown(),
                ],
              ),
            ),
          ],
        ),

        _buildTextFieldLabel('Teléfono'),
        _buildInputField(
          hintText: 'Tu número de teléfono',
          keyboardType: TextInputType.phone,
          controller: _phoneController,
        ),

        _buildTextFieldLabel('Contraseña'),
        _buildInputField(
          hintText: 'Mínimo 6 caracteres',
          isPassword: true,
          controller: _passwordController,
        ),

        // Campos específicos de Médico
        if (_currentRole == UserRole.medico)
            _buildDoctorFields(),
      ],
    );
  }

  // Widget de campos específicos para Médico
  Widget _buildDoctorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFieldLabel('Cédula Profesional'),
        _buildInputField(
          hintText: 'Ej. 123456',
          keyboardType: TextInputType.number,
          controller: _licenseController,
        ),
        _buildTextFieldLabel('Especialidad'),
        _buildInputField(
          hintText: 'Ej. Cardiología',
          controller: _specialtyController,
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final isMedicoActive = _currentRole == UserRole.medico;
    final isPacienteActive = _currentRole == UserRole.paciente;

    final ButtonStyle medicoButtonStyle = OutlinedButton.styleFrom(
      backgroundColor: isMedicoActive ? sanareBlue : Colors.transparent,
      foregroundColor: isMedicoActive ? Colors.white : sanareLightBlue,
      side: BorderSide(color: isMedicoActive ? sanareBlue : sanareLightBlue, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: isMedicoActive ? 2 : 0,
    );

    final ButtonStyle pacienteButtonStyle = OutlinedButton.styleFrom(
      backgroundColor: isPacienteActive ? sanareBlue : Colors.transparent,
      foregroundColor: isPacienteActive ? Colors.white : sanareLightBlue,
      side: BorderSide(color: isPacienteActive ? sanareBlue : sanareLightBlue, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: isPacienteActive ? 2 : 0,
    );


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: _buildTopLogo(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Botones de alternancia Iniciar Sesión / Registrarse
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Navega a la pantalla de Login
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: sanareBlue,
                        side: const BorderSide(color: sanareLightBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {}, // No hace nada, ya está seleccionado
                      style: OutlinedButton.styleFrom(
                        backgroundColor: sanareBlue,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: sanareBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                      ),
                      child: const Text('Registrarse', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Contenido de la vista de Registro
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Crea una cuenta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: sanareBlue,
                      ),
                    ),
                  ),
                  const Divider(color: sanareLightBlue, height: 40, thickness: 1),

                  // Selector de Rol (Soy paciente - Soy médico)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () => _setRole(UserRole.paciente),
                          style: pacienteButtonStyle,
                          child: const Text('Soy paciente', style: TextStyle(fontSize: 14)),
                        ),
                        OutlinedButton(
                          onPressed: () => _setRole(UserRole.medico),
                          style: medicoButtonStyle,
                          child: const Text('Soy médico', style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),

                  // FORMULARIO ÚNICO
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return SizeTransition(
                        sizeFactor: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<UserRole>(_currentRole),
                      child: _buildRegistrationForm(),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botón Siguiente
                  Center(
                    child: ElevatedButton(
                      onPressed: _handleRegister,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(180, 50),
                        backgroundColor: sanareBlue,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Siguiente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}