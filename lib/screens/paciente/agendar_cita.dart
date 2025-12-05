import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanare/screens/models/clinica.dart';
import 'package:sanare/services/medico_service.dart';
import 'package:sanare/services/cita_service.dart';

const Color sanareBlue = Color(0xFF4A688A);
const Color sanareAccent = Color(0xFF26C6DA);
const Color sanareLightGray = Color(0xFFE0E0E0);
const Color sanareDarkText = Color(0xFF333333);

class AgendarCitaScreen extends StatefulWidget {
  final Clinica selectedClinica;

  const AgendarCitaScreen({super.key, required this.selectedClinica});

  @override
  State<AgendarCitaScreen> createState() => _AgendarCitaScreenState();
}

class _AgendarCitaScreenState extends State<AgendarCitaScreen> {
  final CitaService _citaService = CitaService();
  final MedicoService _medicoService = MedicoService();

  List<String> _availableTimeSlots = [];
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _isLoading = false;
  String? _timeSlotsLoadError;
  final TextEditingController _motivoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'es';
    _motivoController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _motivoController.removeListener(_updateButtonState);
    _motivoController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    if (!_isLoading && mounted) {
      setState(() {});
    }
  }

  Future<void> _loadTimeSlots() async {
    if (_selectedDate == null) {
      if (mounted) {
        setState(() {
          _timeSlotsLoadError = "Selecciona una fecha para ver los horarios disponibles.";
          _availableTimeSlots = [];
          _isLoading = false;
        });
      }
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    if (mounted) {
      setState(() {
        _isLoading = true;
        _timeSlotsLoadError = null;
        _availableTimeSlots = [];
      });
    }

    try {
      final slots = await _medicoService.getAvailableTimeSlots(
        widget.selectedClinica.id,
        fecha: formattedDate,
      );

      if (mounted) {
        setState(() {
          _availableTimeSlots = slots;
          _selectedTime = null;
        });
      }
    } catch (e) {
      if (mounted) {
        final String errorMsg = e.toString().replaceFirst('Exception: ', '');
        setState(() {
          _timeSlotsLoadError = errorMsg;
          _availableTimeSlots = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar horarios: $errorMsg')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: sanareAccent,
            colorScheme: const ColorScheme.light(primary: sanareAccent),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
          _selectedTime = null;
          _timeSlotsLoadError = null;
          _availableTimeSlots = [];
        });
        _loadTimeSlots();
      }
    }
  }

  Future<void> _agendarCita() async {
    final int medicoResponsableId = widget.selectedClinica.medicoResponsableId;
    final String motivoCita = _motivoController.text.trim();

    if (medicoResponsableId == 0 ||
        _selectedDate == null ||
        _selectedTime == null ||
        motivoCita.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona fecha, hora e ingresa el motivo.')),
      );
      return;
    }

    if (_timeSlotsLoadError != null) return;

    setState(() => _isLoading = true);

    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final String formattedTime = _selectedTime!;

    final citaData = {
      'fecha': formattedDate,
      'hora': formattedTime,
      'motivo': motivoCita,
      'clinica_id': widget.selectedClinica.id,
    };

    try {
      await _citaService.scheduleCita(
        citaData,
        medicoId: medicoResponsableId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita agendada con éxito!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final String errorMsg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agendar: $errorMsg')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildMotivoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Motivo de la Cita'),
        TextFormField(
          controller: _motivoController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Describe brevemente la razón de la consulta (máx 100 caracteres)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: sanareLightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: sanareAccent, width: 2.0),
            ),
          ),
          maxLength: 100,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showFullPageLoading = _isLoading && _selectedDate == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agendar Cita en ${widget.selectedClinica.nombre}',
          style: const TextStyle(color: sanareBlue, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: sanareBlue),
        elevation: 1,
      ),
      body: showFullPageLoading
          ? const Center(child: CircularProgressIndicator(color: sanareAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResponsibleDoctorInfo(),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Selecciona la Fecha'),
                  _buildDateSelector(),
                  const SizedBox(height: 30),
                  if (_selectedDate != null) ...[
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator(color: sanareAccent)),
                    if (!_isLoading && _timeSlotsLoadError != null) _buildTimeSlotsError(),
                    if (!_isLoading &&
                        _timeSlotsLoadError == null &&
                        _availableTimeSlots.isNotEmpty) ...[
                      _buildSectionTitle('Selecciona la Hora'),
                      _buildTimeSlotGrid(),
                      const SizedBox(height: 30),
                      _buildMotivoField(),
                      const SizedBox(height: 40),
                    ] else if (!_isLoading &&
                        _timeSlotsLoadError == null &&
                        _availableTimeSlots.isEmpty) ...[
                      const Center(
                        child: Text(
                          'No hay horarios disponibles para la fecha seleccionada.',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: sanareDarkText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ],
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ||
                              _timeSlotsLoadError != null ||
                              _selectedDate == null ||
                              _selectedTime == null ||
                              _motivoController.text.trim().isEmpty
                          ? null
                          : _agendarCita,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sanareAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading &&
                              _selectedDate != null &&
                              _selectedTime != null
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _timeSlotsLoadError != null ||
                                      _selectedDate == null ||
                                      _selectedTime == null
                                  ? 'Selecciona Fecha/Hora'
                                  : 'Confirmar Cita',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildResponsibleDoctorInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: sanareLightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: sanareLightGray),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: sanareBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tu cita será agendada con el médico responsable de esta clínica (ID: ${widget.selectedClinica.medicoResponsableId}).',
              style: const TextStyle(color: sanareDarkText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: sanareDarkText,
        ),
      ),
    );
  }

  Widget _buildTimeSlotsError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 10),
            Text(
              'Error al cargar horarios: $_timeSlotsLoadError',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 15),
            if (_selectedDate != null)
              ElevatedButton(
                onPressed: _loadTimeSlots,
                style: ElevatedButton.styleFrom(
                  backgroundColor: sanareAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reintentar Carga'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: sanareLightGray),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate == null
                  ? 'Seleccionar una fecha'
                  : DateFormat('EEEE, d MMM yyyy', 'es')
                      .format(_selectedDate!),
              style: TextStyle(
                fontSize: 16,
                color: _selectedDate == null
                    ? sanareDarkText.withOpacity(0.6)
                    : sanareDarkText,
                fontWeight:
                    _selectedDate == null ? FontWeight.normal : FontWeight.w600,
              ),
            ),
            const Icon(Icons.calendar_today, color: sanareAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    if (_availableTimeSlots.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _availableTimeSlots.length,
      itemBuilder: (context, index) {
        final time = _availableTimeSlots[index];
        final isSelected = _selectedTime == time;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTime = time;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? sanareAccent : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? sanareAccent : sanareLightGray,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? sanareAccent.withOpacity(0.5)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 8 : 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isSelected ? Colors.white : sanareDarkText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
