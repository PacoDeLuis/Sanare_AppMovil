import 'package:flutter/material.dart';
import 'package:sanare/services/secure_storage_service.dart';
import 'login.dart';
import 'medico/home.dart';
import 'paciente/home.dart';

const Color sanareBlue = Color(0xFF4A688A);
const Color sanareLightPink = Color(0xFFD6AEC4);
const Color sanareDarkText = Color(0xFF333333);

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  final SecureStorageService _storageService = SecureStorageService();
  bool _initialized = false;
  Widget _nextScreen = const LoginScreen();

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    final token = await _storageService.getAccessToken();
    final role = await _storageService.getUserRole();

    if (token != null && role != null) {
      if (role == 'medico') {
        _nextScreen = const MedicoHomeScreen();
      } else if (role == 'paciente') {
        _nextScreen = const PacienteHomeScreen();
      }
    } else {
      _nextScreen = const LoginScreen();
    }

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SanareSplashScreenMerged(showLoading: true);
    }
    return _nextScreen;
  }
}

class SanareSplashScreenMerged extends StatelessWidget {
  final bool showLoading;
  const SanareSplashScreenMerged({super.key, this.showLoading = false});

  Widget _buildSanareLogo(double size) {
    const Color sanareBlue = Color(0xFF4A688A);
    const Color sanareLightPink = Color(0xFFD6AEC4);

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
              color: sanareLightPink.withOpacity(0.8),
              borderRadius: BorderRadius.circular(size / 4),
            ),
            transform: Matrix4.rotationZ(0.785),
          ),
          Container(
            width: size * 0.55,
            height: size * 0.55,
            decoration: BoxDecoration(
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
                Text('SANARE', style: Theme.of(context).textTheme.titleLarge),
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
                  style: TextStyle(fontSize: 16, color: sanareDarkText),
                ),
                const SizedBox(height: 80),
                if (!showLoading)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                  )
                else
                  const CircularProgressIndicator(color: sanareBlue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
