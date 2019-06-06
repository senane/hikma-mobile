import 'package:equatable/equatable.dart';

abstract class NewPatientState extends Equatable {
  NewPatientState([List props = const []]) : super(props);
}

class NewPatientInitial extends NewPatientState {
  @override
  String toString() => 'NewPatientInitial';
}

class NewPatientLoading extends NewPatientState {
  @override
  String toString() => 'NewPatientLoading';
}

class NewPatientRegistered extends NewPatientState {
  @override
  String toString() => 'NewPatientRegistered';
}
