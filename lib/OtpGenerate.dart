import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uber_application/Route.dart';
import 'package:uber_application/StartScreen.dart';
import 'dart:math';

class VerifyOtp extends StatefulWidget {
  final String boardingLocation;
  final String destinationLocation;

  const VerifyOtp({
    Key? key,
    required this.boardingLocation,
    required this.destinationLocation,
  }) : super(key: key);

  @override
  _VerifyOtpState createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  MapController? _mapController;
  bool _isLoading = true;
  late String otp;

  String generateOTP() {
    final random = Random();
    final otp = 100000 + random.nextInt(900000);
    return otp.toString().padLeft(6, '0');
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController(
      initPosition: GeoPoint(latitude: 37.7749, longitude: -122.4194),
    );
    otp = generateOTP();
    _setMarkers();
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
          north: max(boardingGeoPoint.latitude, destinationGeoPoint.latitude) + 0.01,
          south: min(boardingGeoPoint.latitude, destinationGeoPoint.latitude) - 0.01,
          east: max(boardingGeoPoint.longitude, destinationGeoPoint.longitude) + 0.01,
          west: min(boardingGeoPoint.longitude, destinationGeoPoint.longitude) - 0.01,
        );

        await _mapController?.zoomToBoundingBox(bounds, paddinInPixel: 64);

        await _mapController?.drawRoad(
          boardingGeoPoint,
          destinationGeoPoint,
          roadOption: RoadOption(
            roadColor: Colors.blue,
            roadWidth: 10,
            zoomInto: true,
          ),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        _showError('Unable to find coordinates for the locations provided.');
      }
    } catch (e) {
      _showError('Error setting up the map: ${e.toString()}');
    }
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
      MaterialPageRoute(builder: (context) => const StartScreen()),
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
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your OTP',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      otp,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoutePage(
                                boardingLocation: widget.boardingLocation,
                                destinationLocation: widget.destinationLocation,
                                otp: otp,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
