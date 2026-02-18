import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/bingo_hall_model.dart';
import '../../../home/repositories/hall_repository.dart';

class LoyaltySettingsScreen extends ConsumerStatefulWidget {
  final String hallId;
  final BingoHallModel hall;

  const LoyaltySettingsScreen({super.key, required this.hallId, required this.hall});

  @override
  ConsumerState<LoyaltySettingsScreen> createState() => _LoyaltySettingsScreenState();
}

class _LoyaltySettingsScreenState extends ConsumerState<LoyaltySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _symbolController;
  late TextEditingController _colorController;
  late TextEditingController _checkInBonusController;
  late TextEditingController _timeDropAmountController;
  late TextEditingController _timeDropIntervalController;
  late TextEditingController _capController;
  late TextEditingController _birthdayBonusController;

  bool _isCapEnabled = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final settings = widget.hall.loyaltySettings;

    _nameController = TextEditingController(text: settings.currencyName);
    _symbolController = TextEditingController(text: settings.currencySymbol);
    _colorController = TextEditingController(text: settings.primaryColor);
    _checkInBonusController = TextEditingController(text: settings.checkInBonus.toString());
    _timeDropAmountController = TextEditingController(text: settings.timeDropAmount.toString());
    _timeDropIntervalController = TextEditingController(text: settings.timeDropInterval.toString());
    _birthdayBonusController = TextEditingController(text: settings.birthdayBonus.toString());
    
    _isCapEnabled = settings.dailyEarningCap != null;
    _capController = TextEditingController(text: settings.dailyEarningCap?.toString() ?? "100");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _colorController.dispose();
    _checkInBonusController.dispose();
    _timeDropAmountController.dispose();
    _timeDropIntervalController.dispose();
    _capController.dispose();
    _birthdayBonusController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedSettings = LoyaltySettings(
        currencyName: _nameController.text.trim(),
        currencySymbol: _symbolController.text.trim().toUpperCase(),
        primaryColor: _colorController.text.trim(),
        checkInBonus: int.parse(_checkInBonusController.text.trim()),
        timeDropAmount: int.parse(_timeDropAmountController.text.trim()),
        timeDropInterval: int.parse(_timeDropIntervalController.text.trim()),
        birthdayBonus: int.parse(_birthdayBonusController.text.trim()),
        dailyEarningCap: _isCapEnabled ? int.parse(_capController.text.trim()) : null,
      );

      final updatedHall = widget.hall.copyWith(loyaltySettings: updatedSettings);
      
      await ref.read(hallRepositoryProvider).updateHall(updatedHall);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings updated successfully!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text("Loyalty Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("Save", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader("Branding"),
            _buildTextField(
              controller: _nameController,
              label: "Currency Name",
              hint: "e.g., Points, Stars, Coins",
              desc: "What do call your loyalty points?",
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _symbolController,
                    label: "Symbol",
                    hint: "PTS",
                    desc: "Short abbreviation (3-4 chars).",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _colorController,
                    label: "Primary Color (Hex)",
                    hint: "FFD700",
                    prefix: "#",
                    desc: "Theme color for your points.",
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader("Earning Rules"),
            
            _buildNumberField(
              controller: _checkInBonusController,
              label: "Check-in Bonus",
              suffix: "pts",
              desc: "Points awarded instantly when a user checks in.",
            ),

             _buildNumberField(
              controller: _timeDropAmountController,
              label: "Time-Drop Amount",
              suffix: "pts",
              desc: "Points awarded passively for staying at the hall.",
            ),
             _buildNumberField(
              controller: _timeDropIntervalController,
              label: "Time-Drop Interval",
              suffix: "mins",
              desc: "How often passively earned points are dropped.",
            ),

            const SizedBox(height: 16),
            _buildSectionHeader("Limits & Bonuses"),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.amber,
              title: const Text("Daily Earning Cap", style: TextStyle(color: Colors.white)),
              subtitle: const Text("Limit the total points a user can earn per day.", style: TextStyle(color: Colors.white54, fontSize: 12)),
              value: _isCapEnabled,
              onChanged: (val) => setState(() => _isCapEnabled = val),
            ),
            
            if (_isCapEnabled)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 16),
                child: _buildNumberField(
                  controller: _capController,
                  label: "Max Points per Day",
                  suffix: "pts",
                  desc: "Maximum total points from all sources.",
                ),
              ),

             _buildNumberField(
              controller: _birthdayBonusController,
              label: "Birthday Bonus",
              suffix: "pts",
              desc: "Points awarded on the user's birthday.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? desc,
    String? prefix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixText: prefix,
              prefixStyle: const TextStyle(color: Colors.white70),
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (val) => val == null || val.isEmpty ? "Required" : null,
          ),
          if (desc != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              suffixText: suffix,
              suffixStyle: const TextStyle(color: Colors.amber),
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return "Required";
              if (int.tryParse(val) == null) return "Must be a number";
              if (int.parse(val) < 0) return "Cannot be negative";
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
