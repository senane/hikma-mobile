import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';

import '../../constants.dart';
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
      // Make a new local patient
      int patientLocalId = await userRepository.addPatient(event.data);
      // Queue job to create new patient online
      await userRepository.queueJob(patientLocalId, JOB_CREATE_PATIENT, event.data);

      PatientIds patient = await createPatient(auth: auth, body: event.data);
      print(patient.uuid);
      await userRepository.updateCreatedPatient(patientLocalId, patient);
      yield NewPatientRegistered();
    }
  }
}
