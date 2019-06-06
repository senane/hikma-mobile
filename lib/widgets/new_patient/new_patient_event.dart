import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class NewPatientEvent extends Equatable {
  NewPatientEvent([List props = const []]) : super(props);
}

class SaveButtonClicked extends NewPatientEvent {
  final Map data;
  SaveButtonClicked({@required this.data}) : super ([data]);
  @override
  String toString() => 'PatientDetailsStarted';
}

class CancelButtonClicked extends NewPatientEvent {
  @override
  String toString() => 'PatientDetailsStarted';
}
