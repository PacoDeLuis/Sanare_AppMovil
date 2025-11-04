import 'package:flutter/material.dart';
import 'screens/login.dart'; 

void main() {
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
          // ignore: deprecated_member_use
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
      home: const SanareSplashScreenMerged(), 
    );
  }
}

class SanareSplashScreenMerged extends StatelessWidget {
  const SanareSplashScreenMerged({super.key});

  Widget _buildSanareLogo(double size) {
    const Color sanareBlue = MyApp.sanareBlue;
    const Color sanareLightPink = MyApp.sanareLightPink;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.55, 
            height: size * 0.55,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: sanareLightPink.withOpacity(0.8),
              borderRadius: BorderRadius.circular(size / 4),
            ),
            transform: Matrix4.rotationZ(0.785),
          ),
          Container(
            width: size * 0.55, 
            height: size * 0.55,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: sanareBlue.withOpacity(0.8),
              borderRadius: BorderRadius.circular(size / 4),
            ),
            transform: Matrix4.rotationZ(0.785),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color sanareBlue = MyApp.sanareBlue;
    const Color sanareDarkText = MyApp.sanareDarkText;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildSanareLogo(size.width * 0.35),
                const SizedBox(height: 30),

                Text(
                  'SANARE',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 50),

                Text(
                  'Directorio de clínicas y consultorios médicos',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),

                const Text(
                  'Encuentra el especialista ideal para ti',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: sanareDarkText,
                  ),
                ),
                const SizedBox(height: 80),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(), 
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(size.width * 0.6, 55),
                    backgroundColor: sanareBlue, 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), 
                    ),
                    elevation: 5, 
                  ),
                  child: const Text(
                    'Iniciar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
