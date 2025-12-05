import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Asegúrate de que este import sea correcto en tu proyecto
import 'package:sanare/services/clinica_service.dart';

// Paleta de Colores de las Imágenes
const Color sanareBlue = Color(0xFF4A688A); // Azul oscuro/marino para acciones principales
const Color sanareLightBlue = Color(0xFF8DAAC1); // Azul claro para bordes y acentos
const Color sanareDarkText = Color(0xFF333333); // Color de texto principal (títulos y labels)
const Color sanareLightGray = Color(0xFFF3F4F6); // Fondo de campos o chips (se mantiene para relleno de inputs)
const Color sanareDangerRed = Color(0xFFE55A5A); // Rojo para la acción de eliminar
const Color sanareWhite = Color(0xFFFFFFFF); // Blanco para texto en botones azules
const Color sanareSuccessGreen = Color(0xFF4CAF50); // Verde para éxito

class ConsultorioScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const ConsultorioScreen({super.key, this.initialData});

  @override
  State<ConsultorioScreen> createState() => _ConsultorioScreenState();
}

class _ConsultorioScreenState extends State<ConsultorioScreen> {
  // Asegúrate de que ClinicaService esté definido correctamente en tu proyecto
  final ClinicaService _clinicaService = ClinicaService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? _selectedImage;
  String? _initialImageUrl; // Para mostrar la imagen existente
  TimeOfDay? _aperturaTime;
  TimeOfDay? _cierreTime;

  final List<int> _diasHabiles = [];
  final List<String> _diasSemana = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

  bool _isLoading = false;
  int? _clinicId;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _loadInitialData(widget.initialData!);
    }
  }

  void _loadInitialData(Map<String, dynamic> data) {
    _clinicId = data['id'] as int?;
    // Asegurando manejo de nulos y tipos
    _nameController.text = data['nombre'] as String? ?? '';
    _descriptionController.text = data['descripcion'] as String? ?? '';
    _locationController.text = data['ubicacion'] as String? ?? '';
    _initialImageUrl = data['imagen_url'] as String?; // Asumiendo que existe una URL

    if (data['hora_apertura'] != null) {
      _aperturaTime = _parseTimeFromDjango(data['hora_apertura']);
    }
    if (data['hora_cierre'] != null) {
      _cierreTime = _parseTimeFromDjango(data['hora_cierre']);
    }

    if (data['dias_habiles'] is List) {
      _diasHabiles.addAll(data['dias_habiles'].whereType<int>());
    }
  }

  TimeOfDay? _parseTimeFromDjango(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _initialImageUrl = null; // Borrar URL si se selecciona una nueva imagen local
      });
    }
  }

  Future<void> _selectTime(bool isApertura) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        // Estilo para el TimePicker
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: sanareBlue,
              onSurface: sanareDarkText,
              // Utilizar LightGray para el fondo de la superficie para mantener coherencia
              surface: sanareLightGray,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isApertura) {
          _aperturaTime = picked;
        } else {
          _cierreTime = picked;
        }
      });
    }
  }

  String _formatTimeForDjango(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  void _saveConsultorio() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena todos los campos obligatorios.')),
      );
      return;
    }

    if (_aperturaTime == null || _cierreTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona las horas de apertura y cierre.')),
      );
      return;
    }

    if (_diasHabiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona al menos un día hábil.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String action = _clinicId == null ? 'registrado' : 'actualizado';

    try {
      if (_clinicId == null) {
        await _clinicaService.registerClinica(
          nombre: _nameController.text.trim(),
          descripcion: _descriptionController.text.trim(),
          ubicacion: _locationController.text.trim(),
          horaApertura: _formatTimeForDjango(_aperturaTime),
          horaCierre: _formatTimeForDjango(_cierreTime),
          diasHabiles: _diasHabiles,
          imagen: _selectedImage,
        );
      } else {
        await _clinicaService.updateClinica(
          id: _clinicId!,
          nombre: _nameController.text.trim(),
          descripcion: _descriptionController.text.trim(),
          ubicacion: _locationController.text.trim(),
          horaApertura: _formatTimeForDjango(_aperturaTime),
          horaCierre: _formatTimeForDjango(_cierreTime),
          diasHabiles: _diasHabiles,
          imagen: _selectedImage,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consultorio "${_nameController.text}" $action con éxito.'),
            backgroundColor: sanareSuccessGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: sanareDangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Función para manejar la eliminación
  void _deleteConsultorio() {
    // Implementación placeholder para la acción de eliminar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de eliminación ejecutada (placeholder).'),
        backgroundColor: sanareDangerRed,
      ),
    );
    // Aquí iría la lógica para eliminar el consultorio
  }

  // Estilo para etiquetas de campos (bold y color oscuro, con asterisco para requerido)
  Widget _buildTextFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: sanareDarkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                fontSize: 16,
                color: sanareDangerRed,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  // Estilo para campos de texto
  Widget _buildInputField({
    required TextEditingController controller,
    String hintText = '',
    int maxLines = 1,
  }) {
    final bool isRequired = (controller == _nameController ||
        controller == _descriptionController ||
        controller == _locationController);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFieldLabel(
          controller == _nameController
              ? 'Nombre del Consultorio'
              : controller == _descriptionController
                  ? 'Especialidad'
                  : 'Ubicación / Dirección',
          isRequired: isRequired,
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: sanareDarkText),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Este campo es obligatorio.';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: sanareLightBlue),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            fillColor: sanareLightGray.withOpacity(0.5), // Ligeramente más opaco
            filled: true,

            // Estilo de bordes redondeados y colores
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: sanareBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: sanareDangerRed, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: sanareDangerRed, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Widget para seleccionar la imagen
  Widget _buildImagePicker() {
    // Determinar qué imagen mostrar: 1. Nueva, 2. Existente (URL), 3. Placeholder
    Widget imageWidget;
    if (_selectedImage != null) {
      // 1. Nueva imagen local seleccionada
      imageWidget = Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (_initialImageUrl != null && _initialImageUrl!.isNotEmpty) {
      // 2. Imagen existente (remota). Se usa un placeholder para evitar errores de red en el snippet.
      // Reemplaza esto con un Image.network real en tu app.
      imageWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, color: sanareBlue, size: 40),
            const SizedBox(height: 8),
            Text('Imagen Existente\n(URL: $_initialImageUrl)',
                textAlign: TextAlign.center,
                style: const TextStyle(color: sanareBlue, fontWeight: FontWeight.w500)),
          ],
        ),
      );
      /* // Si Image.network estuviera disponible, se usaría así:
      imageWidget = Image.network(
        _initialImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _defaultPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(color: sanareBlue));
        },
      );
      */
    } else {
      // 3. Placeholder por defecto
      imageWidget = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: sanareLightBlue, size: 40),
            SizedBox(height: 8),
            Text('Seleccionar Imagen',
                style: TextStyle(color: sanareLightBlue, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: sanareLightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sanareLightBlue, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageWidget,
            ),
          ),
        ),
        if (_selectedImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Imagen local seleccionada: ${_selectedImage!.path.split('/').last}',
              style: const TextStyle(color: sanareBlue, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // Estilo de Chip para selección de días
  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFieldLabel('Días Hábiles', isRequired: true),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: List.generate(_diasSemana.length, (index) {
            final isSelected = _diasHabiles.contains(index);

            return FilterChip(
              label: Text(_diasSemana[index]),
              selected: isSelected,
              backgroundColor: sanareLightGray.withOpacity(0.5),
              selectedColor: sanareBlue,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? sanareBlue : sanareLightBlue,
                  width: isSelected ? 2 : 1,
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected ? sanareWhite : sanareDarkText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _diasHabiles.add(index);
                  } else {
                    _diasHabiles.remove(index);
                  }
                });
              },
            );
          }),
        ),
      ],
    );
  }

  // Widget para seleccionar las horas de apertura y cierre
  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFieldLabel('Horas de Atención', isRequired: true),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: sanareLightGray.withOpacity(0.5),
                    border: Border.all(
                        color: _aperturaTime != null ? sanareBlue : sanareLightBlue,
                        width: _aperturaTime != null ? 2 : 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: sanareBlue),
                      const SizedBox(width: 8),
                      Text(
                        _aperturaTime?.format(context) ?? 'Apertura',
                        style: TextStyle(
                          color: _aperturaTime != null ? sanareDarkText : sanareLightBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: sanareLightGray.withOpacity(0.5),
                    border: Border.all(
                        color: _cierreTime != null ? sanareBlue : sanareLightBlue,
                        width: _cierreTime != null ? 2 : 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: sanareBlue),
                      const SizedBox(width: 8),
                      Text(
                        _cierreTime?.format(context) ?? 'Cierre',
                        style: TextStyle(
                          color: _cierreTime != null ? sanareDarkText : sanareLightBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Agrupa campos en un Card (Bloque de Información)
  Widget _buildDataCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 25.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: sanareBlue, size: 28), // Icono añadido
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700, // Un poco más de énfasis
                      color: sanareBlue),
                ),
              ],
            ),
            const Divider(color: sanareLightBlue, height: 25, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.initialData != null;
    final String appBarTitle = isEditing ? 'Editar Consultorio' : 'Agregar Consultorio';
    final String mainButtonText = isEditing ? 'Guardar Cambios' : 'Guardar Consultorio';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // REEMPLAZO DEL PLACEHOLDER POR EL WIDGET DE LOGO REAL
            // ⚠️ MODIFICA ESTA RUTA POR LA RUTA REAL DE TU LOGO
            Image.asset('assets/logo_sanare.png', height: 30,
            errorBuilder: (context, error, stackTrace) => Text('Sanare', style: TextStyle(color: sanareWhite, fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            Text(
              appBarTitle,
              style: const TextStyle(
                color: sanareWhite,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: sanareBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: sanareWhite),
      ),
      body: SafeArea(
        // Se añade un Padding Superior al SingleChildScrollView para compensar la eliminación del encabezado
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0, bottom: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // *** SECCIÓN DE ENCABEZADO DE PÁGINA ELIMINADA ***

                // Bloque 1: Datos Básicos
                _buildDataCard(
                  'Información Principal',
                  Icons.local_hospital_rounded, // Icono para clínica
                  [
                    _buildInputField(
                      hintText: 'Ej: Consultorio Central',
                      controller: _nameController,
                    ),
                    _buildInputField(
                      hintText: 'Ej: Cardiología y Cirugía Cardiovascular',
                      controller: _descriptionController,
                      maxLines: 1,
                    ),
                    _buildInputField(
                      hintText: 'Ej: Col. San Benito, Av. 1',
                      controller: _locationController,
                    ),
                  ],
                ),

                // Bloque 2: Horarios y Días Hábiles
                _buildDataCard(
                  'Disponibilidad',
                  Icons.schedule_rounded, // Icono para horarios
                  [
                    _buildTimeSelector(),
                    const SizedBox(height: 10),
                    _buildDaySelector(),
                  ],
                ),

                // Bloque 3: Imagen
                _buildDataCard(
                  'Imagen del Consultorio',
                  Icons.image_rounded, // Icono para imagen
                  [
                    _buildImagePicker(),
                  ],
                ),

                const SizedBox(height: 10),

                // BOTÓN DE ELIMINAR MEJORADO
                if (isEditing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: ElevatedButton.icon(
                      onPressed: _deleteConsultorio,
                      icon: const Icon(Icons.delete_forever, color: sanareWhite),
                      label: const Text('Eliminar consultorio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sanareDangerRed, // Fondo rojo
                        foregroundColor: sanareWhite, // Texto blanco
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4, // Añadir sombra para destacarlo
                      ),
                    ),
                  ),

                // Botón principal de Guardar/Actualizar (ya no está fijo en el footer)
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveConsultorio,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: sanareBlue,
                    foregroundColor: sanareWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 8,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: sanareWhite,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          mainButtonText,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                ),
                const SizedBox(height: 20), // Espacio inferior para ScrollView
              ],
            ),
          ),
        ),
      ),
      // Se elimina el `Column` que contenía el `Expanded` y el `Container` del footer
      // y el botón principal se mueve dentro del `SingleChildScrollView` para que se desplace.
    );
  }
}