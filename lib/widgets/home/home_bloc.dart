import 'dart:async';

import 'package:flutter_sqlcipher/sqlite.dart';
import 'package:hikma_health/authentication/authentication.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'home.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;
  final HomeInitial _emptyState = HomeInitial(query:'', patients: []);

  HomeBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  @override
  HomeState get initialState => _emptyState;

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {

    if (event is SearchButtonPressedOnline) {
      yield HomeLoading();
      try {
        String auth = await userRepository.readAuth();
        List<PatientSearchResult> patients =
          await queryPatient(
              auth: auth,
              locationUuid: event.locationUuid,
              query: event.query);
        if (patients != null) {
          yield HomeInitial(query: event.query, patients: patients);
        }
        else {
          yield _emptyState;
        }
      } catch (error) {}
    } else if (event is SearchButtonPressedOffline) {
      yield HomeLoading();
      SQLiteCursor cursor = await userRepository
          .dbHelper.searchPatients(event.query);
      List<PatientSearchResult> patients =
          PatientSearchList.fromCursor(cursor).patientSearchList;
      if (patients != null) {
        yield HomeInitial(query: event.query, patients: patients);
      }
      else {
        yield _emptyState;
      }
    } else if (event is ClearButtonPressed) {
      yield HomeLoading();
      yield _emptyState;
    } else if (event is LogoutButtonPressed) {
      authenticationBloc.dispatch(LoggedOut());
      yield HomeLogout();
    }
  }
}
