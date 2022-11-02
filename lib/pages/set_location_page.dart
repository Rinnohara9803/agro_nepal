// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../repositories/google_maps_repository.dart';
// import '../services/shared_service.dart';

// class SetLocationPage extends StatefulWidget {
//   static String routeName = '/setLocationPage';
//   const SetLocationPage({Key? key}) : super(key: key);

//   @override
//   State<SetLocationPage> createState() => _SetLocationPageState();
// }

// class _SetLocationPageState extends State<SetLocationPage> {
//   late GoogleMapController _googleMapController;

//   // List<Marker> _markers = [];
//   Marker? _locationMarker;

//   Marker getMarker(
//     BuildContext context,
//     double latitude,
//     double longitude,
//     String rentId,
//   ) {
//     return Marker(
//       onTap: () {},
//       markerId: MarkerId('kk'),
//       infoWindow: InfoWindow(
//         title: 'kk',
//       ),
//       icon: BitmapDescriptor.defaultMarkerWithHue(
//         BitmapDescriptor.hueRed,
//       ),
//       position: LatLng(
//         latitude,
//         longitude,
//       ),
//     );
//   }

//   final _cameraPosition = CameraPosition(
//     target: LatLng(
//       SharedService.currentPosition.latitude,
//       SharedService.currentPosition.longitude,
//     ),
//     zoom: 12.5,
//     tilt: 0,
//   );

//   @override
//   void initState() {
//     GoogleMapsRepository.determinePosition();
//     _locationMarker = Marker(
//       onTap: () {},
//       markerId: const MarkerId('rino'),
//       infoWindow: const InfoWindow(
//         title: 'CurrentLocation',
//       ),
//       icon: BitmapDescriptor.defaultMarkerWithHue(
//         BitmapDescriptor.hueBlue,
//       ),
//       position: LatLng(SharedService.currentPosition.latitude,
//           SharedService.currentPosition.longitude),
//     );

//     super.initState();
//   }

//   @override
//   void dispose() {
//     _googleMapController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
//         floatingActionButton: FloatingActionButton(
//           backgroundColor: Colors.white,
//           child: const Icon(
//             Icons.center_focus_strong,
//             color: Colors.blueGrey,
//           ),
//           onPressed: () {
//             _googleMapController.animateCamera(
//               CameraUpdate.newCameraPosition(_cameraPosition),
//             );
//           },
//         ),
//         body: Stack(
//           children: [
//             GoogleMap(
//               mapType: MapType.normal,
//               // markers: _markers.map((marker) {
//               //   return marker;
//               // }).toSet(),
//               initialCameraPosition: _cameraPosition,
//               onMapCreated: (controller) => _googleMapController = controller,
//             ),
//             Positioned(
//               right: 10,
//               top: 10,
//               child: IconButton(
//                 color: Colors.blueGrey,
//                 onPressed: () {
//                   _googleMapController.animateCamera(
//                     CameraUpdate.newCameraPosition(
//                       CameraPosition(
//                         target: LatLng(
//                           SharedService.currentPosition.latitude,
//                           SharedService.currentPosition.longitude,
//                         ),
//                         zoom: 15.5,
//                         tilt: 50,
//                       ),
//                     ),
//                   );
//                 },
//                 icon: const Icon(
//                   Icons.location_on_outlined,
//                   size: 35,
//                 ),
//               ),
//             ),
//             Positioned(
//               left: 15,
//               top: 60,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         height: 12,
//                         width: 12,
//                         color: const Color.fromARGB(255, 72, 20, 195),
//                       ),
//                       const SizedBox(
//                         width: 5,
//                       ),
//                       const Text(
//                         'My Location',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 4,
//                   ),
//                   Row(
//                     children: [
//                       Container(
//                         height: 12,
//                         width: 12,
//                         color: Colors.red,
//                       ),
//                       const SizedBox(
//                         width: 5,
//                       ),
//                       const Text(
//                         'Available rents',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
