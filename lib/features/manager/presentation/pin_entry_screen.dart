import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'manager_dashboard_screen.dart';

import 'package:local_auth/local_auth.dart' as local_auth;

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  String _pin = "";
  final String _correctPin = "4836"; // Hardcoded Dev PIN
  
  final local_auth.LocalAuthentication auth = local_auth.LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      setState(() {
        _canCheckBiometrics = canCheck && isSupported;
      });
      
      if (_canCheckBiometrics) {
        _authenticate();
      }
    } catch (e) {
      // Ignore error for now, as this is just an initial check
    }
  }

  Future<void> _authenticate() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Scan to verify Admin Access',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (authenticated && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ManagerDashboardScreen()),
        );
      }
    } catch (e) {
      // Ignore error, fallback to PIN
    }
  }

  void _onDigitPress(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
      });
      if (_pin.length == 4) {
        _validatePin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _validatePin() {
    if (_pin == _correctPin) {
      // Success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ManagerDashboardScreen()),
      );
    } else {
      // Failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect PIN"), 
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 1000),
        ),
      );
      setState(() {
        _pin = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, size: 64, color: Colors.blueAccent),
            const SizedBox(height: 24),
            const Text(
              "Manager Access",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter your 4-digit PIN",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            if (_canCheckBiometrics)
               Padding(
                 padding: const EdgeInsets.only(top: 8),
                 child: TextButton.icon(
                   onPressed: _authenticate, 
                   icon: const Icon(Icons.fingerprint, color: Colors.blueAccent), 
                   label: const Text("Use Biometrics", style: TextStyle(color: Colors.blueAccent)),
                 ),
               ),

            const SizedBox(height: 48),

            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length ? Colors.blueAccent : Colors.white12,
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),

            // Numpad
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  children: [
                    for (var i = 1; i <= 9; i++) _buildDigitBtn(i.toString()),
                    // Biometric Button (Bottom Left)
                    if (_canCheckBiometrics)
                      IconButton(
                        onPressed: _authenticate,
                        icon: const Icon(Icons.fingerprint, color: Colors.blueAccent, size: 32),
                      )
                    else 
                      const SizedBox(), 

                    _buildDigitBtn("0"),
                    
                    IconButton(
                      onPressed: _onDelete,
                      icon: const Icon(Icons.backspace_outlined, color: Colors.white70, size: 28),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitBtn(String digit) {
    return InkWell(
      onTap: () => _onDigitPress(digit),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white12),
          shape: BoxShape.circle,
        ),
        child: Text(
          digit,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
