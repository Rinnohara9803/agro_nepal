import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../repositories/google_maps_repository.dart';
import '../services/shared_service.dart';
import '../utilities/themes.dart';
import 'make_payments_page.dart';

class SetLocationPage extends StatefulWidget {
  static String routeName = '/setLocationPage';
  const SetLocationPage({Key? key}) : super(key: key);

  @override
  State<SetLocationPage> createState() => _SetLocationPageState();
}

class _SetLocationPageState extends State<SetLocationPage> {
  late GoogleMapController _googleMapController;
  double _latitude = SharedService.currentPosition.latitude;
  double _longitude = SharedService.currentPosition.longitude;

  final List<Marker> _markers = [];
  Marker? _locationMarker;

  Marker getCurrentMarker(double lat, double long) {
    return Marker(
      markerId: const MarkerId('Delivery Location'),
      infoWindow: const InfoWindow(
        title: 'Delivery Location',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
      position: LatLng(
        lat,
        long,
      ),
    );
  }

  Marker getMarker(
    BuildContext context,
    double latitude,
    double longitude,
    String rentId,
  ) {
    return Marker(
      onTap: () {},
      markerId: const MarkerId('Delivery Location'),
      infoWindow: const InfoWindow(
        title: 'Delivery Location',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
      position: LatLng(
        latitude,
        longitude,
      ),
    );
  }

  final _cameraPosition = CameraPosition(
    target: LatLng(
      SharedService.currentPosition.latitude,
      SharedService.currentPosition.longitude,
    ),
    zoom: 12.5,
    tilt: 0,
  );

  @override
  void initState() {
    GoogleMapsRepository.determinePosition();
    _locationMarker = Marker(
      onTap: () {},
      markerId: const MarkerId('Delivery Location'),
      infoWindow: const InfoWindow(
        title: 'Delivery Location',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      ),
      position: LatLng(
        SharedService.currentPosition.latitude,
        SharedService.currentPosition.longitude,
      ),
    );
    SharedService.deliveryPosition = LatLng(
      SharedService.currentPosition.latitude,
      SharedService.currentPosition.longitude,
    );
    _markers.add(_locationMarker!);

    super.initState();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              markers: _markers.map((marker) {
                return marker;
              }).toSet(),
              onTap: (latLng) {
                print(latLng.latitude);
                setState(() {
                  if (_markers.length > 1) {
                    _markers.removeLast();
                    _latitude = latLng.latitude;
                    _longitude = latLng.longitude;
                    _markers.add(
                      getCurrentMarker(
                        latLng.latitude,
                        latLng.longitude,
                      ),
                    );
                  } else {
                    _latitude = latLng.latitude;
                    _longitude = latLng.longitude;
                    _markers.add(
                      getCurrentMarker(
                        latLng.latitude,
                        latLng.longitude,
                      ),
                    );
                  }
                });
              },
              initialCameraPosition: _cameraPosition,
              onMapCreated: (controller) => _googleMapController = controller,
            ),
            Positioned(
              left: 15,
              top: 20,
              child: Row(
                children: [
                  Container(
                    height: 12,
                    width: 12,
                    color: const Color.fromARGB(255, 72, 20, 195),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    'Delivery Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 100,
                ),
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  child: InkWell(
                    onTap: () async {
                      SharedService.deliveryPosition =
                          LatLng(_latitude, _longitude);
                      await placemarkFromCoordinates(_latitude, _longitude)
                          .then(
                        (data) {
                          SharedService.deliveryLocation =
                              '${data.first.subLocality} , ${data.first.locality} , ${data.first.administrativeArea}';
                          Navigator.pushReplacementNamed(
                            context,
                            MakePaymentsPage.routeName,
                            arguments: {
                              'country': data.first.country,
                              'administrativeArea':
                                  data.first.administrativeArea,
                              'locality': data.first.locality,
                              'subLocality': data.first.subLocality,
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: ThemeClass.primaryColor,
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: const Center(
                        child: AutoSizeText(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
