import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../repositories/bluetooth_repository.dart';
import '../../../../models/venue_model.dart';
import '../../../home/repositories/venue_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothSettingsScreen extends ConsumerStatefulWidget {
  final String venueId;
  final VenueModel venue;

  const BluetoothSettingsScreen({
    super.key,
    required this.venueId,
    required this.venue,
  });

  @override
  ConsumerState<BluetoothSettingsScreen> createState() =>
      _BluetoothSettingsScreenState();
}

class _BluetoothSettingsScreenState
    extends ConsumerState<BluetoothSettingsScreen> {
  // State
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  bool _isAuthenticated = false;

  // Signal Analytics
  int _currentRssi = -100;
  Timer? _rssiTimer;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  // Controllers
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Settings Controls
  late bool _isBroadcasting;
  late double _txPower; // dBm
  late double _advInterval; // ms
  bool _isDeployingExtender = false;
  String? _beaconToHide;
  Map<String, String> _customNames = {};

  // Heartbeat
  bool _heartbeatEnabled = false;
  int _onDuration = 2000;
  int _offDuration = 1000;

  final List<Map<String, dynamic>> _txPowerLevels = [
    {"index": 0, "label": "-21 dBm (Minimum)"},
    {"index": 1, "label": "-18 dBm"},
    {"index": 2, "label": "-15 dBm"},
    {"index": 3, "label": "-12 dBm"},
    {"index": 4, "label": "-9 dBm"},
    {"index": 5, "label": "-6 dBm"},
    {"index": 6, "label": "-3 dBm"},
    {"index": 7, "label": "0 dBm (Default)"},
    {"index": 8, "label": "+3 dBm"},
    {"index": 9, "label": "+4 dBm"},
    {"index": 10, "label": "+5 dBm (Standard Max)"},
    {"index": 11, "label": "+8 dBm"},
    {"index": 12, "label": "+10 dBm"},
    {"index": 13, "label": "+15 dBm"},
    {"index": 14, "label": "+20 dBm (Ultra Range)"},
  ];

  bool _showPinUpdate = false;

  void _startRssiPolling() {
    _rssiTimer?.cancel();
    _rssiTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_connectedDevice != null && mounted) {
        try {
          final rssi = await _connectedDevice!.readRssi();
          if (mounted) setState(() => _currentRssi = rssi);
        } catch (_) {}
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _isBroadcasting = widget.venue.isBroadcasting;
    _advInterval = widget.venue.advInterval;

    // Convert raw dBm to firmware index recursively
    double storedTx = widget.venue.txPower;
    if (storedTx < 0) {
      // Legacy layout detected, default safely to Index 7 (0dBm)
      _txPower = 7.0; 
    } else {
      _txPower = storedTx;
    }
    _loadCustomNames();
  }

  Future<void> _loadCustomNames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        for (String key in prefs.getKeys()) {
          if (key.startsWith("beacon_name_")) {
            String mac = key.replaceFirst("beacon_name_", "");
            _customNames[mac] = prefs.getString(key) ?? "";
          }
        }
      });
    } catch (e) {
      debugPrint("Failed to parse Local Nicknames.");
    }
  }

  @override
  void dispose() {
    _rssiTimer?.cancel();
    _connectionStateSubscription?.cancel();
    _pinController.dispose();
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _listenToConnectionState(BluetoothDevice device) {
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = device.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.disconnected && mounted && _isAuthenticated) {
        // Suspend the active tracker natively
        _rssiTimer?.cancel();
        if (mounted) setState(() => _currentRssi = -100);

        // Natively deploy a background auto-reconnect sequence masking the hardware reboot 
        try {
          // FBP inherently waits for hardware availability when autoConnect is implicitly specified
          await device.connect(timeout: const Duration(seconds: 15));
          await device.discoverServices();
          
          if (mounted) {
            String activePin = widget.venue.beaconPin ?? ref.read(bluetoothRepositoryProvider).getVenuePin(widget.venue);
            await ref.read(bluetoothRepositoryProvider).sendAuthPin(device, activePin);
            _startRssiPolling();
          }
        } catch (e) {
          debugPrint("Continuous hardware auto-reconnect failed natively tracking the disconnected hardware!");
        }
      }
    });
  }

  Widget _buildRssiBadge() {
    Color signalColor;
    String signalText;
    
    if (_currentRssi >= -50) {
      signalColor = Colors.greenAccent;
      signalText = "Excellent";
    } else if (_currentRssi >= -70) {
      signalColor = Colors.lightGreen;
      signalText = "Good";
    } else if (_currentRssi >= -85) {
      signalColor = Colors.orange;
      signalText = "Fair";
    } else {
      signalColor = Colors.redAccent;
      signalText = "Weak";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(Icons.signal_cellular_alt, color: signalColor, size: 20),
        const SizedBox(height: 4),
        Text(
          "$_currentRssi dBm",
          style: TextStyle(color: signalColor, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          signalText,
          style: TextStyle(color: signalColor.withOpacity(0.8), fontSize: 10),
        ),
      ],
    );
  }

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
              _buildSignalControls(bluetoothRepo),
              const SizedBox(height: 16),
              _buildHeartbeatControls(),
              const SizedBox(height: 16),
              _buildUuidSection(bluetoothRepo),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard(
    BluetoothRepository repo,
    AsyncValue<List<ScanResult>> scanResults,
  ) {
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
                  Text(
                    "Connected to ${_connectedDevice!.platformName}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _connectedDevice!.remoteId.toString(),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            _buildRssiBadge(),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54),
              onPressed: () async {
                _rssiTimer?.cancel();
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
            Text(
              _isDeployingExtender ? "Select Target Range Extender" : "Nearby Beacons",
              style: TextStyle(
                color: _isDeployingExtender ? Colors.purpleAccent : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isDeployingExtender)
              TextButton(
                onPressed: () {
                   setState(() { _isDeployingExtender = false; });
                },
                child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
              )
            else if (_isScanning)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.blue),
                onPressed: () {
                  setState(() => _isScanning = true);
                  repo.scanForBeacons(); // scan handled by stream provider mostly, but trigger helps
                  // Auto-stop handled by repo or timer
                  Future.delayed(
                    const Duration(seconds: 10),
                    () => setState(() => _isScanning = false),
                  );
                },
              ),
          ],
        ),
        if (_isDeployingExtender) ...[
          const SizedBox(height: 8),
          const Text(
            "Please select a fresh unconfigured factory beacon from the list below. The physical cloning sequence will map your venue arrays seamlessly onto it.",
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
        const SizedBox(height: 12),
        scanResults.when(
          data: (results) {
            List<ScanResult> activeResults = results;
            if (_isDeployingExtender && _beaconToHide != null) {
              activeResults = results.where((r) => r.device.remoteId.toString() != _beaconToHide).toList();
            }

            if (activeResults.isEmpty)
              return const Text(
                "No beacons found. pull to refresh.",
                style: TextStyle(color: Colors.white38),
              );
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeResults.length,
              itemBuilder: (ctx, i) {
                final r = activeResults[i];
                final mac = r.device.remoteId.toString();
                final activeName = _customNames[mac] ?? (r.advertisementData.advName.isNotEmpty
                    ? r.advertisementData.advName
                    : (r.device.platformName.isNotEmpty ? r.device.platformName : "Unknown Device"));

                return ListTile(
                  title: Text(
                    activeName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "ID: ${r.device.remoteId} | RSSI: ${r.rssi}",
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: ElevatedButton(
                    child: const Text("Connect"),
                    onPressed: () async {
                      setState(() => _isScanning = true);
                      try {
                        await repo.connect(r.device);
                        setState(() {
                          _connectedDevice = r.device;
                          _isScanning = false;
                        });
                        
                        if (_isDeployingExtender) {
                          await _deployRangeExtender(r.device);
                          return;
                        }

                        // Automatically authenticate
                        await repo.sendAuthPin(
                          r.device,
                          widget.venue.beaconPin ?? repo.getVenuePin(widget.venue),
                        );
                        
                        _listenToConnectionState(r.device);
                        _startRssiPolling();
                        if (mounted) {
                          setState(() {
                             _isAuthenticated = true;
                             _nameController.text = _customNames[r.device.remoteId.toString()] ?? (activeName != "Unknown Device" ? activeName : "BP101E");
                          });
                        }
                      } catch (e) {
                         if(mounted) setState(() => _isScanning = false); 
                      }
                    },
                  ),
                );
              },
            );
          },
          error: (e, s) =>
              Text("Error: $e", style: const TextStyle(color: Colors.red)),
          loading: () => const LinearProgressIndicator(),
        ),
      ],
    );
  }

  Future<void> _deployRangeExtender(BluetoothDevice device) async {
    final repo = ref.read(bluetoothRepositoryProvider);
    try {
      // 1. Authenticate with factory default natively to target the fresh unconfigured beacon
      await repo.writeCommand(device, "AT+PIN000000");
      await Future.delayed(const Duration(milliseconds: 100));

      // 2. Overwrite the Node's active hardware pin to the core Venue Pin securely
      String activePin = widget.venue.beaconPin ?? repo.getVenuePin(widget.venue);
      await repo.lockHardwarePin(device, activePin);
      await Future.delayed(const Duration(milliseconds: 100));

      // 3. Force the active module onto the shared coordinate footprint
      String cleanUuid = widget.venue.beaconUuid.replaceAll("-", "").toUpperCase();
      await repo.writeCommand(device, "AT+IUUID$cleanUuid");
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 4. Sync default signal rules natively
      await repo.writeCommand(device, "AT+TX=${widget.venue.txPower.toInt()}");
      await Future.delayed(const Duration(milliseconds: 100));
      await repo.writeCommand(device, "AT+INT=${widget.venue.advInterval.toInt()}");
      await Future.delayed(const Duration(milliseconds: 100));

      // 5. Explicit Custom Naming
      if (_nameController.text.isNotEmpty) {
          await repo.writeCommand(device, "AT+NAME=${_nameController.text}");
          await Future.delayed(const Duration(milliseconds: 100));
      }

      if (mounted) {
        setState(() { _isDeployingExtender = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Module securely cloned! It is now a Range Extender!"), backgroundColor: Colors.purple),
        );
        // Authenticate normally so they land securely inside its dashboard
        await repo.sendAuthPin(device, activePin);
        _listenToConnectionState(device);
        _startRssiPolling();
        if (mounted) setState(() => _isAuthenticated = true);
      }
    } catch (e) {
      if (mounted) {
         setState(() { _isDeployingExtender = false; _connectedDevice = null; _isAuthenticated = false; });
         device.disconnect();
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Failed to deploy Extender: $e"), backgroundColor: Colors.red)
         );
      }
    }
  }

  Widget _buildAuthCard(BluetoothRepository repo) {
    bool isClaimedByMe = widget.venue.beaconUuid != "PENDING_CONFIG" && widget.venue.beaconUuid.length > 20;

    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Owner Authentication",
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (!isClaimedByMe)
              TextField(
                controller: _pinController,
                decoration: const InputDecoration(
                  labelText: "Beacon PIN (Default 000000)",
                  filled: true,
                  fillColor: Colors.black,
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Secured natively with Automated Venue PIN. No manual entry required.",
                  style: TextStyle(color: Colors.green, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                try {
                  String submissionPin = isClaimedByMe ? repo.getVenuePin(widget.venue) : _pinController.text;
                  await repo.sendAuthPin(_connectedDevice!, submissionPin);
                  setState(() => _isAuthenticated = true);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Hardware Rejection - Unauthorized Access: $e")),
                    );
                  }
                }
              },
              child: const Text("Unlock Secure Settings"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterToggle(BluetoothRepository repo) {
    return SwitchListTile(
      title: const Text(
        "Broadcast Signal",
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        _isBroadcasting ? "Beacon is Active" : "Beacon is Silent",
        style: const TextStyle(color: Colors.white54),
      ),
      value: _isBroadcasting,
      onChanged: (val) {
        setState(() => _isBroadcasting = val);
        repo.writeCommand(_connectedDevice!, val ? "AT+ADV=1" : "AT+ADV=0");
      },
      activeThumbColor: Colors.green,
    );
  }

  Widget _buildUuidSection(BluetoothRepository repo) {
    bool isClaimedByMe = widget.venue.beaconUuid != "PENDING_CONFIG" && widget.venue.beaconUuid.length > 20;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isClaimedByMe ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        border: Border.all(color: isClaimedByMe ? Colors.green : Colors.orange),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isClaimedByMe ? Icons.lock : Icons.lock_open, color: isClaimedByMe ? Colors.green : Colors.orange),
              const SizedBox(width: 8),
              Text(
                isClaimedByMe ? "Hardware Lock Enabled" : "Hardware is Unclaimed",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isClaimedByMe
                ? "This beacon's identity signature and hardware PIN are firmly locked to your CMS. No other business can remotely control it."
                : "Claim this beacon to securely rotate its hardware signature and lock its PIN tracking natively to this venue.",
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (isClaimedByMe) ...[
            const Text("Secured UUID:", style: TextStyle(color: Colors.white54, fontSize: 12)),
            Text(
              widget.venue.beaconUuid,
              style: const TextStyle(color: Colors.white, fontFamily: "Courier", fontSize: 11),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Hardware Display Name",
                filled: true,
                fillColor: Colors.black,
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(_showPinUpdate ? Icons.cancel : Icons.lock_reset),
                label: Text(_showPinUpdate ? "Cancel PIN Change" : "Set New PIN"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black26, foregroundColor: Colors.white),
                onPressed: () {
                  setState(() {
                    _showPinUpdate = !_showPinUpdate;
                    if (!_showPinUpdate) {
                      _oldPinController.clear();
                      _newPinController.clear();
                      _confirmPinController.clear();
                    }
                  });
                },
              ),
            ),
            if (_showPinUpdate) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _oldPinController,
                decoration: const InputDecoration(
                  labelText: "Current Hardware PIN",
                  filled: true,
                  fillColor: Colors.black,
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 8),
              Row(
                 children: [
                   Expanded(
                     child: TextField(
                       controller: _newPinController,
                       decoration: const InputDecoration(
                         labelText: "New PIN",
                         filled: true,
                         fillColor: Colors.black,
                       ),
                       style: const TextStyle(color: Colors.white),
                       keyboardType: TextInputType.number,
                       maxLength: 6,
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     child: TextField(
                       controller: _confirmPinController,
                       decoration: const InputDecoration(
                         labelText: "Confirm PIN",
                         filled: true,
                         fillColor: Colors.black,
                       ),
                       style: const TextStyle(color: Colors.white),
                       keyboardType: TextInputType.number,
                       maxLength: 6,
                     ),
                   ),
                 ]
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Bluetooth Settings"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                onPressed: () async {
                  try {
                    // Check if they are trying to update PIN
                    if (_oldPinController.text.isNotEmpty || _newPinController.text.isNotEmpty || _confirmPinController.text.isNotEmpty) {
                      String validCurrentPin = widget.venue.beaconPin ?? repo.getVenuePin(widget.venue);
                      
                      if (_oldPinController.text != validCurrentPin) {
                        throw "Current PIN is incorrect!";
                      }
                      if (_newPinController.text.length != 6) {
                        throw "New PIN must be exactly 6 digits!";
                      }
                      if (_newPinController.text != _confirmPinController.text) {
                        throw "New PINs do not match!";
                      }
                      
                      // Physically apply the new PIN
                      await repo.lockHardwarePin(_connectedDevice!, _newPinController.text);
                      
                      // Cloud sync the new PIN
                      final updatedHall = widget.venue.copyWith(
                        beaconPin: _newPinController.text,
                        txPower: _txPower,
                        advInterval: _advInterval,
                        isBroadcasting: _isBroadcasting,
                      );
                      ref.read(venueRepositoryProvider).updateHall(updatedHall);
                      
                      _oldPinController.clear();
                      _newPinController.clear();
                      _confirmPinController.clear();
                      if (mounted) setState(() => _showPinUpdate = false);
                    }

                    // Save Signal Parameters synchronously
                    await repo.writeCommand(_connectedDevice!, "AT+TX=${_txPower.toInt()}");
                    await Future.delayed(const Duration(milliseconds: 100));
                    await repo.writeCommand(_connectedDevice!, "AT+INT=${_advInterval.toInt()}");
                    await Future.delayed(const Duration(milliseconds: 100));
                    
                    if (_nameController.text.isNotEmpty) {
                       final prefs = await SharedPreferences.getInstance();
                       await prefs.setString("beacon_name_${_connectedDevice!.remoteId.toString()}", _nameController.text);
                       if (mounted) {
                          setState(() { _customNames[_connectedDevice!.remoteId.toString()] = _nameController.text; });
                       }
                      
                       await repo.writeCommand(_connectedDevice!, "AT+NAME=${_nameController.text}");
                       await Future.delayed(const Duration(milliseconds: 100));
                    }
                    
                    // Hardware LED Pulse Formatting
                    String ledCommand = _heartbeatEnabled ? "AT+LED=1,${_onDuration},${_offDuration}" : "AT+LED=0";
                    await repo.writeCommand(_connectedDevice!, ledCommand);
                    await Future.delayed(const Duration(milliseconds: 100));
                    
                    // Always lock variables up to Firebase, even if no PIN changed
                    final updatedHall = widget.venue.copyWith(
                      txPower: _txPower,
                      advInterval: _advInterval,
                      isBroadcasting: _isBroadcasting,
                    );
                    ref.read(venueRepositoryProvider).updateHall(updatedHall);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Hardware synchronized successfully!"), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                      print("SAVE ERROR EXCEPTION TRACE: $e");
                      if (mounted) {
                        if (e.toString().contains("REMOTE_USER_TERMINATED_CONNECTION") || e.toString().contains("not connected")) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Hardware synchronized successfully! Beacon is restarting."), backgroundColor: Colors.green),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to Compile Settings: $e"), backgroundColor: Colors.red),
                          );
                        }
                    }
                  }
                }
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  try {
                    // Downgrade hardware PIN back to factory default
                    await repo.lockHardwarePin(_connectedDevice!, "000000");

                    // Release ownership in Firestore
                    final updatedHall = widget.venue.copyWith(beaconUuid: "PENDING_CONFIG");
                    ref.read(venueRepositoryProvider).updateHall(updatedHall);

                    if (mounted) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Hardware unlinked & surrendered to factory state.")),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to release hardware: $e")));
                    }
                  }
                },
                child: const Text("Unclaim & Factory Reset"),
              ),
            ),
            const Divider(color: Colors.white24, height: 40),
            const Text("Fleet Architect", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
            const Text(
              "Expand your venue's physical tracking footprint by cloning identical configurations onto subsequent beacons locally extending the range.",
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_link),
                label: const Text("Add a Range Extender"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, foregroundColor: Colors.white),
                onPressed: () async {
                    _beaconToHide = _connectedDevice?.remoteId.toString();
                    _connectedDevice?.disconnect();
                    if (mounted) {
                      setState(() {
                         _isDeployingExtender = true;
                         _connectedDevice = null;
                         _isAuthenticated = false;
                         _currentRssi = -100;
                         _isScanning = true;
                      });
                      ref.read(bluetoothRepositoryProvider).scanForBeacons();
                    }
                }
              ),
            ),
          ] else ...[
            TextField(
              controller: _newPinController,
              decoration: const InputDecoration(
                labelText: "Set Unique 6-Digit PIN (Required)",
                filled: true,
                fillColor: Colors.black,
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.link),
                label: const Text("Claim & Lock Beacon"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.black),
                onPressed: () async {
                  try {
                    if (_newPinController.text.length != 6) {
                      throw "You must define a 6-digit PIN securely locking this hardware!";
                    }

                    // Physically lock the new custom PIN
                    await repo.lockHardwarePin(_connectedDevice!, _newPinController.text);

                    // Update Tracker UUID
                    final newUuid = await repo.rotateUuid(_connectedDevice!);

                      // Update Firestore bounds locking the new Custom PIN
                      final updatedHall = widget.venue.copyWith(
                        beaconUuid: newUuid,
                        beaconPin: _newPinController.text,
                        txPower: _txPower,
                        advInterval: _advInterval,
                        isBroadcasting: _isBroadcasting,
                      );
                      ref.read(venueRepositoryProvider).updateHall(updatedHall);

                    if (mounted) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Hardware Successfully Claimed & Locked!")),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Claim Beacon: $e")));
                    }
                  }
                },
              ),
            ),
          ],
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
            const Text(
              "Signal Parameters",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "TX Power (Range)",
              style: TextStyle(color: Colors.white54),
            ),
            Slider(
              value: _txPower,
              min: 0,
              max: (_txPowerLevels.length - 1).toDouble(),
              divisions: _txPowerLevels.length - 1,
              label: _txPowerLevels[_txPower.toInt()]["label"],
              onChanged: (val) {
                setState(() => _txPower = val);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "Interval (Speed)",
              style: TextStyle(color: Colors.white54),
            ),
            Slider(
              value: _advInterval,
              min: 100,
              max: 2000,
              divisions: 19,
              label: "${_advInterval.toInt()} ms",
              onChanged: (val) {
                setState(() => _advInterval = val);
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
                const Text(
                  "Signal Heartbeat",
                  style: TextStyle(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _heartbeatEnabled,
                  onChanged: (val) => setState(() => _heartbeatEnabled = val),
                  activeThumbColor: Colors.pinkAccent,
                ),
              ],
            ),
            if (_heartbeatEnabled) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeInput(
                      "On (ms)",
                      _onDuration,
                      (v) => _onDuration = v,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeInput(
                      "Off (ms)",
                      _offDuration,
                      (v) => _offDuration = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Rhythm: Active...",
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
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
final scanResultsStreamProvider = StreamProvider.autoDispose<List<ScanResult>>((
  ref,
) {
  return ref.watch(bluetoothRepositoryProvider).scanForBeacons();
});
