import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';

import 'edit_patient.dart';

class EditPatientBloc extends Bloc<EditPatientEvent, EditPatientState> {
  final UserRepository userRepository;

  EditPatientBloc({
    @required this.userRepository,
  }) : assert(userRepository != null);

  @override
  EditPatientState get initialState => EditPatientInitial();

  @override
  Stream<EditPatientState> mapEventToState(
      EditPatientEvent event) async* {
    if (event is SaveButtonClicked) {
      yield EditPatientLoading();
      yield EditPatientRegistered();
    }
  }
}
