import 'package:hikma_health/model/patient.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class PatientDetailsState extends Equatable {
  PatientDetailsState([List props = const []]) : super(props);
}

class PatientDetailsLoading extends PatientDetailsState {
  @override
  String toString() => 'PatientDetailsLoading';
}

class PatientDetailsLoaded extends PatientDetailsState {

  final PatientPersonalInfo patientData;

  PatientDetailsLoaded({@required this.patientData}) :
        assert(patientData != null),
        super([patientData]);

  @override
  String toString() => 'PatientDetailsInitial';
}
