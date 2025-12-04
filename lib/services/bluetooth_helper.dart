import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothHelper {
  // Inicia el escaneo de dispositivos Bluetooth por un tiempo determinado
  static void startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
  }

  // Escucha los resultados del escaneo y pasa los resultados al callback proporcionado
  static void listenScanResults(void Function(List<ScanResult>) onData) {
    FlutterBluePlus.scanResults.listen(onData);
  }

  // Detiene el escaneo de dispositivos Bluetooth
  static void stopScan() {
    FlutterBluePlus.stopScan();
  }
}
