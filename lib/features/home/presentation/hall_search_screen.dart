import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import '../../home/repositories/hall_repository.dart';
import '../../../services/location_service.dart';
import 'hall_profile_screen.dart';
import '../../../models/bingo_hall_model.dart';
import '../../../core/widgets/glass_container.dart';

class HallSearchScreen extends ConsumerStatefulWidget {
  const HallSearchScreen({super.key});

  @override
  ConsumerState<HallSearchScreen> createState() => _HallSearchScreenState();
}

class _HallSearchScreenState extends ConsumerState<HallSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PanelController _panelController = PanelController();
  
  GoogleMapController? _mapController;
  
  // Search State
  final _searchSubject = BehaviorSubject<SearchCriteria>();
  late Stream<List<BingoHallModel>> _hallsStream;
  List<BingoHallModel> _currentHalls = []; // Keep track for Panel/Markers
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  // Default bounds
  LatLng _currentCenter = const LatLng(39.8283, -98.5795); 
  double _currentRadius = 25.0;

  @override
  void initState() {
    super.initState();
    _setupStream();
    _initializeLocation();
  }

  void _setupStream() {
    _hallsStream = _searchSubject
        .debounceTime(const Duration(milliseconds: 100)) // Throttle slightly
        .switchMap((criteria) {
          // SwitchMap cancels the previous stream when a new one arrives!
          return ref.read(hallRepositoryProvider).getHallsInRadius(
            latitude: criteria.center.latitude,
            longitude: criteria.center.longitude,
            radiusInMiles: criteria.radius,
          );
        });
        
    // Listen to update local state (markers/panel)
    _hallsStream.listen((halls) {
        if (mounted) {
          setState(() {
            _currentHalls = halls;
            _markers = halls.map((hall) {
              return Marker(
                markerId: MarkerId(hall.id),
                position: LatLng(hall.latitude, hall.longitude),
                infoWindow: InfoWindow(title: hall.name, snippet: hall.city),
                onTap: () => _panelController.open(),
              );
            }).toSet();
          });
        }
    });

    // Initial push
    _searchSubject.add(SearchCriteria(_currentCenter, _currentRadius));
  }

  Future<void> _initializeLocation() async {
    final userPosition = ref.read(userLocationStreamProvider).valueOrNull;
    if (userPosition != null) {
      _updateCenter(LatLng(userPosition.latitude, userPosition.longitude));
    } else {
      _updateCircle();
    }
  }

  void _updateCenter(LatLng newCenter) {
    setState(() => _currentCenter = newCenter);
    // Push new criteria to stream
    _searchSubject.add(SearchCriteria(newCenter, _currentRadius));
  }
  
  void _animateTo(LatLng dest) {
    setState(() => _currentCenter = dest);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(dest, _getZoomLevel(_currentRadius)));
    _updateCircle();
    _searchSubject.add(SearchCriteria(dest, _currentRadius));
  }

  void _updateCircle() {
    setState(() {
      _circles = {
        Circle(
          circleId: const CircleId("radius_circle"),
          center: _currentCenter,
          radius: _currentRadius * 1609.34,
          fillColor: Colors.blue.withOpacity(0.15),
          strokeColor: Colors.transparent,
          strokeWidth: 0,
        ),
      };
    });
  }
  
  double _getZoomLevel(double radius) {
    double scale = radius / 500;
    return 16 - (16 * scale).clamp(0, 10).toDouble();
  }

  Future<void> _onSearchSubmitted(String query) async {
    if (query.isEmpty) return;
    
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        _animateTo(LatLng(loc.latitude, loc.longitude));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location not found")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error finding location")));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userLocationStreamProvider, (prev, next) {
      if (next.value != null && prev?.value == null) {
        final pos = next.value!;
        _animateTo(LatLng(pos.latitude, pos.longitude));
      }
    });

    return Scaffold(
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 120,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        color: const Color(0xFF1A1A1A),
        panel: _buildPanel(),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _currentCenter, zoom: 10),
              onMapCreated: (controller) {
                _mapController = controller;
                _updateCircle();
              },
              onCameraMove: (position) {
                 // Update visual circle instantly
                 setState(() {
                   _currentCenter = position.target;
                   _updateCircle();
                 });
                 // Push to stream (debounced)
                 _searchSubject.add(SearchCriteria(position.target, _currentRadius));
              },
              onCameraIdle: () {
                 // No specific action needed as stream handles it
              },
              markers: _markers,
              circles: _circles,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              style: _darkMapStyle,
            ),
        
            // Top Overlay (Search + Radius)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Bar
                    GlassContainer(
                      blur: 10,
                      opacity: 0.8,
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          icon: const Icon(Icons.search, color: Colors.amber),
                          hintText: "Search City or Zip",
                          hintStyle: const TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_forward, color: Colors.white),
                            onPressed: () => _onSearchSubmitted(_searchController.text),
                          ),
                        ),
                        onSubmitted: _onSearchSubmitted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Radius Slider
                    GlassContainer(
                      blur: 10,
                      opacity: 0.8,
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Text("Radius:", style: TextStyle(color: Colors.white70)),
                          Expanded(
                            child: Slider(
                              value: _currentRadius,
                              min: 1,
                              max: 100,
                              activeColor: Colors.amber,
                              inactiveColor: Colors.white24,
                              label: "${_currentRadius.round()} mi",
                              divisions: 99,
                              onChanged: (val) {
                                setState(() {
                                  _currentRadius = val;
                                  _updateCircle(); 
                                });
                                _searchSubject.add(SearchCriteria(_currentCenter, val));
                              },
                              onChangeEnd: (val) {
                                // No specific action needed as stream handles it
                              },
                            ),
                          ),
                          Text("${_currentRadius.round()} mi", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                        ],
                      ),
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

  Widget _buildPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "${_currentHalls.length} Halls Nearby",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        
        Expanded(
          child: _currentHalls.isEmpty 
              ? const Center(child: Text("No halls in this area", style: TextStyle(color: Colors.white54)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _currentHalls.length,
                  separatorBuilder: (c, i) => const Divider(color: Colors.white12),
                  itemBuilder: (context, index) {
                    final hall = _currentHalls[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                             image: NetworkImage("https://loremflickr.com/200/200/bingo"), // Placeholder
                             fit: BoxFit.cover,
                          ),
                        ),
                        child: const Icon(Icons.store, color: Colors.amber),
                      ),
                      title: Text(hall.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        "${hall.city}, ${hall.state}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                      onTap: () {
                         Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => HallProfileScreen(hall: hall))
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchSubject.close();
    super.dispose();
  }

  // Dark Style JSON (Simplified)
  final String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#181818"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1b1b1b"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#3c3c3c"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  }
]
''';
}

class SearchCriteria {
  final LatLng center;
  final double radius;
  SearchCriteria(this.center, this.radius);
}
