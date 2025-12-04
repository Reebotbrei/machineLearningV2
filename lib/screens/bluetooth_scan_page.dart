import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'alphabet_sign_screen.dart';
import '../theme/colors.dart';

class BluetoothScanScreen extends StatefulWidget {
  const BluetoothScanScreen({Key? key}) : super(key: key);

  @override
  State<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<bool>? _isScanningSubscription;

  @override
  void initState() {
    super.initState();
    _startScan();
    
    // Escuchar cambios en el estado de escaneo
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((scanning) {
      if (mounted) {
        setState(() {
          _isScanning = scanning;
        });
      }
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _isScanningSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _scanResults.clear();
    });

    try {
      // Iniciar escaneo
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
      );

      // Escuchar resultados
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          if (mounted) {
            setState(() {
              _scanResults = results;
            });
          }
        },
        onError: (e) {
          print("Error en escaneo: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al escanear: $e'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
      );
    } catch (e) {
      print("Error al iniciar escaneo: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    // Detener escaneo
    await FlutterBluePlus.stopScan();

    // Mostrar loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.fondo2,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.icon),
              const SizedBox(height: 16),
              Text(
                'Conectando...',
                style: TextStyle(color: AppColors.icon, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Conectar con timeout
      await device.connect(timeout: const Duration(seconds: 10));

      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading

      // Navegar a AlphabetSignScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AlphabetSignScreen(device: device),
        ),
      );
    } catch (e) {
      print("Error al conectar: $e");
      
      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al conectar: $e'),
          backgroundColor: Colors.redAccent,
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: () => _connectToDevice(device),
          ),
        ),
      );
    }
  }

  String _getDeviceName(ScanResult result) {
    // Priorizar el nombre del advertisement data
    if (result.advertisementData.advName.isNotEmpty) {
      return result.advertisementData.advName;
    }
    // Si no hay nombre, usar el ID
    if (result.device.platformName.isNotEmpty) {
      return result.device.platformName;
    }
    return 'Dispositivo desconocido';
  }

  bool _isTargetDevice(ScanResult result) {
    // Verificar si es nuestro ESP32 por UUID
    return result.advertisementData.serviceUuids.any(
      (uuid) => uuid.toString().toLowerCase() == "abcdef01-1234-5678-1234-56789abcdef0",
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Dispositivos Bluetooth',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.icon,
          ),
        ),
        actions: [
          if (_isScanning)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.icon),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.icon),
              onPressed: _startScan,
              tooltip: 'Reescanear',
            ),
        ],
      ),
      body: Column(
        children: [
          // Header con información
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fondo2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.icon.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
                  color: AppColors.icon,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isScanning ? 'Escaneando...' : 'Escaneo completado',
                        style: TextStyle(
                          color: AppColors.icon,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_scanResults.length} dispositivos encontrados',
                        style: TextStyle(
                          color: AppColors.subtytle,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de dispositivos
          Expanded(
            child: _scanResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isScanning ? Icons.bluetooth_searching : Icons.bluetooth_disabled,
                          size: 64,
                          color: AppColors.subtytle.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isScanning 
                              ? 'Buscando dispositivos...'
                              : 'No se encontraron dispositivos',
                          style: TextStyle(
                            color: AppColors.subtytle,
                            fontSize: 16,
                          ),
                        ),
                        if (!_isScanning) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _startScan,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Escanear nuevamente'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.icon,
                              foregroundColor: AppColors.subtytle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final result = _scanResults[index];
                      final isTarget = _isTargetDevice(result);
                      final deviceName = _getDeviceName(result);
                      final rssi = result.rssi;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.fondo2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isTarget 
                                ? Colors.greenAccent.withOpacity(0.5)
                                : Colors.white.withOpacity(0.1),
                            width: isTarget ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isTarget 
                                  ? Colors.greenAccent.withOpacity(0.2)
                                  : AppColors.fondo.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isTarget ? Icons.camera_alt : Icons.bluetooth,
                              color: isTarget ? Colors.greenAccent : AppColors.icon,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            deviceName,
                            style: TextStyle(
                              color: AppColors.icon,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                result.device.remoteId.toString(),
                                style: TextStyle(
                                  color: AppColors.subtytle,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.signal_cellular_alt,
                                    size: 14,
                                    color: _getSignalColor(rssi),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$rssi dBm',
                                    style: TextStyle(
                                      color: _getSignalColor(rssi),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isTarget) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'ESP32-CAM',
                                        style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.icon,
                            size: 20,
                          ),
                          onTap: () => _connectToDevice(result.device),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(int rssi) {
    if (rssi >= -60) return Colors.greenAccent;
    if (rssi >= -80) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
