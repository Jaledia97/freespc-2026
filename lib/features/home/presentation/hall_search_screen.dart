import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math' as math;
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
  List<BingoHallModel> _allFetchedHalls = []; // All halls from repository
  List<BingoHallModel> _currentHalls = []; // Visible filtered halls
  Set<Marker> _markers = {};
  // Removed _circles as per user request
  
  // Viewport State
  LatLngBounds? _currentBounds;
  bool _isProgrammaticMove = false; // Prevent feedback loops

  // Default bounds
  LatLng _currentCenter = const LatLng(39.8283, -98.5795); 
  double _currentRadius = 10.0;

  @override
  void initState() {
    super.initState();
    _setupStream();
    _initializeLocation();
  }

  void _setupStream() {
    _hallsStream = _searchSubject
        .debounceTime(const Duration(milliseconds: 100))
        .switchMap((criteria) {
          return ref.read(hallRepositoryProvider).getHallsInRadius(
            latitude: criteria.center.latitude,
            longitude: criteria.center.longitude,
            radiusInMiles: criteria.radius,
          );
        });
        
    // Listen to update local state
    _hallsStream.listen((halls) {
        if (mounted) {
          setState(() {
            _allFetchedHalls = halls;
            _filterVisibleHalls(); // Filter immediately upon new data
          });
        }
    });

    _searchSubject.add(SearchCriteria(_currentCenter, _currentRadius));
  }
  
  void _filterVisibleHalls() {
    List<BingoHallModel> filtered;
    
    if (_currentBounds == null) {
      // Fallback if bounds aren't ready (e.g. initial load before map idle)
      filtered = _allFetchedHalls;
    } else {
      filtered = _allFetchedHalls.where((hall) {
        return _contains(_currentBounds!, LatLng(hall.latitude, hall.longitude));
      }).toList();
    }
    
    setState(() {
      _currentHalls = filtered;
      _markers = filtered.map((hall) {
        return Marker(
          markerId: MarkerId(hall.id),
          position: LatLng(hall.latitude, hall.longitude),
          infoWindow: InfoWindow(title: hall.name, snippet: hall.city),
          onTap: () => _panelController.open(),
        );
      }).toSet();
    });
  }
  
  bool _contains(LatLngBounds bounds, LatLng point) {
    return point.latitude >= bounds.southwest.latitude &&
           point.latitude <= bounds.northeast.latitude &&
           point.longitude >= bounds.southwest.longitude &&
           point.longitude <= bounds.northeast.longitude;
  }

  Future<void> _initializeLocation() async {
    final userPosition = ref.read(userLocationStreamProvider).valueOrNull;
    if (userPosition != null) {
      _updateCenter(LatLng(userPosition.latitude, userPosition.longitude));
    }
  }

  void _updateCenter(LatLng newCenter) {
    setState(() => _currentCenter = newCenter);
    _searchSubject.add(SearchCriteria(newCenter, _currentRadius));
  }
  
  void _animateTo(LatLng dest, double radius) {
    setState(() {
      _currentCenter = dest;
      _currentRadius = radius;
      _isProgrammaticMove = true;
    });
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(dest, _getZoomLevel(radius))
    ).then((_) => Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isProgrammaticMove = false);
    }));

    _searchSubject.add(SearchCriteria(dest, radius));
  }
  
  // Helper: Zoom -> Radius (Approximate)
  // Zoom 10 ~= 25mi radius visible vertically
  // Zoom 11 ~= 12mi
  // Formula: Radius = 40000 / (2^zoom) * adjustment? 
  // Simplified Log Model:  Radius = 2^(15.5 - zoom)
  // Zoom 12 -> 2^(3.5) = 11.3mi
  // Zoom 10 -> 2^(5.5) = 45mi
  double _getRadiusFromZoom(double zoom) {
    return math.pow(2, 15.5 - zoom).toDouble().clamp(1.0, 100.0);
  }

  // Helper: Radius -> Zoom
  // Zoom = 15.5 - log2(radius)
  double _getZoomLevel(double radius) {
    if (radius <= 0) return 16;
    return (15.5 - (math.log(radius) / math.log(2))).clamp(0.0, 20.0);
  }

  Future<void> _onSearchSubmitted(String query) async {
    if (query.isEmpty) return;
    
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        _animateTo(LatLng(loc.latitude, loc.longitude), _currentRadius);
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
        _animateTo(LatLng(pos.latitude, pos.longitude), 10.0);
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
              minMaxZoomPreference: const MinMaxZoomPreference(8.5, null),
              initialCameraPosition: CameraPosition(target: _currentCenter, zoom: _getZoomLevel(_currentRadius)),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onCameraMove: (position) {
                 if (!_isProgrammaticMove) {
                   // User is pinching/panning manually
                   final newRadius = _getRadiusFromZoom(position.zoom);
                   setState(() {
                     _currentCenter = position.target;
                     _currentRadius = newRadius;
                   });
                   // Push debounced search
                   _searchSubject.add(SearchCriteria(position.target, newRadius));
                 }
              },
              onCameraIdle: () async {
                 // Update bounds and filter list
                 if (_mapController != null) {
                   final bounds = await _mapController!.getVisibleRegion();
                   setState(() {
                     _currentBounds = bounds;
                   });
                   _filterVisibleHalls();
                 }
              },
              markers: _markers,
              // circles: _circles, // Removed
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
                                // Programmatic update from slider
                                _animateTo(_currentCenter, val);
                              },
                              onChangeEnd: (val) {
                                // Refresh bounds filtering if needed? 
                                // Stream update handles it.
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
                          image: hall.logoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(hall.logoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: NetworkImage("https://loremflickr.com/200/200/bingo"), // Placeholder
                                  fit: BoxFit.cover,
                                ),
                        ),
                        child: hall.logoUrl == null 
                            ? const Icon(Icons.store, color: Colors.amber)
                            : null,
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
