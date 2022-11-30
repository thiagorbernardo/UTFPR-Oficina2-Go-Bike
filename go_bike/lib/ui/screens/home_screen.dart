import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:maps_launcher/maps_launcher.dart';

import 'package:go_bike/cubit/theme_cubit.dart';
import 'package:go_bike/data/bloc/user/user_bloc.dart';
import 'package:go_bike/ui/app_bar/bottom_bar.dart';
import 'package:go_bike/utils/app_colors.dart';
import 'package:go_bike/config/globals.dart' as globals;

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController mapController = MapController();
  final PanelController panelController = PanelController();
  final PanelController subPanelController = PanelController();
  LatLng _latLng = LatLng(-25.439226, -49.2692129);
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<UserBloc>(context).add(GetLastlocation());
    _getUserLocation();

    Timer.periodic(const Duration(seconds: 5), (timer) {
      BlocProvider.of<UserBloc>(context).add(GetLastlocation());
      print('Buscando localização');
    });
  }

  void _getUserLocation() async {
    try {
      Position position = await _determinePosition();
      _latLng = LatLng(position.latitude, position.longitude);
      mapController.move(_latLng, 16);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        bottomNavigationBar: const BottomBar(),
        floatingActionButton: FloatingActionButton.small(
          elevation: 0,
          highlightElevation: 0,
          onPressed: () async {
            _getUserLocation();
          },
          backgroundColor: Colors.white,
          splashColor: Colors.transparent,
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              FontAwesomeIcons.locationArrow,
              size: 28,
              color: AppColors.primary,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        body: SlidingUpPanel(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          parallaxEnabled: true,
          maxHeight: 250,
          minHeight: 57,
          controller: panelController,
          panel: ColumnRowWidget(
            userLocation: _latLng,
            mapController: mapController,
            panelController: subPanelController,
          ),
          body: BlocListener<UserBloc, UserState>(
            listenWhen: (previous, current) =>
                previous is GetLastLocationLoadingState ||
                current is GetLastLocationLoadedState ||
                current is UserInitial,
            listener: (context, state) async {
              if (state is GetLastLocationLoadedState) {
                _markers = [
                  Marker(
                    point: state.location.location,
                    width: 80,
                    height: 80,
                    builder: (context) => GestureDetector(
                      child: Icon(
                        FontAwesomeIcons.bicycle,
                        color: Colors.indigo.shade700,
                        size: 35,
                      ),
                      onTap: () => {
                        mapController.move(state.location.location, 18),
                        panelController.open(),
                      },
                    ),
                  )
                ];
                mapController.move(state.location.location, 16);
                setState(() {});
              }
            },
            child: GestureDetector(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center: _latLng,
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
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
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
                    markers: _markers,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ColumnRowWidget extends StatelessWidget {
  final LatLng userLocation;
  final MapController mapController;
  final PanelController panelController;

  const ColumnRowWidget({
    Key? key,
    required this.userLocation,
    required this.mapController,
    required this.panelController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bikeName = "Bicicleta de Thiago";
    String distanceInKm = "";
    int diffTime = 1;
    String diffType = "min";

    return BlocBuilder<UserBloc, UserState>(
      buildWhen: (previous, current) =>
          previous is GetLastLocationLoadingState &&
          current is GetLastLocationLoadedState,
      builder: (context, state) {
        print("GET LOCATION - BIKE STATE ${globals.bikeState}");
        String parkedText = context.read<ThemeCubit>().isParked
            ? "Desestacionar"
            : "Estacionar";
        if (state is GetLastLocationLoadedState) {
          double distance = Geolocator.distanceBetween(
                  userLocation.latitude,
                  userLocation.longitude,
                  state.location.location.latitude,
                  state.location.location.longitude) /
              1000;
          distanceInKm = distance.toStringAsFixed(2);

          Duration diff = DateTime.now().difference(state.location.date);

          if (diff.inMinutes > 60) {
            diffTime = diff.inHours;
            diffType = "horas";
          } else {
            diffTime = diff.inMinutes;
            diffType = "min";
          }
        }

        return SlidingUpPanel(
          controller: panelController,
          minHeight: 0,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          isDraggable: true,
          parallaxEnabled: true,
          panel: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    FontAwesomeIcons.minus,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          bikeName,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => panelController.close(),
                          child: const Icon(
                            FontAwesomeIcons.solidCircleXmark,
                            size: 25,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      state is GetLastLocationLoadedState
                          ? "${state.location.mainAddress},\n${state.location.subAddress}"
                          : "",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$diffTime $diffType atrás',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ClickableCard(
                          title: parkedText,
                          color: Colors.deepPurple.shade800,
                          icon: FontAwesomeIcons.squareParking,
                          onTap: context.read<ThemeCubit>().state.isOwner
                              ? () => {
                                    BlocProvider.of<UserBloc>(context)
                                        .add(ParkBike(!globals.bikeState)),
                                  }
                              : null,
                        ),
                        const Spacer(),
                        ClickableCard(
                          title: "Direções",
                          color: Colors.indigo.shade500,
                          icon: FontAwesomeIcons.route,
                          onTap: state is GetLastLocationLoadedState
                              ? () {
                                  MapsLauncher.launchCoordinates(
                                      state.location.location.latitude,
                                      state.location.location.longitude);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  FontAwesomeIcons.minus,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  'Bicicletas',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              Divider(
                height: 10,
                thickness: 0.2,
                color: Colors.grey.shade700,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: state is GetLastLocationLoadedState
                          ? () {
                              mapController.move(state.location.location, 17);
                              panelController.open();
                            }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/bike.png',
                            width: 100,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                bikeName,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '$diffTime $diffType atrás',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          state is GetLastLocationLoadedState
                              ? Text(
                                  '$distanceInKm km',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                )
                              : const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.grey,
                                    strokeWidth: 3,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ClickableCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final void Function()? onTap;

  const ClickableCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isOwner = onTap != null;
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.grey.shade100,
        elevation: 3,
        child: SizedBox(
          height: 100,
          width: 170,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isOwner ? color : Colors.grey,
                  size: 35,
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: isOwner ? Colors.black : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
