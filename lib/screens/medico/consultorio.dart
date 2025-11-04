import 'package:flutter/material.dart';

const Color sanareBlue = Color(0xFF4A688A);
const Color sanareLightBlue = Color(0xFF8DAAC1);
const Color sanareDarkText = Color(0xFF333333);

class ConsultorioScreen extends StatefulWidget {
  const ConsultorioScreen({super.key});

  @override
  State<ConsultorioScreen> createState() => _ConsultorioScreenState();
}

class _ConsultorioScreenState extends State<ConsultorioScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _locationController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _saveConsultorio() {
    if (_nameController.text.isEmpty || _specializationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa al menos el Nombre y la Especialidad.')),
      );
      return;
    }

  
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Consultorio ${_nameController.text} agregado con éxito!'),
        backgroundColor: sanareBlue,
      ),
    );
    Navigator.pop(context);
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

  Widget _buildInputField({String hintText = '', required TextEditingController controller}) {
    return SizedBox(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Añadir Nuevo Consultorio',
          style: TextStyle(color: sanareDarkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: sanareBlue),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Datos del Consultorio',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: sanareBlue,
                ),
              ),
              const Divider(color: sanareLightBlue, height: 40, thickness: 1),

              _buildTextFieldLabel('Nombre del Consultorio/Clínica'),
              _buildInputField(hintText: 'Ej: Consultorio Central', controller: _nameController),

              _buildTextFieldLabel('Especialidad Principal'),
              _buildInputField(hintText: 'Ej: Cardiología Pediátrica', controller: _specializationController),
              
              _buildTextFieldLabel('Ubicación / Dirección'),
              _buildInputField(hintText: 'Ej: Col. San Benito, Av. 1', controller: _locationController),
              
              _buildTextFieldLabel('Horarios de Atención'),
              _buildInputField(hintText: 'Ej: Lunes a Viernes, 8:00 - 17:00', controller: _hoursController),
              
              _buildTextFieldLabel('Link de Imagen (simulado)'),
              _buildInputField(hintText: 'URL de la imagen del lugar', controller: TextEditingController()),
              
              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: _saveConsultorio,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: sanareBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Guardar Consultorio', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
