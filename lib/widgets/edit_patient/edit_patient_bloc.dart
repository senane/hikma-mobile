import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';

import 'edit_patient.dart';

class EditPatientBloc extends Bloc<EditPatientEvent, EditPatientState> {
  final UserRepository userRepository;

  EditPatientBloc({
    @required this.userRepository,
  }) : assert(userRepository != null);

  @override
  EditPatientState get initialState => EditPatientLoading();

  @override
  Stream<EditPatientState> mapEventToState(
      EditPatientEvent event) async* {
    if (event is EditPatientStarted) {
      PatientPersonalInfo patientData = await userRepository
          .getLocalPatientInfo(event.localId, event.uuid);
      yield EditPatientInitial(patientData: patientData);
    } else if (event is SaveButtonClicked) {
      yield EditPatientSaving();
      await userRepository.editPatient(event.data, event.localId);
      yield EditPatientSaved();
    }
  }
}
