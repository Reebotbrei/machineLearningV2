import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import '../theme/colors.dart';

class AlphabetSignScreen extends StatefulWidget {
  final BluetoothDevice device;

  const AlphabetSignScreen({super.key, required this.device});

  @override
  State<AlphabetSignScreen> createState() => _AlphabetSignScreenState();
}

class _AlphabetSignScreenState extends State<AlphabetSignScreen> {
  // TTS
  final FlutterTts _flutterTts = FlutterTts();

  // Datos en tiempo real
  String _currentLetter = '-';
  double _confidence = 0.0;
  bool _isConnected = false;

  // Palabra formada
  String _currentWord = '';
  final List<String> _completedWords = [];

  // Control de duplicados
  String _lastLetter = '';
  DateTime _lastLetterTime = DateTime.now();
  static const Duration _letterCooldown = Duration(milliseconds: 1500);

  // BLE
  BluetoothCharacteristic? targetCharacteristic;
  StreamSubscription? _notificationSub;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSub;

  @override
  void initState() {
    super.initState();
    _initTTS();
    _setupConnectionListener();
    _discoverServicesAndListen();
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.6);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  void _setupConnectionListener() {
    // Escuchar cambios en el estado de conexión
    _connectionStateSub = widget.device.connectionState.listen(
      (state) {
        if (!mounted) return;
        
        setState(() {
          _isConnected = (state == BluetoothConnectionState.connected);
        });

        // Si se desconecta, volver atrás
        if (state == BluetoothConnectionState.disconnected) {
          if (mounted) {
            Navigator.pop(context);
          }
        }
      },
      onError: (error) {
        print("Error en conexión: $error");
      },
    );
  }

  Future<void> _discoverServicesAndListen() async {
    try {
      List<BluetoothService> services = await widget.device.discoverServices();
      
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toLowerCase() ==
              "abcdef01-1234-5678-1234-56789abcdef0" &&
              (characteristic.properties.notify || characteristic.properties.indicate)) {
            
            // Activar notificaciones
            await characteristic.setNotifyValue(true);
            
            // Escuchar notificaciones
            _notificationSub = characteristic.lastValueStream.listen(
              (value) {
                // ✅ Verificar mounted antes de procesar
                if (!mounted) return;
                
                final received = String.fromCharCodes(value).trim();
                if (received.isNotEmpty) {
                  _handleIncomingData(received);
                }
              },
              onError: (error) {
                print("Error en notificaciones: $error");
              },
              cancelOnError: false,
            );
            
            if (mounted) {
              setState(() => targetCharacteristic = characteristic);
            }
            return;
          }
        }
      }
    } catch (e) {
      print("Error al descubrir servicios: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al conectar con ESP32: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _handleIncomingData(String message) {
    if (!mounted) return; // ✅ Verificación adicional
    
    try {
      // Parsear: "LETRA|CONFIANZA|"
      List<String> parts = message.split('|');
      if (parts.length >= 2) {
        String letter = parts[0].trim();
        double confidence = double.parse(parts[1]);
        processIncomingData(letter, confidence);
      }
    } catch (e) {
      print("Error al parsear datos: $e");
    }
  }

  void processIncomingData(String letter, double confidence) {
    if (!mounted) return; // ✅ Verificar antes de setState
    
    final now = DateTime.now();
    if (letter == _lastLetter && now.difference(_lastLetterTime) < _letterCooldown) {
      return;
    }

    _lastLetter = letter;
    _lastLetterTime = now;

    setState(() {
      _currentLetter = letter.toUpperCase();
      _confidence = confidence;

      if (letter != '-' && letter != 'SPACE' && letter != 'DEL') {
        _currentWord += letter.toUpperCase();
      }
    });

    // Leer la letra en voz alta
    _flutterTts.speak(letter);
  }

  void _speakCurrentWord() async {
    if (_currentWord.isNotEmpty) {
      await _flutterTts.speak(_currentWord);
    }
  }

  void _confirmWord() {
    if (!mounted) return; // ✅ Verificar mounted
    
    if (_currentWord.isNotEmpty) {
      setState(() {
        _completedWords.insert(0, _currentWord);
        if (_completedWords.length > 10) {
          _completedWords.removeLast();
        }
        _currentWord = '';
      });
    }
  }

  void _deleteLetter() {
    if (!mounted) return; // ✅ Verificar mounted
    
    if (_currentWord.isNotEmpty) {
      setState(() {
        _currentWord = _currentWord.substring(0, _currentWord.length - 1);
      });
    }
  }

  void _clearWord() {
    if (!mounted) return; // ✅ Verificar mounted
    
    setState(() {
      _currentWord = '';
    });
  }

  Future<void> disconnect() async {
    try {
      // Desactivar notificaciones antes de desconectar
      if (targetCharacteristic != null) {
        await targetCharacteristic!.setNotifyValue(false);
      }
      
      // Desconectar dispositivo
      await widget.device.disconnect();
    } catch (e) {
      print("Error al desconectar: $e");
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    // Cancelar todas las suscripciones
    _notificationSub?.cancel();
    _connectionStateSub?.cancel();
    
    // Desactivar notificaciones y desconectar
    targetCharacteristic?.setNotifyValue(false).catchError((e) {
      print("Error al desactivar notificaciones: $e");
    });
    
    widget.device.disconnect().catchError((e) {
      print("Error al desconectar en dispose: $e");
    });
    
    // Detener TTS
    _flutterTts.stop();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.fondo2,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.icon),
          onPressed: disconnect,
        ),
        title: Text(
          'Abecedario de Señas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.icon,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: _isConnected ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCurrentLetterCard(),
          const SizedBox(height: 16),
          _buildWordBuilder(),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 16),
          _buildWordHistory(),
        ],
      ),
    );
  }

  Widget _buildCurrentLetterCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.fondo2.withOpacity(0.9),
            AppColors.fondo.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.fondo2.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'LETRA DETECTADA',
            style: TextStyle(
              color: AppColors.subtytle,
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _currentLetter,
            style: TextStyle(
              color: AppColors.icon,
              fontSize: 90,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.speed, color: AppColors.subtytle, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${(_confidence * 100).toStringAsFixed(0)}% confianza',
                  style: TextStyle(
                    color: AppColors.icon,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordBuilder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.fondo2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.greenAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Palabra en formación',
                style: TextStyle(
                  color: AppColors.subtytle,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fondo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentWord.isEmpty ? '...' : _currentWord,
              style: TextStyle(
                color: _currentWord.isEmpty ? AppColors.subtytle : Colors.greenAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.backspace_outlined,
              label: 'Borrar',
              color: Colors.orangeAccent,
              onTap: _deleteLetter,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
              icon: Icons.volume_up_rounded,
              label: 'Escuchar',
              color: Colors.blueAccent,
              onTap: _speakCurrentWord,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
              icon: Icons.check_circle_outline,
              label: 'Confirmar',
              color: Colors.greenAccent,
              onTap: _confirmWord,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
              icon: Icons.clear_rounded,
              label: 'Limpiar',
              color: Colors.redAccent,
              onTap: _clearWord,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordHistory() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.fondo2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.fondo2.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.history, color: AppColors.icon, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Palabras completadas',
                  style: TextStyle(
                    color: AppColors.subtytle,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _completedWords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, color: AppColors.subtytle.withOpacity(0.3), size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Aún no hay palabras',
                            style: TextStyle(color: AppColors.subtytle, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _completedWords.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.fondo,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.fondo2.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: AppColors.icon,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  _completedWords[index],
                                  style: TextStyle(
                                    color: AppColors.icon,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _flutterTts.speak(_completedWords[index]),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.volume_up_rounded,
                                    color: Colors.blueAccent,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
