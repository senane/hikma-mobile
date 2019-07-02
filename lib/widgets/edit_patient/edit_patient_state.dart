import 'package:equatable/equatable.dart';

abstract class EditPatientState extends Equatable {
  EditPatientState([List props = const []]) : super(props);
}

class EditPatientInitial extends EditPatientState {
  @override
  String toString() => 'EditPatientInitial';
}

class EditPatientLoading extends EditPatientState {
  @override
  String toString() => 'EditPatientLoading';
}

class EditPatientRegistered extends EditPatientState {
  @override
  String toString() => 'EditPatientRegistered';
}
