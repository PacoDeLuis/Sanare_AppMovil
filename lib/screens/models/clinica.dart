// lib/screens/models/clinica.dart

class Clinica {
  final int id;
  final String nombre;
  final String descripcion;
  final String ubicacion;
  final String horaApertura;
  final String horaCierre;
  final double rating;
  final String? imagen;
  
  final int medicoResponsableId; 

  Clinica({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    required this.horaApertura,
    required this.horaCierre,
    required this.rating,
    this.imagen,
    required this.medicoResponsableId,
  });

  factory Clinica.fromJson(Map<String, dynamic> json) {
    
    final medicoResponsableData = json['medico_responsable'];
    int responsableId;
    
    if (medicoResponsableData is int) {
        responsableId = medicoResponsableData;
    } else if (medicoResponsableData is Map<String, dynamic>) {
        responsableId = medicoResponsableData['id'] as int;
    } else {
        responsableId = 0; 
    }

    return Clinica(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      ubicacion: json['ubicacion'] as String,
      horaApertura: json['hora_apertura'] as String,
      horaCierre: json['hora_cierre'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      imagen: json['imagen'] as String?,
      
      medicoResponsableId: responsableId, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'hora_apertura': horaApertura,
      'hora_cierre': horaCierre,
      'rating': rating,
      'imagen': imagen,
      'medico_responsable_id': medicoResponsableId,
    };
  }
}