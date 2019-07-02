import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class EditPatientEvent extends Equatable {
  EditPatientEvent([List props = const []]) : super(props);
}

class SaveButtonClicked extends EditPatientEvent {
  final Map data;
  SaveButtonClicked({@required this.data}) : super ([data]);
  @override
  String toString() => 'SaveButtonClicked';
}

class CancelButtonClicked extends EditPatientEvent {
  @override
  String toString() => 'CancelButtonClicked';
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