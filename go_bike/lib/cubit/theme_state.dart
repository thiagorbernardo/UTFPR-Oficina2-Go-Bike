part of 'theme_cubit.dart';

@immutable
class ThemeState extends Equatable {
  final ThemeData themeData;
  final bool isOwner;

  const ThemeState(this.themeData, this.isOwner);

  @override
  List<Object?> get props => [themeData, isOwner];
}
