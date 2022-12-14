import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class BikeLocation {
  DateTime date;
  LatLng location;
  bool isParked = false;
  late String mainAddress;
  late String subAddress;

  BikeLocation({
    required this.date,
    required this.location,
  });

  BikeLocation.fromJson(Map<String, dynamic> json)
      : date = DateTime.parse(json['createdAt']),
        location = LatLng(json['latitude'], json['longitude']),
        isParked = json['state'];

  Future<void> setAddressFromLocation() async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    Placemark place = placemarks[0];

    mainAddress = "${place.street}, ${place.subThoroughfare}";
    subAddress =
        "${place.subLocality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}";
  }
}
