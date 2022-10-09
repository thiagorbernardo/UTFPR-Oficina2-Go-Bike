part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class Connect extends UserEvent {
  @override
  List<Object> get props => [];
}

class ParkBike extends UserEvent {
  @override
  List<Object> get props => [];
}

class GetLastlocation extends UserEvent {
  @override
  List<Object> get props => [];
}
