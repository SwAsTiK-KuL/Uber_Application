import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserNavigation extends StatefulWidget {
  @override
  _UserNavigation createState() => _UserNavigation();
}

class _UserNavigation extends State<UserNavigation> {
  String currentAddress = "Unknown Address";

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
    final String osrmUrl = "http://router.project-osrm.org/reverse?latitude=$latitude&longitude=$longitude&format=json";

    try {
      final response = await http.get(Uri.parse(osrmUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('OSRM Response: $data');

        if (data['features'] != null && data['features'].isNotEmpty) {
          setState(() {
            currentAddress = data['features'][0]['properties']['address'] ?? "Address not found";
          });
        } else {
          setState(() {
            currentAddress = "Address not found in response.";
          });
        }
      } else {
        setState(() {
          currentAddress = "Failed to fetch address. Status code: ${response.statusCode}";
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Navigation"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Current Address:",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              currentAddress,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text("Get Current Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
