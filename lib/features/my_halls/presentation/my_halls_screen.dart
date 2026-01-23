import 'package:flutter/material.dart';

class MyHallsScreen extends StatelessWidget {
  const MyHallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Subscribed Halls')),
      body: const Center(
        child: Text('My Subscribed Halls'),
      ),
    );
  }
}
