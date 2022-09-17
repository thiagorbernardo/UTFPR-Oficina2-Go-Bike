import 'package:bloc/bloc.dart';
import 'package:go_bike/utils/routes/routes.dart';

class BottomNavCubit extends Cubit<int> {
  BottomNavCubit({int initalState = 0}) : super(initalState);

  void changePage(int index) => emit(index);

  String get path {
    switch (state) {
      case 1:
        return Routes.profile;
      default:
        return Routes.home;
    }
  }

  void reset() => emit(0);
}
