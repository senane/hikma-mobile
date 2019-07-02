import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';

import 'edit_patient.dart';

class EditPatientBloc extends Bloc<EditPatientEvent, EditPatientState> {
  final UserRepository userRepository;
  final EditPatientLoading _emptyState = EditPatientLoading();

  EditPatientBloc({
    @required this.userRepository,
  }) : assert(userRepository != null);

  @override
  EditPatientState get initialState => _emptyState;

  @override
  Stream<EditPatientState> mapEventToState(
      EditPatientEvent event) async* {
    if (event is SaveButtonClicked) {
      yield EditPatientLoading();
      yield EditPatientRegistered();
    } else if (event is EditPatientStarted) {
      PatientPersonalInfo patientData = await userRepository
          .getLocalPatientInfo(event.localId, event.uuid);
      yield EditPatientInitial(patientData: patientData);
    }
  }
}
