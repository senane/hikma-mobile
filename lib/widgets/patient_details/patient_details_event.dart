import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class PatientDetailsEvent extends Equatable {
  PatientDetailsEvent([List props = const []]) : super(props);
}

class PatientDetailsStarted extends PatientDetailsEvent {
  final String uuid;
  PatientDetailsStarted({@required this.uuid}) : super ([uuid]);
  @override
  String toString() => 'PatientDetailsStarted';
}
