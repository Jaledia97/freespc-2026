import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/display_settings_repository.dart';

class DisplaySettingsScreen extends ConsumerWidget {
  const DisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFormat = ref.watch(timeFormatProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Display Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Setting
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Appearance", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Choose your preferred theme.", style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 16),
                
                Consumer(
                  builder: (context, ref, _) {
                    final themeMode = ref.watch(themeModeProvider);
                    return DropdownButtonFormField<AppThemeMode>(
                      initialValue: themeMode,
                      dropdownColor: const Color(0xFF2C2C2C),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.black26, 
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: AppThemeMode.system,
                          child: Text("Auto (System Default)", style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: AppThemeMode.light,
                          child: Text("Light Mode", style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: AppThemeMode.dark,
                          child: Text("Dark Mode", style: TextStyle(color: Colors.white)),
                        ),
                      ], 
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(themeModeProvider.notifier).setMode(val);
                        }
                      }
                    );
                  }
                ),
              ],
            ),
          ),

          // Time Format Setting
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Time Format", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Select your preferred clock format.", style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<TimeFormat>(
                  initialValue: timeFormat,
                  dropdownColor: const Color(0xFF2C2C2C),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.black26, 
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: TimeFormat.h12,
                      child: Text("12-Hour (1:00 PM)", style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: TimeFormat.h24,
                      child: Text("24-Hour (13:00)", style: TextStyle(color: Colors.white)),
                    ),
                  ], 
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(timeFormatProvider.notifier).setFormat(val);
                    }
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
