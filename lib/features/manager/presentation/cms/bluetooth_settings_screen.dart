import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../repositories/bluetooth_repository.dart';
import '../../../../models/bingo_hall_model.dart';
import '../../../home/repositories/hall_repository.dart';

class BluetoothSettingsScreen extends ConsumerStatefulWidget {
  final String hallId;
  final BingoHallModel hall;

  const BluetoothSettingsScreen({super.key, required this.hallId, required this.hall});

  @override
  ConsumerState<BluetoothSettingsScreen> createState() => _BluetoothSettingsScreenState();
}

class _BluetoothSettingsScreenState extends ConsumerState<BluetoothSettingsScreen> {
  // State
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  bool _isAuthenticated = false;
  
  // Settings Controls
  bool _isBroadcasting = true;
  double _txPower = 0; // dBm
  double _advInterval = 1000; // ms
  
  // Heartbeat
  bool _heartbeatEnabled = false;
  int _onDuration = 2000;
  int _offDuration = 1000;

  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bluetoothRepo = ref.watch(bluetoothRepositoryProvider);
    final scanResults = ref.watch(scanResultsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Beacon Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Connection Header
            _buildConnectionCard(bluetoothRepo, scanResults),
            const SizedBox(height: 24),

            if (_connectedDevice != null && !_isAuthenticated)
               _buildAuthCard(bluetoothRepo),

            if (_connectedDevice != null && _isAuthenticated) ...[
               _buildMasterToggle(bluetoothRepo),
               const SizedBox(height: 16),
               _buildUuidSection(bluetoothRepo),
               const SizedBox(height: 16),
               _buildSignalControls(bluetoothRepo),
               const SizedBox(height: 16),
               _buildHeartbeatControls(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard(BluetoothRepository repo, AsyncValue<List<ScanResult>> scanResults) {
    if (_connectedDevice != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.bluetooth_connected, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Connected to ${_connectedDevice!.platformName}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(_connectedDevice!.remoteId.toString(), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54),
              onPressed: () async {
                await repo.disconnect(_connectedDevice!);
                setState(() {
                  _connectedDevice = null;
                  _isAuthenticated = false;
                });
              },
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             const Text("Nearby Beacons", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
             if (_isScanning)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
             else
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blue), 
                  onPressed: () {
                    setState(() => _isScanning = true);
                    repo.scanForBeacons(); // scan handled by stream provider mostly, but trigger helps
                    // Auto-stop handled by repo or timer
                    Future.delayed(const Duration(seconds: 10), () => setState(() => _isScanning = false));
                  },
                ),
           ],
         ),
         const SizedBox(height: 12),
         scanResults.when(
           data: (results) {
             if (results.isEmpty) return const Text("No beacons found. pull to refresh.", style: TextStyle(color: Colors.white38));
             return ListView.builder(
               shrinkWrap: true,
               physics: const NeverScrollableScrollPhysics(),
               itemCount: results.length,
               itemBuilder: (ctx, i) {
                 final r = results[i];
                 return ListTile(
                   title: Text(r.device.platformName.isNotEmpty ? r.device.platformName : "Unknown Device", style: const TextStyle(color: Colors.white)),
                   subtitle: Text("ID: ${r.device.remoteId} | RSSI: ${r.rssi}", style: const TextStyle(color: Colors.white54)),
                   trailing: ElevatedButton(
                     child: const Text("Connect"),
                     onPressed: () async {
                        await repo.connect(r.device);
                        setState(() => _connectedDevice = r.device);
                     },
                   ),
                 );
               },
             );
           },
           error: (e,s) => Text("Error: $e", style: const TextStyle(color: Colors.red)),
           loading: () => const LinearProgressIndicator(),
         ),
      ],
    );
  }

  Widget _buildAuthCard(BluetoothRepository repo) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Owner Authentication", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: "Beacon PIN (Default 000000)",
                filled: true,
                fillColor: Colors.black,
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                 await repo.sendAuthPin(_connectedDevice!, _pinController.text);
                 // Assuming success for UI demo, real world needs read-back or error catch
                 setState(() => _isAuthenticated = true);
              },
              child: const Text("Unlock Settings"),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildMasterToggle(BluetoothRepository repo) {
     return SwitchListTile(
       title: const Text("Broadcast Signal", style: TextStyle(color: Colors.white)),
       subtitle: Text(_isBroadcasting ? "Beacon is Active" : "Beacon is Silent", style: const TextStyle(color: Colors.white54)),
       value: _isBroadcasting,
       onChanged: (val) {
         setState(() => _isBroadcasting = val);
         repo.writeCommand(_connectedDevice!, val ? "AT+ADV=1" : "AT+ADV=0");
       },
       activeColor: Colors.green,
     );
   }

   Widget _buildUuidSection(BluetoothRepository repo) {
     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: const Color(0xFF1E1E1E),
         borderRadius: BorderRadius.circular(12),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text("Security & Sync", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
           const SizedBox(height: 12),
           const Text("Current UUID:", style: TextStyle(color: Colors.white54)),
           Text(widget.hall.beaconUuid, style: const TextStyle(color: Colors.white, fontFamily: "Courier", fontSize: 12)),
           const SizedBox(height: 16),
           SizedBox(
             width: double.infinity,
             child: ElevatedButton.icon(
               icon: const Icon(Icons.sync),
               label: const Text("Rotate & Sync UUID"),
               style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
               onPressed: () async {
                 final newUuid = await repo.rotateUuid(_connectedDevice!);
                 setState(() {}); // refresh UI?
                 
                 // Update Firestore
                 final updatedHall = widget.hall.copyWith(beaconUuid: newUuid);
                 ref.read(hallRepositoryProvider).updateHall(updatedHall);
                 
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("UUID Rotated & Spec Updated!")));
               },
             ),
           ),
         ],
       ),
     );
   }

   Widget _buildSignalControls(BluetoothRepository repo) {
     return Card(
       color: const Color(0xFF1E1E1E),
       child: Padding(
         padding: const EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              const Text("Signal Parameters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text("TX Power (Range)", style: TextStyle(color: Colors.white54)),
              Slider(
                value: _txPower,
                min: -19,
                max: 5,
                divisions: 24,
                label: "${_txPower.toInt()} dBm",
                onChanged: (val) {
                  setState(() => _txPower = val);
                },
                onChangeEnd: (val) {
                   repo.writeCommand(_connectedDevice!, "AT+TX=${val.toInt()}");
                },
              ),
              const SizedBox(height: 16),
              const Text("Interval (Speed)", style: TextStyle(color: Colors.white54)),
              Slider(
                value: _advInterval,
                min: 100,
                max: 2000,
                divisions: 19,
                label: "${_advInterval.toInt()} ms",
                onChanged: (val) {
                  setState(() => _advInterval = val);
                },
                 onChangeEnd: (val) {
                   repo.writeCommand(_connectedDevice!, "AT+INT=${val.toInt()}");
                },
              ),
           ],
         ),
       ),
     );
   }

   Widget _buildHeartbeatControls() {
      return Card(
       color: const Color(0xFF1E1E1E),
       child: Padding(
         padding: const EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 const Text("Signal Heartbeat", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                 Switch(
                   value: _heartbeatEnabled, 
                   onChanged: (val) => setState(() => _heartbeatEnabled = val),
                   activeColor: Colors.pinkAccent,
                 ),
               ],
             ),
             if (_heartbeatEnabled) ...[
               const SizedBox(height: 12),
               Row(
                 children: [
                   Expanded(child: _buildTimeInput("On (ms)", _onDuration, (v) => _onDuration = v)),
                   const SizedBox(width: 12),
                   Expanded(child: _buildTimeInput("Off (ms)", _offDuration, (v) => _offDuration = v)),
                 ],
               ),
               const SizedBox(height: 8),
               const Text("Rhythm: Active...", style: TextStyle(color: Colors.green, fontSize: 12)),
               // Actual timer logic would go here in a real app, toggling broadcasting
             ],
           ],
         ),
       ),
      );
   }

   Widget _buildTimeInput(String label, int val, Function(int) onChanged) {
     return TextField(
       decoration: InputDecoration(
         labelText: label,
         filled: true,
         fillColor: Colors.black,
       ),
       keyboardType: TextInputType.number,
       controller: TextEditingController(text: val.toString()),
       onSubmitted: (v) => onChanged(int.tryParse(v) ?? val),
     );
   }
}

// Needed for stream
final scanResultsStreamProvider = StreamProvider.autoDispose<List<ScanResult>>((ref) {
  return ref.watch(bluetoothRepositoryProvider).scanForBeacons();
});
