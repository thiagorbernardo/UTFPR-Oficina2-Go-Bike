part of 'theme_cubit.dart';

@immutable
class ThemeState extends Equatable {
  final ThemeData themeData;
  final bool isOwner;
  final bool bikeState;

  const ThemeState(this.themeData, this.isOwner, this.bikeState);

  @override
  List<Object?> get props => [themeData, isOwner, bikeState];
}
