import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';
import '../../constants.dart';
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

      String body = json.encode(event.data).replaceAll('"null"', 'null');

      print('adding job');
      await userRepository.dbHelper.insertToJobQueue(
          event.localId, JOB_UPDATE_PATIENT, body);

      Map patient = await userRepository.dbHelper.editPatient(event.data, event.localId);
      print(patient);

      print('edited');
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        userRepository.executeJobs();
      }

      yield EditPatientEdited();
    } else if (event is EditPatientStarted) {
      PatientPersonalInfo patientData = await userRepository
          .getLocalPatientInfo(event.localId, event.uuid);
      yield EditPatientInitial(patientData: patientData);
    }
  }
}
