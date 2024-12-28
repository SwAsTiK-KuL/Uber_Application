import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class UberTheme {
  static const Color primary = Color(0xFF000000);
  static const Color secondary = Color(0xFF276EF1);
  static const Color background = Colors.white;
  static const Color grey = Color(0xFFF6F6F6);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF545454);
}

class DriversDirection extends StatefulWidget {
  final String boardingLocation;

  const DriversDirection({Key? key, required this.boardingLocation}) : super(key: key);

  @override
  _DriversDirectionState createState() => _DriversDirectionState();
}

class _DriversDirectionState extends State<DriversDirection> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  LatLng? _currentLocation;
  LatLng? _boardingLocationCoordinates;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupLocationAndMap();
  }

  Future<void> _setupLocationAndMap() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled');
        }
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          throw Exception('Location permission denied');
        }
      }

      LocationData locationData = await _location.getLocation();
      List<String> coordinates = widget.boardingLocation.split(',');

      if (coordinates.length != 2) {
        throw Exception('Invalid boarding location format');
      }

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
          _boardingLocationCoordinates = LatLng(
            double.parse(coordinates[0].trim()),
            double.parse(coordinates[1].trim()),
          );
          _isLoading = false;
        });

        _location.onLocationChanged.listen((LocationData currentLocation) {
          if (mounted) {
            setState(() {
              _currentLocation = LatLng(
                currentLocation.latitude!,
                currentLocation.longitude!,
              );
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
      debugPrint('Error setting up map: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UberTheme.background,
      appBar: AppBar(
        backgroundColor: UberTheme.background,
        elevation: 0,
        title: Text(
          "Driver's Direction",
          style: TextStyle(
            color: UberTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: UberTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(
                Icons.my_location,
                color: UberTheme.secondary,
              ),
              onPressed: () {
                if (_currentLocation != null) {
                  _mapController.move(_currentLocation!, 15.0);
                }
              },
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Container(
        color: UberTheme.background,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(UberTheme.secondary),
              ),
              SizedBox(height: 16),
              Text(
                'Loading map and location...',
                style: TextStyle(
                  color: UberTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        color: UberTheme.background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: UberTheme.secondary),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: UberTheme.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UberTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _setupLocationAndMap();
                  },
                  child: const Text(
                    'Retry',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_currentLocation == null || _boardingLocationCoordinates == null) {
      return const Center(
        child: Text(
          'Unable to load location data',
          style: TextStyle(
            color: UberTheme.textPrimary,
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation!,
              initialZoom: 15.0,
              onMapReady: () {
                if (_currentLocation != null && _boardingLocationCoordinates != null) {
                  final centerLat = (_currentLocation!.latitude + _boardingLocationCoordinates!.latitude) / 2;
                  final centerLng = (_currentLocation!.longitude + _boardingLocationCoordinates!.longitude) / 2;
                  final center = LatLng(centerLat, centerLng);

                  final distance = const Distance().distance(
                      _currentLocation!,
                      _boardingLocationCoordinates!
                  );
                  final zoom = _calculateZoomLevel(distance);

                  _mapController.move(center, zoom);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: UberTheme.secondary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.circle,
                          color: UberTheme.secondary,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                  Marker(
                    point: _boardingLocationCoordinates!,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.location_on,
                      color: UberTheme.primary,
                      size: 40,
                    ),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_currentLocation!, _boardingLocationCoordinates!],
                    strokeWidth: 3.0,
                    color: UberTheme.secondary,
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: UberTheme.background,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Distance to pickup',
                    style: TextStyle(
                      color: UberTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${_calculateDistance().toStringAsFixed(2)} km',
                    style: TextStyle(
                      color: UberTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UberTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _setupLocationAndMap,
                  child: const Text(
                    'Update Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateDistance() {
    if (_currentLocation != null && _boardingLocationCoordinates != null) {
      final Distance distance = const Distance();
      return distance.as(
        LengthUnit.Kilometer,
        _currentLocation!,
        _boardingLocationCoordinates!,
      );
    }
    return 0.0;
  }

  double _calculateZoomLevel(double distance) {
    if (distance <= 100) {
      return 15.0;
    } else if (distance <= 500) {
      return 13.0;
    } else if (distance <= 2000) {
      return 11.0;
    } else if (distance <= 5000) {
      return 9.0;
    } else {
      return 7.0;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}