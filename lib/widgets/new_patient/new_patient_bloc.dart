import 'dart:async';

import 'package:hikma_health/database/database_calls.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

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
      String auth = await userRepository.readAuth();
      await createPatient(auth: auth, body: event.data);
      await queueJob(auth: auth, body: event.data);
      yield NewPatientRegistered();
    }
  }
}
