import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:go_bike/data/repository/api_provider.dart';
import 'package:go_bike/models/bike_location.dart';
import 'package:latlong2/latlong.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final _repository = ApiProvider();
  UserBloc() : super(UserInitial()) {
    on<GetLastlocation>((event, emit) async {
      try {
        emit(GetLastLocationLoadingState());
        final location = await _repository.getLastLocation("123");
        emit(GetLastLocationLoadedState(location));
      } catch (e) {
        emit(GetLastLocationErrorState());
      }
    });
    on<ParkBike>((event, emit) async {
      try {
        emit(ParkBikeLoadingState());
        await _repository.parkBike("123");
        emit(ParkBikeLoadedState());
      } catch (e) {
        emit(ParkBikeErrorState());
      }
    });
  }
}
