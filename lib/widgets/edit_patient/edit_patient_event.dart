import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class EditPatientEvent extends Equatable {
  EditPatientEvent([List props = const []]) : super(props);
}

class SaveButtonClicked extends EditPatientEvent {
  final Map data;
  SaveButtonClicked({@required this.data}) : super ([data]);
  @override
  String toString() => 'PatientDetailsStarted';
}

class CancelButtonClicked extends EditPatientEvent {
  @override
  String toString() => 'PatientDetailsStarted';
}
