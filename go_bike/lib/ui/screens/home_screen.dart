import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_bike/data/bloc/user/user_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:go_bike/main.dart';
import 'package:go_bike/ui/app_bar/bottom_bar.dart';
import 'package:go_bike/utils/app_colors.dart';
import 'package:go_bike/utils/routes/routes.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _getLocation();
  }

  void _getLocation() async {
    try {
      BlocProvider.of<UserBloc>(context).add(Connect());

      Position position = await _determinePosition();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        bottomNavigationBar: const BottomBar(),
        body: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            //utfpr -25.439226,-49.2692129
            center: LatLng(-25.439226, -49.2692129),
            zoom: 17,
            maxZoom: 19.0,
            enableScrollWheel: true,
            scrollWheelVelocity: 0.005,
            plugins: [
              const LocationMarkerPlugin(
                centerOnLocationUpdate: CenterOnLocationUpdate.once,
                turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
              ),
            ],
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.example.app',
            ),
            LocationMarkerLayerOptions(
              marker: const DefaultLocationMarker(
                child: Icon(
                  Icons.navigation,
                  color: Colors.white,
                ),
              ),
              markerSize: const Size(35, 35),
              markerDirection: MarkerDirection.heading,
            ),
            MarkerLayerOptions(
              markers: [
                Marker(
                  point: LatLng(-25.439226, -49.2695529),
                  width: 80,
                  height: 80,
                  builder: (context) => IconButton(
                    icon: const Icon(
                      FontAwesomeIcons.bicycle,
                      color: AppColors.error,
                      size: 30,
                    ),
                    onPressed: () => print("marker"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
