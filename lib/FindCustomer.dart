import 'package:flutter/material.dart';
import 'DriversDirection.dart';

class FindCustomer extends StatefulWidget {
  final bool isRequestActive;
  final String destinationLocation;

  const FindCustomer({
    Key? key,
    required this.isRequestActive,
    required this.destinationLocation,
  }) : super(key: key);

  @override
  _FindCustomerState createState() => _FindCustomerState();
}

class _FindCustomerState extends State<FindCustomer> {
  late bool isRequestActive;

  @override
  void initState() {
    super.initState();
    isRequestActive = widget.isRequestActive;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Request"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: isRequestActive
              ? _buildActiveRequestUI()
              : _buildNoRequestsUI(),
        ),
      ),
    );
  }

  Widget _buildActiveRequestUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Request Received!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          widget.destinationLocation,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAcceptButton(),
            _buildRejectButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNoRequestsUI() {
    return const Text(
      "No requests at the moment",
      style: TextStyle(fontSize: 18),
      textAlign: TextAlign.center,
    );
  }

  ElevatedButton _buildAcceptButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriversDirection(
              boardingLocation: widget.destinationLocation,
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Accepted!')),
        );
      },
      icon: const Icon(Icons.check),
      label: const Text("Accept"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  ElevatedButton _buildRejectButton() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          isRequestActive = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request denied')),
        );
      },
      icon: const Icon(Icons.cancel),
      label: const Text("Deny"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}