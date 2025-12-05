import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppText {
  static const h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const body = TextStyle(
    fontSize: 14,
    color: AppColors.textLight,
  );

  static const small = TextStyle(
    fontSize: 12,
    color: AppColors.textLight,
  );

  static const button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}