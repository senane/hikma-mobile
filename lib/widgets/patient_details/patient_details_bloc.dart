import 'dart:async';

import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'patient_details.dart';

class PatientDetailsBloc extends Bloc<PatientDetailsEvent, PatientDetailsState> {
  final UserRepository userRepository;
  final PatientDetailsLoading _emptyState = PatientDetailsLoading();

  PatientDetailsBloc({
    @required this.userRepository,
  }) : assert(userRepository != null);

  @override
  PatientDetailsState get initialState => _emptyState;

  @override
  Stream<PatientDetailsState> mapEventToState(
      PatientDetailsEvent event) async* {
    if (event is PatientDetailsStarted) {
      PatientPersonalInfo patientData = await userRepository
          .getLocalPatientInfo(event.localId, event.uuid);
      print(patientData.firstName);
      yield PatientDetailsLoaded(patientData: patientData);
    }
  }
}
