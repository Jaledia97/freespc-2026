import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:freespc/models/venue_model.dart';

final bluetoothRepositoryProvider = Provider<BluetoothRepository>((ref) {
  return BluetoothRepository();
});

class BluetoothRepository {
  // Feasycom Standard UUIDs (common for BP101E, but we might need to be flexible)
  // For now, we scan for devices with specific names or Service UUIDs.
  // BP101E often advertises as "FSC_BP101E" or similar.
  static const String targetDeviceName = "BP101E";
  static const String pinServiceUuid =
      "0000FFF0-0000-1000-8000-00805F9B34FB"; // Example
  static const String writeCharUuid =
      "0000FFF2-0000-1000-8000-00805F9B34FB"; // Example

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

    return FlutterBluePlus.scanResults.map(
      (results) => results
          .where(
            (r) =>
                r.device.platformName.toUpperCase().contains("BP101E") ||
                r.device.platformName.toUpperCase().contains("FSC"),
          )
          .toList(),
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

  String getVenuePin(VenueModel venue) {
    if (venue.beaconPin != null && venue.beaconPin!.length == 6) {
      return venue.beaconPin!;
    }
    int hash = venue.id.hashCode.abs();
    // Mathematically clamp hash to a 6-digit number between 100000 and 999999
    String pin = ((hash % 899999) + 100000).toString();
    return pin;
  }

  Future<void> sendAuthPin(BluetoothDevice device, String pin) async {
    // AT Command Authentication Payload requires \r\n
    String command = "AT+PIN$pin\r\n";
    await _writeToFff2(device, command);
  }

  Future<void> lockHardwarePin(BluetoothDevice device, String newPin) async {
    // Modify actual hardware PIN so unauthorized users cannot hijack it
    // Wait for auth to complete first sequentially
    await _writeToFff2(device, "AT+PIN$newPin\r\n");
  }

  Future<void> writeCommand(BluetoothDevice device, String command) async {
    if (!command.endsWith("\r\n")) {
      command += "\r\n";
    }
    await _writeToFff2(device, command);
  }

  Future<void> _writeToFff2(BluetoothDevice device, String command) async {
    final services = await device.discoverServices();
    for (var service in services) {
      // Safely support both 16-bit ("FFF0") and 128-bit ("0000FFF0...") representations
      if (service.uuid.toString().toUpperCase().contains("FFF0")) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toUpperCase().contains("FFF2")) {
            try {
              // Enforce strict GATT Write Confirmations to absolutely verify hardware processed the command
              await characteristic.write(command.codeUnits, withoutResponse: false);
              debugPrint("Successfully Sent Command: $command");
              return;
            } catch (e) {
              debugPrint("Error writing command [$command]: $e");
              rethrow;
            }
          }
        }
      }
    }
    throw Exception("Target AT Command Service/Characteristic (FFF0/FFF2) not found on device.");
  }

  Future<String> rotateUuid(BluetoothDevice device) async {
    // 1. Generate new UUID dynamically
    final newUuid = const Uuid().v4();

    // 2. Formulate AT command (Feasycom typically uses AT+IUUID= without dashes)
    String formattedUuid = newUuid.replaceAll('-', '').toUpperCase();
    String command = "AT+IUUID$formattedUuid"; // Can be AT+IUUID=... depending on specific firmware, standard is no =

    await writeCommand(device, command);

    return newUuid; // Return the standard dash format for Firestore
  }
}
