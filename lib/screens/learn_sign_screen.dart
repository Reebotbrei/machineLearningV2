import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LearnSignsScreen extends StatefulWidget {
  const LearnSignsScreen({super.key});

  @override
  State<LearnSignsScreen> createState() => _LearnSignsScreenState();
}

class _LearnSignsScreenState extends State<LearnSignsScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Datos del abecedario con descripciones de cómo hacer cada seña
  final List<Map<String, String>> _alphabet = [
    {
      'letter': 'A',
      'description': 'Puño cerrado con el pulgar al lado',
      'tip': 'Como si sostuvieras una moneda',
    },
    {
      'letter': 'B',
      'description': 'Mano abierta, dedos juntos, pulgar doblado sobre la palma',
      'tip': 'Palma hacia adelante',
    },
    {
      'letter': 'C',
      'description': 'Mano curvada en forma de C',
      'tip': 'Como si sostuvieras una taza',
    },
    {
      'letter': 'D',
      'description': 'Índice arriba, demás dedos tocan el pulgar formando un círculo',
      'tip': 'El índice apunta hacia arriba',
    },
    {
      'letter': 'E',
      'description': 'Dedos doblados tocando el pulgar',
      'tip': 'Como una garra suave',
    },
    {
      'letter': 'F',
      'description': 'Pulgar e índice forman círculo, otros dedos extendidos',
      'tip': 'Similar al gesto de "OK"',
    },
    {
      'letter': 'G',
      'description': 'Índice y pulgar paralelos apuntando al lado',
      'tip': 'Como una pistola horizontal',
    },
    {
      'letter': 'H',
      'description': 'Índice y medio extendidos horizontalmente, juntos',
      'tip': 'Dedos apuntando al lado',
    },
    {
      'letter': 'I',
      'description': 'Puño cerrado con meñique extendido',
      'tip': 'Solo el dedo pequeño arriba',
    },
    {
      'letter': 'J',
      'description': 'Igual que la I, pero dibujando una J en el aire',
      'tip': 'Meñique traza la letra J',
    },
    {
      'letter': 'K',
      'description': 'Índice y medio en V, pulgar entre ellos',
      'tip': 'Dedos apuntando hacia arriba',
    },
    {
      'letter': 'L',
      'description': 'Pulgar e índice en ángulo de 90°',
      'tip': 'Forma una L clara',
    },
    {
      'letter': 'M',
      'description': 'Pulgar debajo de tres dedos doblados',
      'tip': 'Tres dedos sobre el pulgar',
    },
    {
      'letter': 'N',
      'description': 'Pulgar debajo de dos dedos doblados',
      'tip': 'Dos dedos sobre el pulgar',
    },
    {
      'letter': 'Ñ',
      'description': 'Como la N, moviendo la mano hacia los lados',
      'tip': 'N con movimiento ondulante',
    },
    {
      'letter': 'O',
      'description': 'Todos los dedos tocan el pulgar formando un círculo',
      'tip': 'Forma un óvalo con la mano',
    },
    {
      'letter': 'P',
      'description': 'Como la K pero apuntando hacia abajo',
      'tip': 'K invertida',
    },
    {
      'letter': 'Q',
      'description': 'Como la G pero apuntando hacia abajo',
      'tip': 'G invertida',
    },
    {
      'letter': 'R',
      'description': 'Índice y medio cruzados',
      'tip': 'Dedos de la suerte',
    },
    {
      'letter': 'S',
      'description': 'Puño cerrado, pulgar sobre los dedos',
      'tip': 'Puño firme',
    },
    {
      'letter': 'T',
      'description': 'Pulgar entre índice y medio doblados',
      'tip': 'Pulgar asomando entre dedos',
    },
    {
      'letter': 'U',
      'description': 'Índice y medio extendidos y juntos hacia arriba',
      'tip': 'Dos dedos unidos apuntando arriba',
    },
    {
      'letter': 'V',
      'description': 'Índice y medio extendidos y separados',
      'tip': 'Señal de victoria/paz',
    },
    {
      'letter': 'W',
      'description': 'Tres dedos extendidos y separados (índice, medio, anular)',
      'tip': 'Tres dedos arriba',
    },
    {
      'letter': 'X',
      'description': 'Índice doblado como gancho',
      'tip': 'Dedo en forma de gancho',
    },
    {
      'letter': 'Y',
      'description': 'Pulgar y meñique extendidos, otros dedos cerrados',
      'tip': 'Gesto de teléfono/hang loose',
    },
    {
      'letter': 'Z',
      'description': 'Índice extendido dibujando una Z en el aire',
      'tip': 'Traza la letra Z',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.6);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  // Función auxiliar para obtener la ruta correcta de la imagen
  String _getImagePath(String letter) {
    if (letter == 'Ñ') {
      return 'assets/signs/N_TILDE.jpg';
    }
    return 'assets/signs/$letter.jpg';
  }

  void _speakLetter() {
    final letter = _alphabet[_currentIndex]['letter']!;
    final description = _alphabet[_currentIndex]['description']!;
    _flutterTts.speak('Letra $letter. $description');
  }

  void _nextCard() {
    if (_currentIndex < _alphabet.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1E33),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Aprender Señas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Indicador de progreso
          _buildProgressIndicator(),

          // Flashcard principal
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: _alphabet.length,
              itemBuilder: (context, index) {
                return _buildFlashcard(_alphabet[index]);
              },
            ),
          ),

          // Controles de navegación
          _buildNavigationControls(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Letra ${_currentIndex + 1} de ${_alphabet.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${((_currentIndex + 1) / _alphabet.length * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _alphabet.length,
              backgroundColor: const Color(0xFF1D1E33),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(Map<String, String> data) {
    return Center(
      child: Container(
        width: double.infinity,
        height: 620, // Altura fija para todas las tarjetas
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.9),
              const Color(0xFF4834DF).withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Letra grande
            Text(
              data['letter']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Área para imagen - TAMAÑO FIJO
            Container(
              width: 200,  // Ancho fijo
              height: 200, // Alto fijo
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  _getImagePath(data['letter']!),
                  fit: BoxFit.contain, // Mantiene la proporción sin deformar
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Descripción
            Text(
              data['description']!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Tip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      data['tip']!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botón anterior
          _buildNavButton(
            icon: Icons.arrow_back_rounded,
            onTap: _previousCard,
            enabled: _currentIndex > 0,
          ),

          // Botón escuchar
          GestureDetector(
            onTap: _speakLetter,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          // Botón siguiente
          _buildNavButton(
            icon: Icons.arrow_forward_rounded,
            onTap: _nextCard,
            enabled: _currentIndex < _alphabet.length - 1,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF1D1E33)
              : const Color(0xFF1D1E33).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled ? Colors.white24 : Colors.white10,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white24,
          size: 28,
        ),
      ),
    );
  }
}
