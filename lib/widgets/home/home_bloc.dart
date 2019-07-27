import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hikma_health/authentication/authentication.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';

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
    if (event is SearchButtonPressed) {
      yield HomeLoading();
      try {
        String locationUuid = await userRepository.readLocationUuid();
        List<PatientSearchResult> patients =
            await userRepository.searchPatients(
                event.query,
                locationUuid);
        if (patients != null) {
          yield HomeInitial(query: event.query, patients: patients);
        }
        else {
          yield _emptyState;
        }
      } catch (error) {}
    } else if (event is ClearButtonPressed) {
      yield HomeLoading();
      yield _emptyState;
    } else if (event is LogoutButtonPressed) {
      authenticationBloc.dispatch(LoggedOut());
      yield HomeLogout();
    }
  }
}
