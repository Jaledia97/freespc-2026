import 'package:flutter/material.dart';

class BusinessAlertsScreen extends StatelessWidget {
  const BusinessAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Business Alerts")),
      body: const Center(
        child: Text("No new alerts for your venue.", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
