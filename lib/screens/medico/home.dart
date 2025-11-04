import 'package:flutter/material.dart';

import 'package:sanare/screens/medico/consultorio.dart'; 

// 1. DEFINICIONES Y MODELOS

const Color sanareBlue = Color(0xFF4A688A);
const Color sanareLightBlue = Color(0xFF8DAAC1);
const Color sanareDarkText = Color(0xFF333333);
const Color sanareLightGray = Color(0xFFF3F4F6);

class Clinic {
  final String name;
  final String specialization;
  final String location;
  final String hours;
  final double rating;
  final String imageUrl;

  Clinic({
    required this.name,
    required this.specialization,
    required this.location,
    required this.hours,
    required this.rating,
    required this.imageUrl,
  });
}

final List<Clinic> dummyClinics = [
  Clinic(
    name: 'Clínica Los Ángeles',
    specialization: 'Neurología',
    location: 'Zacatecoluca',
    hours: '08:00 - 17:00',
    rating: 4.5,
    imageUrl: 'https://placehold.co/600x400/8DAAC1/FFFFFF?text=Clínica+1',
  ),
  Clinic(
    name: 'Hospital San Juan',
    specialization: 'Cardiología',
    location: 'San Salvador',
    hours: '24 Horas',
    rating: 4.8,
    imageUrl: 'https://placehold.co/600x400/4A688A/FFFFFF?text=Clínica+2',
  ),
  Clinic(
    name: 'Centro Médico Alfa',
    specialization: 'Pediatría',
    location: 'Santa Ana',
    hours: '09:00 - 18:00',
    rating: 4.2,
    imageUrl: 'https://placehold.co/600x400/8DAAC1/FFFFFF?text=Clínica+3',
  ),
];


class ClinicCard extends StatelessWidget {
  final Clinic clinic;

  const ClinicCard({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), 
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              clinic.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: sanareLightBlue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.apartment, color: sanareBlue, size: 40),
                );
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clinic.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: sanareBlue,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Clínica especializada en neurología',
                  style: TextStyle(fontSize: 12, color: sanareDarkText),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Especialidad', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(clinic.specialization, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ubicación', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(clinic.location, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Horarios', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(clinic.hours, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
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
                        const SizedBox(width: 5),
                        SizedBox(
                          height: 25,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Función de edición de consultorio')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sanareLightBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('Editar', style: TextStyle(fontSize: 10, color: Colors.white)),
                          ),
                        ),
                      ],
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


// 2. VISTA DE "MIS CONSULTORIOS"

class ConsultorioView extends StatelessWidget {
  const ConsultorioView({super.key});

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: sanareLightGray,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: sanareLightBlue.withOpacity(0.5)),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Buscar consultorio...', 
          border: InputBorder.none,
          icon: Icon(Icons.search, color: sanareLightBlue),
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildFilterSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, 
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Especialidad', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const Row(
              children: [
                Text('Todas', style: TextStyle(fontSize: 14, color: sanareDarkText, fontWeight: FontWeight.w500)),
                Icon(Icons.keyboard_arrow_down, color: sanareDarkText, size: 20),
              ],
            ),
          ],
        ),
        const SizedBox(width: 15), 
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Ubicación', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const Row(
              children: [
                Text('Todas', style: TextStyle(fontSize: 14, color: sanareDarkText, fontWeight: FontWeight.w500)),
                Icon(Icons.keyboard_arrow_down, color: sanareDarkText, size: 20),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSearchBar(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Mis Consultorios', 
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: sanareBlue,
                ),
              ),
              Expanded(
                child: _buildFilterSelector(),
              ),
            ],
          ),
          const Divider(height: 25, thickness: 1, color: sanareLightBlue),
          ...dummyClinics.map((clinic) => ClinicCard(clinic: clinic)).toList(),
        ],
      ),
    );
  }
}

// =======================================================
// 3. VISTA DE NOTIFICACIONES
// =======================================================

class NotificacionesView extends StatelessWidget {
  const NotificacionesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_active_outlined, size: 80, color: sanareBlue),
            SizedBox(height: 20),
            Text(
              'Bandeja de Notificaciones',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: sanareBlue),
            ),
            SizedBox(height: 10),
            Text(
              'Recibirás alertas sobre citas, mensajes y recordatorios importantes de la plataforma.',
              style: TextStyle(fontSize: 16, color: sanareDarkText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


// 4. MEDICO HOME SCREEN (Contenedor Principal)
class MedicoHomeScreen extends StatefulWidget {
  const MedicoHomeScreen({super.key});

  @override
  State<MedicoHomeScreen> createState() => _MedicoHomeScreenState();
}

class _MedicoHomeScreenState extends State<MedicoHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _views = <Widget>[
    const ConsultorioView(),
    const NotificacionesView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  String _getAppBarTitle() {
    return _selectedIndex == 0 ? 'SANARE - Médico' : 'Notificaciones';
  }

  List<Widget> _getAppBarActions(BuildContext context) {
    if (_selectedIndex == 0) {
      return [
        IconButton(
          icon: const Icon(Icons.add_location_alt_outlined, color: sanareBlue),
          tooltip: 'Añadir Consultorio',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConsultorioScreen()),
            );
          },
        ),
        const SizedBox(width: 10),
      ];
    }
    return [const SizedBox(width: 10)];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.medical_services_outlined, color: sanareBlue, size: 30),
            const SizedBox(width: 8),
            Text(
              _getAppBarTitle(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: sanareBlue,
              ),
            ),
          ],
        ),
        actions: _getAppBarActions(context),
      ),
      
      body: SafeArea(
        child: _views.elementAt(_selectedIndex),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment_outlined),
            activeIcon: Icon(Icons.apartment),
            label: 'Consultorios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
        ],
        currentIndex: _selectedIndex, 
        selectedItemColor: sanareBlue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}