import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' as math;
import 'SelectLocation.dart';

class RoutePage extends StatefulWidget {
  final String boardingLocation;
  final String destinationLocation;
  final String otp;

  const RoutePage({
    Key? key,
    required this.boardingLocation,
    required this.destinationLocation,
    required this.otp,
  }) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  MapController? _mapController;
  bool _isLoading = true;
  String distance = "";

  @override
  void initState() {
    super.initState();
    _mapController = MapController(
      initPosition: GeoPoint(latitude: 37.7749, longitude: -122.4194), // Default position
    );
  }

  Future<void> _setMarkers() async {
    try {
      List<Location> boardingLocations = await locationFromAddress(widget.boardingLocation);
      List<Location> destinationLocations = await locationFromAddress(widget.destinationLocation);

      if (boardingLocations.isNotEmpty && destinationLocations.isNotEmpty) {
        final boardingGeoPoint = GeoPoint(
          latitude: boardingLocations.first.latitude,
          longitude: boardingLocations.first.longitude,
        );

        final destinationGeoPoint = GeoPoint(
          latitude: destinationLocations.first.latitude,
          longitude: destinationLocations.first.longitude,
        );

        double calculatedDistance = _calculateDistance(
          boardingGeoPoint.latitude,
          boardingGeoPoint.longitude,
          destinationGeoPoint.latitude,
          destinationGeoPoint.longitude,
        );

        setState(() {
          distance = calculatedDistance.toStringAsFixed(2) + " km";
        });


        await _mapController?.addMarker(
          boardingGeoPoint,
          markerIcon: MarkerIcon(
            icon: Icon(Icons.location_on, color: Colors.blue, size: 48),
          ),
        );

        await _mapController?.addMarker(
          destinationGeoPoint,
          markerIcon: MarkerIcon(
            icon: Icon(Icons.location_on, color: Colors.red, size: 48),
          ),
        );


        final bounds = BoundingBox(
          north: math.max(boardingGeoPoint.latitude, destinationGeoPoint.latitude) + 0.01,
          south: math.min(boardingGeoPoint.latitude, destinationGeoPoint.latitude) - 0.01,
          east: math.max(boardingGeoPoint.longitude, destinationGeoPoint.longitude) + 0.01,
          west: math.min(boardingGeoPoint.longitude, destinationGeoPoint.longitude) - 0.01,
        );

        await _mapController?.zoomToBoundingBox(
          bounds,
          paddinInPixel: 64,
        );


        await _mapController?.drawRoad(
          boardingGeoPoint,
          destinationGeoPoint,
          roadOption: RoadOption(
            roadColor: Colors.blue,
            roadWidth: 10,
            zoomInto: true,
          ),
        );

        setState(() {
          _isLoading = false;
        });
      } else {
        _showError('Unable to find coordinates for the locations provided.');
      }
    } catch (e) {
      _showError('Error setting up the map: ${e.toString()}');
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of the Earth in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c; // Distance in km
  }

  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleVerifyOtp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SelectLocation()),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          OSMFlutter(
            controller: _mapController!,
            onMapIsReady: (ready) {
              if (ready && mounted) {
                setState(() => _isLoading = false);
                _mapController?.enableTracking();
                _setMarkers();
              }
            },
            osmOption: OSMOption(
              userTrackingOption: UserTrackingOption(
                enableTracking: true,
                unFollowUser: false,
              ),
              zoomOption: ZoomOption(
                initZoom: 15,
                minZoomLevel: 3,
                maxZoomLevel: 19,
                stepZoom: 1.0,
              ),
              userLocationMarker: UserLocationMaker(
                personMarker: MarkerIcon(
                  icon: Icon(
                    Icons.location_history_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                directionArrowMarker: MarkerIcon(
                  icon: Icon(
                    Icons.double_arrow,
                    size: 48,
                  ),
                ),
              ),
              roadConfiguration: RoadOption(
                roadColor: Colors.yellowAccent,
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver is on the way',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pickup: ${widget.boardingLocation}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Destination: ${widget.destinationLocation}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Distance: $distance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'OTP: ${widget.otp}', // Display OTP here
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              // child: ElevatedButton(
              //   onPressed: _handleVerifyOtp,
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.blue,
              //   ),
              //   child: const Text('Verify OTP'),
              // ),
            ),
          ),
        ],
      ),
    );
  }
}
