import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // Tarjetas clínicas suaves
  static BoxDecoration card = BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  // Barra de búsqueda estilo “Sanare”
  static BoxDecoration searchBar = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );

  // Botón principal estilo pastilla en azul del logo
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  );

  // Botón secundario rosa suave
  static ButtonStyle softButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.softPink,
    foregroundColor: AppColors.primaryDark,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  );
}