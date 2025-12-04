import 'package:flutter/material.dart';
import 'bluetooth_scan_page.dart';
import 'learn_sign_screen.dart';
import '../theme/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.fondo,
              AppColors.fondo2,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo o icono principal
                const Icon(
                  Icons.sign_language,
                  size: 120,
                  color: AppColors.icon,
                ),
                const SizedBox(height: 40),

                // Título
                const Text(
                  'Lenguaje de Señas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Subtítulo
                const Text(
                  'Comunicación accesible para todos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 60),

                // Botón: Aprender señas
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LearnSignsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.school, size: 24),
                  label: const Text(
                    'Aprender Señas',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D1E33),
                    foregroundColor: Colors.white60,
                    side: const BorderSide(color: Colors.white60, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón: Traducir
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BluetoothScanScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bluetooth_searching, size: 24),
                  label: const Text(
                    'Traducir',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.icon,
                    foregroundColor: AppColors.subtytle,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                    elevation: 8,
                    shadowColor: AppColors.icon,
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
