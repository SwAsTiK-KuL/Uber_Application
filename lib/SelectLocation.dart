import 'package:flutter/material.dart';
import 'ConfirmPickUp.dart';

class SelectLocation extends StatefulWidget {
  const SelectLocation({super.key});

  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  final TextEditingController boardingController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final String customerName = "John Doe";

  @override
  void dispose() {
    boardingController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Uber',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
              color: Colors.white,
            ),
            onPressed: () {
              print('Home icon pressed');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: boardingController,
              decoration: InputDecoration(
                labelText: 'Boarding Location',
                border: const OutlineInputBorder(),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.asset(
                    'assets/pin.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.location_on, size: 20);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                labelText: 'Destination Location',
                border: const OutlineInputBorder(),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.asset(
                    'assets/map.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.map, size: 20);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                final String boardingLocation = boardingController.text;
                final String destinationLocation = destinationController.text;

                if (boardingLocation.isEmpty || destinationLocation.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter both locations'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmPickUp(
                      boardingLocation: boardingLocation,
                      destinationLocation: destinationLocation,
                      customerName: customerName, // Pass the defined customerName here
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Text('Confirm Location'),
            ),
          ],
        ),
      ),
    );
  }
}
