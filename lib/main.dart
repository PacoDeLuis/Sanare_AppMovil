import 'package:flutter/material.dart';
import 'screens/splash_wrapper.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- 1. Importación necesaria

void main() async { // <-- 2. MODIFICACIÓN: Función asíncrona
  // 3. Inicializa el binding de Flutter (necesario si main es async)
  WidgetsFlutterBinding.ensureInitialized();

  // 4. SOLUCIÓN AL LocaleDataException: Inicializa los datos de localización para el español
  await initializeDateFormatting('es', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color sanareBlue = Color(0xFF4A688A);
  static const Color sanareLightPink = Color(0xFFD6AEC4);
  static const Color sanareDarkText = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SANARE App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: sanareBlue,
          primary: sanareBlue,
          secondary: sanareLightPink,
          background: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: sanareBlue,
            letterSpacing: 2,
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            color: sanareBlue,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      home: const SplashWrapper(), // El SplashWrapper decide si mostrar Login o Home
    );
  }
}

// NOTA: La clase SanareSplashScreenMerged fue ELIMINADA de main.dart
// y ahora se utiliza la versión que está dentro de splash_wrapper.dart.
