import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class EditPatientEvent extends Equatable {
  EditPatientEvent([List props = const []]) : super(props);
}

class EditPatientStarted extends EditPatientEvent {
  final int localId;
  final String uuid;
  EditPatientStarted({
    @required this.localId,
    @required this.uuid,
  }) : super ([localId]);
  @override
  String toString() => 'EditPatientStarted';
}

class SaveButtonClicked extends EditPatientEvent {
  final Map data;
  final String uuid;
  final int localId;
  SaveButtonClicked({
    @required this.data,
    @required this.uuid,
    @required this.localId}) : super ([data]);
  @override
  String toString() => 'SaveButtonClicked';
}

class CancelButtonClicked extends EditPatientEvent {
  @override
  String toString() => 'CancelButtonClicked';
}
