import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'FindCustomer.dart';

class DriverProfile extends StatefulWidget {
  const DriverProfile({super.key});

  @override
  _DriverProfileState createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  String currentAddress = "Fetching your location..."; // Placeholder for current address
  final TextEditingController destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          currentAddress = "Location services are disabled.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          setState(() {
            currentAddress = "Location permission denied.";
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await _getAddressFromLatLng(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        currentAddress = "Error fetching location: $e";
      });
    }
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    final String osrmUrl = "http://router.project-osrm.org/reverse?lat=$latitude&lon=$longitude";
    print("Request URL: $osrmUrl");

    try {
      final response = await http.get(Uri.parse(osrmUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['display_name'] != null) {
          setState(() {
            currentAddress = data['display_name'] ?? "Address not found";
          });
        } else {
          setState(() {
            currentAddress = "Address not found in response.";
          });
        }
      } else {
        setState(() {
          currentAddress = "Failed to fetch address. Status code: ${response.statusCode}, Body: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        currentAddress = "Error fetching address: $e";
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    String driverFirstName = "Pratik";
    String driverLastName = "Nikat";
    String driverEmail = "pratiknikat07@gmail.com";
    String driverPhone = "9856-4764-7583-3478";
    String carName = "swift-vdi";
    String carNumber = "MH 42 AD 2856";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UBER',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16.0),
              const Text(
                "WELCOME BACK",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                  'lib/assets/profile_pic.png',
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                "Profile details",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          driverFirstName,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          driverLastName,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Card(
                child: ListTile(
                  leading: Icon(Icons.email, color: Colors.black),
                  title: Text(driverEmail),
                ),
              ),
              const SizedBox(height: 8.0),
              Card(
                child: ListTile(
                  leading: Icon(Icons.phone, color: Colors.black),
                  title: Text(driverPhone),
                ),
              ),
              const SizedBox(height: 8.0),
              Card(
                child: ListTile(
                  leading: Icon(Icons.location_on, color: Colors.black),
                  title: Text(currentAddress),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                "Car details",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          carName,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          carNumber,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FindCustomer(
                        isRequestActive: true,
                        destinationLocation: destinationController.text,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text("ACTIVE"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
