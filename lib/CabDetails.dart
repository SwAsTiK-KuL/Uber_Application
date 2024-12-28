// import 'package:flutter/material.dart';
// import 'StartScreen.dart'; // Import the StartScreen widget
//
// class CabDetails extends StatelessWidget {
//   final String driverName;
//   final String driverEmail;
//   final String driverPhone;
//   final String boardingLocation;
//   final String profileImage;
//
//   const CabDetails({//     Key? key,
//     required this.driverName,
//     required this.driverEmail,
//     required this.driverPhone,
//     required this.boardingLocation,
//     required this.profileImage,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Cab Details'),
//         backgroundColor: Colors.black,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Profile Image
//             CircleAvatar(
//               radius: 50,
//               backgroundImage: AssetImage(profileImage),
//             ),
//             const SizedBox(height: 16.0),
//
//             // Driver Name
//             Text(
//               'Name: $driverName',
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8.0),
//
//             // Driver Email
//             Text(
//               'Email: $driverEmail',
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 8.0),
//
//             // Driver Phone
//             Text(
//               'Phone: $driverPhone',
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 16.0),
//
//             // Boarding Location
//             Text(
//               'Boarding Location: $boardingLocation',
//               style: const TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
