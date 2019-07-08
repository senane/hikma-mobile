import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/network/network_calls.dart';
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
      String auth = await userRepository.readAuth();
      print(event.uuid);
      print(event.data);
      updatePatient(auth: auth, body: event.data, uuid: event.uuid);
      yield EditPatientEdited();
    } else if (event is EditPatientStarted) {
      PatientPersonalInfo patientData = await userRepository
          .getLocalPatientInfo(event.localId, event.uuid);
      yield EditPatientInitial(patientData: patientData);
    }
  }
}
