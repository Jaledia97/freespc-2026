import 'package:flutter/material.dart';

class VenueLedgerScreen extends StatelessWidget {
  const VenueLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Center(
        child: Text(
          "Venue Ledger & Analytics",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
