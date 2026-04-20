import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/notification_service.dart';
import '../../../core/widgets/glass_container.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class CreateVenueScreen extends ConsumerStatefulWidget {
  const CreateVenueScreen({super.key});

  @override
  ConsumerState<CreateVenueScreen> createState() => _CreateVenueScreenState();
}

class _CreateVenueScreenState extends ConsumerState<CreateVenueScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  String _venueType = 'Venue';
  final List<String> _venueTypes = [
    'Venue',
    'Bar / Club',
    'Restaurant',
    'Event Center',
    'Charity Organization',
    'Other'
  ];

  File? _logoImage;
  bool _isSubmitting = false;

  Future<void> _pickLogo() async {
    final storage = ref.read(storageServiceProvider);
    final file = await storage.pickImage();
    if (file != null) {
      setState(() => _logoImage = File(file.path));
    }
  }

  Future<List<Map<String, dynamic>>> _getSuggestions(String query) async {
    if (query.isEmpty) return [];
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null) return [];

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&components=country:us');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions.map((p) => {
            'description': p['description'],
            'place_id': p['place_id']
          }).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<void> _onSuggestionSelected(Map<String, dynamic> suggestion) async {
    _addressController.text = suggestion['description'];

    final placeId = suggestion['place_id'];
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null || placeId == null) return;

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&fields=address_components');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final components = data['result']['address_components'] as List;
          String city = '';
          String state = '';

          for (var c in components) {
            final types = c['types'] as List;
            if (types.contains('locality')) {
              city = c['long_name'];
            } else if (types.contains('administrative_area_level_1')) {
              state = c['short_name'];
            }
          }

          if (city.isNotEmpty) setState(() => _cityController.text = city);
          if (state.isNotEmpty) setState(() => _stateController.text = state);
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _submitOnboarding(UserModel user) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      // Generate Sandbox UUID smoothly
      final newVenueRef = FirebaseFirestore.instance.collection('venues').doc();
      final newVenueId = newVenueRef.id;

      // Elevate Legacy User Role
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'pendingVenueClaimId': newVenueId,
      });

      // Upload Logo if provided natively
      String? logoUrl;
      if (_logoImage != null) {
         logoUrl = await ref.read(storageServiceProvider).uploadVenueClaimImage(_logoImage!, user.uid);
      }

      // Geocode the submitted location!
      double lat = 0.0;
      double lng = 0.0;
      try {
        final queryStr = "${_addressController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()}";
        List<Location> locations = await locationFromAddress(queryStr);
        if (locations.isNotEmpty) {
          lat = locations.first.latitude;
          lng = locations.first.longitude;
        }
      } catch (e) {
        debugPrint("Sandbox Geocoding Error: $e");
      }
      
      final geoPoint = GeoFirePoint(GeoPoint(lat, lng));

      // 1. Provision Sandbox Venue (Invisible to Public)
      await newVenueRef.set({
        'id': newVenueId,
        'name': _nameController.text.trim(),
        'street': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'latitude': lat,
        'longitude': lng,
        'geo': geoPoint.data,
        'geoHash': geoPoint.geohash,
        'operatingHours': {},
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': false, // Crucial Sandbox isolation
        'beaconUuid': 'PENDING_CONFIG',
        'logoUrl': logoUrl,
        'venueType': _venueType.toLowerCase(),
      });

      // 2. Map Sandbox Team Credentials (Unlocks CMS natively)
      await FirebaseFirestore.instance.collection('venues').doc(newVenueId).collection('team').doc(user.uid).set({
        'uid': user.uid,
        'firstName': user.firstName ?? '',
        'lastName': user.lastName ?? '',
        'username': user.username,
        'photoUrl': user.photoUrl,
        'venueId': newVenueId,
        'venueName': _nameController.text.trim(),
        'assignedRole': 'owner',
        'addedAt': FieldValue.serverTimestamp(),
        'addedByUid': user.uid,
        'claimStatus': 'pending', 
      });

      // 3. Submit Official Queue Record targeting the Sandbox Model
      await FirebaseFirestore.instance.collection('venue_claims').add({
        'userId': user.uid,
        'emailProvided': _emailController.text.trim(),
        'requestedVenueId': newVenueId,
        'venueName': _nameController.text.trim(),
        'venueAddress': _addressController.text.trim(),
        'venueCity': _cityController.text.trim(),
        'venueState': _stateController.text.trim(),
        'venueWebsite': _websiteController.text.trim(),
        'venueType': _venueType,
        'logoUrl': logoUrl,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // Dispatch 'Application Received' Alert locally!
      await ref.read(notificationServiceProvider).sendNotification(
        userId: user.uid,
        title: 'Sandbox Provisioned 🚀',
        body: 'Your business Sandbox for ${_nameController.text.trim()} is built! Tap Workspaces to edit safely inside while we review your claim.',
        type: 'system',
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text("Profile Set Up! 🎉", style: TextStyle(color: Colors.white)),
            content: const Text(
              "Your venue profile has been set up successfully and is currently under review by our team! It will remain hidden from the public until approved, but you can head over to your Settings page right now to start customizing your page, adding staff, and getting everything ready for launch!",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("Return to Dashboard", style: TextStyle(color: Colors.amber)),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final user = userAsync.value;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text("Business Onboarding"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Let's get your venue on the map 📍",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  "We need some basic operational information to verify and map your unlisted venue securely.",
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 32),

                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Upload Logo
                      GestureDetector(
                        onTap: _pickLogo,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                            image: _logoImage != null
                                ? DecorationImage(image: FileImage(_logoImage!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: _logoImage == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, color: Colors.amber, size: 30),
                                    SizedBox(height: 8),
                                    Text("Logo", style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Business Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _venueType,
                        dropdownColor: Colors.grey[900],
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Business Type",
                          labelStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                        ),
                        onChanged: (val) {
                          if (val != null) setState(() => _venueType = val);
                        },
                        items: _venueTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Venue Name
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Business Name",
                          labelStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                        ),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Street Address (Predictive Autocomplete)
                      TypeAheadField<Map<String, dynamic>>(
                        controller: _addressController,
                        builder: (context, controller, focusNode) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "Street Address",
                              labelStyle: TextStyle(color: Colors.white54),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                              hintText: "Start typing...",
                              hintStyle: TextStyle(color: Colors.white38),
                            ),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          );
                        },
                        suggestionsCallback: _getSuggestions,
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            tileColor: const Color(0xFF252525),
                            leading: const Icon(Icons.location_on, color: Colors.amber),
                            title: Text(
                              suggestion['description'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                        onSelected: _onSuggestionSelected,
                        emptyBuilder: (context) => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("No locations found", style: TextStyle(color: Colors.white54)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // City & State
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _cityController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "City",
                                labelStyle: TextStyle(color: Colors.white54),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                              ),
                              validator: (v) => v!.isEmpty ? "Required" : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _stateController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "State",
                                labelStyle: TextStyle(color: Colors.white54),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                              ),
                              validator: (v) => v!.isEmpty ? "Required" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Official Email
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Official Domain Email",
                          labelStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                        ),
                        validator: (v) => v!.isEmpty || !v.contains('@') ? "Valid Business Email is Required" : null,
                      ),
                      const SizedBox(height: 16),

                      // Website (Optional)
                      TextFormField(
                        controller: _websiteController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Website URL (Optional)",
                          labelStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting ? null : () => _submitOnboarding(user),
                    child: _isSubmitting 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Text("Submit Registration", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
