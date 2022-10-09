part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class GetLastLocationLoadingState extends UserState {}

class GetLastLocationLoadedState extends UserState {
  final BikeLocation location;
  const GetLastLocationLoadedState(this.location);
}

class GetLastLocationErrorState extends UserState {}

class ParkBikeLoadingState extends UserState {}

class ParkBikeLoadedState extends UserState {}

class ParkBikeErrorState extends UserState {}
