import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_bike/models/bike_location.dart';

class ApiProvider {
  final Dio _api = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_URL']!,
      // baseUrl: "http://10.0.2.2:4000/api",
    ),
  );

  Future<BikeLocation> getLastLocation(String bikeId) async {
    final res = await _api.get<dynamic>("/bike/$bikeId/lastLocation");

    BikeLocation location = BikeLocation.fromJson(res.data);
    await location.setAddressFromLocation();

    return location;
  }

  Future<void> parkBike(String bikeId, bool state) async {
    await _api.post<dynamic>("/bike/$bikeId/park", data: {
      "value": state,
    });
  }
}
