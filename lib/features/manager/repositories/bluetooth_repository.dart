import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final bluetoothRepositoryProvider = Provider<BluetoothRepository>((ref) {
  return BluetoothRepository();
});

class BluetoothRepository {
  // Feasycom Standard UUIDs (common for BP101E, but we might need to be flexible)
  // For now, we scan for devices with specific names or Service UUIDs.
  // BP101E often advertises as "FSC_BP101E" or similar.
  static const String targetDeviceName = "BP101E"; 
  static const String pinServiceUuid = "0000FFF0-0000-1000-8000-00805F9B34FB"; // Example
  static const String writeCharUuid = "0000FFF2-0000-1000-8000-00805F9B34FB"; // Example

  // Using standard AT commands for Feasycom
  // AT+PIN=000000
  // AT+IBEACON=UUID...

  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Stream<List<ScanResult>> scanForBeacons() {
    // Start scanning
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    
    return FlutterBluePlus.scanResults.map((results) => 
      results
        .where((r) => r.device.platformName.toUpperCase().contains("BP101E") || 
                      r.device.platformName.toUpperCase().contains("FSC"))
        .toList()
    );
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connect(BluetoothDevice device) async {
    await device.connect();
    await device.discoverServices();
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }

  Future<void> sendAuthPin(BluetoothDevice device, String pin) async {
    // Determine strict Write Characteristic from Feasycom Docs or Scan
    // This is a simplified implementation assuming we found the correct service/char
    // Real implementation requires iterating services.
    
    final services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          // Attempt to write PIN. Feasycom usually "AT+PIN123456" or similar
          // Check docs for exact format. Assuming "AT+PIN{code}" or just raw bytes if simpler auth.
          // For Feasycom AT mode: "AT+PIN{000000}"
          String command = "AT+PIN$pin";
          try {
             await characteristic.write(command.codeUnits);
             print("Sent PIN: $command");
             return; // Success (optimistic)
          } catch(e) {
             print("Error writing PIN: $e");
          }
        }
      }
    }
  }

  Future<void> writeCommand(BluetoothDevice device, String command) async {
     final services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          try {
             await characteristic.write(command.codeUnits);
             print("Sent Command: $command");
             return; 
          } catch(e) {
             print("Error writing command: $e");
             rethrow;
          }
        }
      }
    }
  }

  Future<String> rotateUuid(BluetoothDevice device) async {
    // 1. Generate new UUID
    // Standard format: 8-4-4-4-12 hex
    // Using a library or simple randomizer
    final newUuid = _generateRandomUuid();
    
    // 2. Formulate AT command
    // Feasycom: AT+IBEACON=UUID,Major,Minor... verify spec.
    // Assuming AT+UUID={newUuid}
    String command = "AT+UUID$newUuid";
    
    await writeCommand(device, command);
    
    // 3. Wait/Verify (optional read back)
    
    return newUuid;
  }
  
  String _generateRandomUuid() {
    // Simple mock random UUID v4
    // Implementation of valid UUID v4 generator
    return "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"; // Placeholder for true random
  }
}
