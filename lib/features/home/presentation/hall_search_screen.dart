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
          onTap: () => _onHallSelected(hall),
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
    
    // Clean query
    String effectiveQuery = query.trim();
    
    // Heuristic: If 5 digits, assumes US Zip Code
    final isZip = RegExp(r'^\d{5}$').hasMatch(effectiveQuery);
    if (isZip) {
      effectiveQuery = "$effectiveQuery, United States";
    }

    try {
      List<Location> locations = await locationFromAddress(effectiveQuery);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        _animateTo(LatLng(loc.latitude, loc.longitude), _currentRadius);
      } else {
        // Retry without suffix if it was zip? Or just show error.
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location not found")));
      }
    } catch (e) {
      print("Geocoding Error for '$effectiveQuery': $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error finding location. Try adding State/Country.")));
    }
  }

  BingoHallModel? _selectedHall; // Null = List View, Value = Detail View

  void _onHallSelected(BingoHallModel hall) {
    setState(() => _selectedHall = hall);
    // Center map on hall with slightly higher zoom + offset for panel
    // Offset logic: Center is usually obscured by panel. Shift slightly North?
    // For MVP, just center without offset.
    _animateTo(LatLng(hall.latitude, hall.longitude), 5.0); // 5 mile radius view
    _panelController.open();
  }

  void _onBackFromDetail() {
    setState(() => _selectedHall = null);
    _panelController.animatePanelToPosition(0.0); // Collapse to min height
    // Optionally zoom out slightly?
    _animateTo(_currentCenter, 10.0); 
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userLocationStreamProvider, (prev, next) {
      if (next.value != null && prev?.value == null) {
        final pos = next.value!;
        _animateTo(LatLng(pos.latitude, pos.longitude), 10.0);
      }
    });

    return PopScope(
      canPop: _selectedHall == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackFromDetail();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false, // Prevent panel jump on keyboard
        body: SlidingUpPanel(
          controller: _panelController,
          minHeight: 120,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          color: const Color(0xFF1A1A1A),
          panel: _selectedHall == null ? _buildListView() : _buildDetailView(),
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
                     // User is pinching/panning manually (only update if no hall selected to avoid jumping)
                     if (_selectedHall == null) {
                       final newRadius = _getRadiusFromZoom(position.zoom);
                       setState(() {
                         _currentCenter = position.target;
                         _currentRadius = newRadius;
                       });
                       // Push debounced search
                       _searchSubject.add(SearchCriteria(position.target, newRadius));
                     }
                   }
                },
                onCameraIdle: () async {
                   // Update bounds and filter list only if no hall selected (keep pins stable in detail view)
                   if (_mapController != null && _selectedHall == null) {
                     final bounds = await _mapController!.getVisibleRegion();
                     setState(() {
                       _currentBounds = bounds;
                     });
                     _filterVisibleHalls();
                   }
                },
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                style: _darkMapStyle,
              ),
          
              // Top Overlay (Search + Radius) - Hide when detail view active? Or keep?
              // User said "scrollable panel should pop halfway up... underneath it should JUST show that hall's next 5 events"
              // implies complete focus. Let's hide search bar when detail is open to clean UI.
              if (_selectedHall == null)
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
              
              // Back Button Overlay (When Detail Open)
              if (_selectedHall != null)
                Positioned(
                  top: 50,
                  left: 16,
                  child: GestureDetector(
                    onTap: _onBackFromDetail,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanelHandle() {
     return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPanelHandle(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                      onTap: () => _onHallSelected(hall),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDetailView() {
    final hall = _selectedHall!;
    
    // Fetch specials for this specific hall
    final specialsAsync = ref.watch(hallSpecialsProvider(hall.id));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPanelHandle(),
        
        // Hall Header Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70, 
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[800],
                  image: hall.logoUrl != null 
                    ? DecorationImage(image: NetworkImage(hall.logoUrl!), fit: BoxFit.cover)
                    : null,
                ),
                child: hall.logoUrl == null ? const Icon(Icons.store, size: 30, color: Colors.white54) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hall.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${hall.street}, ${hall.city}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(hall.phone ?? "No Phone Listed", style: const TextStyle(color: Colors.blueAccent, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Action Buttons Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
             children: [
               Expanded(
                 child: ElevatedButton.icon(
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                   icon: const Icon(Icons.info),
                   label: const Text("View Profile"),
                   onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HallProfileScreen(hall: hall))),
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: OutlinedButton.icon(
                   style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), foregroundColor: Colors.white),
                   icon: const Icon(Icons.directions),
                   label: const Text("Navigate"),
                   onPressed: () {}, // Implement launchUrl
                 ),
               ),
             ],
          ),
        ),

        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("Next 5 Games", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: specialsAsync.when(
            data: (specials) {
              final next5 = specials.take(5).toList();
              if (next5.isEmpty) {
                 return const Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.calendar_today, color: Colors.white24, size: 40),
                       SizedBox(height: 8),
                       Text("No upcoming events scheduled.", style: TextStyle(color: Colors.white54)),
                     ],
                   ),
                 );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: next5.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                   final s = next5[i];
                   return Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                     child: Row(
                       children: [
                         Column(
                           children: [
                             Text(_month(s.startTime), style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                             Text("${s.startTime?.day}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                           ],
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(s.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                               Text(_time(s.startTime), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                             ],
                           ),
                         ),
                       ],
                     ),
                   );
                },
              );
            },
            error: (e, _) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }

  String _month(DateTime? d) {
    if (d == null) return "JAN";
    const m = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    return m[d.month - 1];
  }

  String _time(DateTime? d) {
    if (d == null) return "TBA";
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
    return "$h:$min $ampm";
  }

  // Placeholder for old _buildPanel
  Widget _buildPanel() {
     // This method signature is required by the SlidingUpPanel's panel property in the original code,
     // but we are dynamically switching contents inside body parameter of Scaffold above (wait, no).
     // The SlidingUpPanel 'panel' param takes a Widget. Detailed logic moved to _buildDetailView/_buildListView.
     // This is just a redirector now, or we can inline the ternary in the build method.
     // Oh, I updated the build method to use ternary directly. Implementation is inside class.
     return const SizedBox(); 
     // Use the methods defined above.
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
