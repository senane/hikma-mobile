import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';

import 'new_patient.dart';

class NewPatientBloc extends Bloc<NewPatientEvent, NewPatientState> {
  final UserRepository userRepository;

  NewPatientBloc({
    @required this.userRepository,
  }) : assert(userRepository != null);

  @override
  NewPatientState get initialState => NewPatientInitial();

  @override
  Stream<NewPatientState> mapEventToState(
      NewPatientEvent event) async* {
    if (event is SaveButtonClicked) {
      yield NewPatientLoading();
      userRepository.createPatientFromForm(event.data);
      yield NewPatientRegistered();
    }
  }
}
