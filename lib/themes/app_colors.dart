import 'package:flutter/material.dart';

class AppColors {
  // Tonos del logo Sanare (Nueva paleta)
  static const primary = Color(0xFF6A86B6);        // azul principal Sanare
  static const primaryDark = Color(0xFF51658C);    // azul oscuro del logo
  static const primaryLight = Color(0xFFA5B9D4);   // azul pastel claro
  static const softPink = Color(0xFFE8D4D6);       // rosa suave del logo

  // Fondo general — blanco azulado clínico
  static const background = Color(0xFFF5F7FA);

  // Tarjetas
  static const card = Colors.white;
  static const border = Color(0xFFE5E7EB); // Borde general de inputs y contenedores

  // Texto
  static const textDark = Color(0xFF2E3A59);
  static const textLight = Color(0xFF7785A2);

  // Estados
  static const success = Color(0xFF7BC5AE);  // verde suave
  static const warning = Color(0xFFFFD89B);
  static const danger = Color(0xFFE57373);   // rojo suave para peligro/error

  // Alias para mantener compatibilidad: error = danger
  static const error = danger;

  // Sombras
  static const shadow = Color.fromARGB(25, 0, 0, 0);
}