import 'package:equatable/equatable.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:meta/meta.dart';

abstract class EditPatientState extends Equatable {
  EditPatientState([List props = const []]) : super(props);
}

class EditPatientLoading extends EditPatientState {
  @override
  String toString() => 'EditPatientLoading';
}

class EditPatientInitial extends EditPatientState {

  final PatientPersonalInfo patientData;

  EditPatientInitial({@required this.patientData}) :
        assert(patientData != null),
        super([patientData]);

  @override
  String toString() => 'EditPatientInitial';
}

class EditPatientSaving extends EditPatientState {
  @override
  String toString() => 'EditPatientSaving';
}

class EditPatientSaved extends EditPatientState {
  @override
  String toString() => 'EditPatientSaved';
}
