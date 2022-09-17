import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:go_bike/data/repository/mqtt_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final _mqttRepository = MqttRepository();
  UserBloc() : super(UserInitial()) {
    on<Connect>((event, emit) async {
      try {
        _mqttRepository.connect();
      } catch (e) {
        print(e);
      }
      // try {
      //   if (event.page == 1) {
      //     emit(RegistersLoadingState());
      //   } else {
      //     emit(RegistersPaginatedLoadingState());
      //   }
      //   final registers = await _repository.fetchRegisters(event.page);
      //   if (event.page == 1) {
      //     _registers = registers;
      //   } else {
      //     _registers.addAll(registers);
      //   }
      //   emit(RegistersLoadedState(_registers));
      // } catch (e) {
      //   emit(RegistersErrorState(e));
      // }
    });
  }
}
