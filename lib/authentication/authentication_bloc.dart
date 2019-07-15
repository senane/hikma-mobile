import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';

import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      final bool hasAuth = await userRepository.hasAuth();
      if (hasAuth) {
        /// This is just to give at least one second for the splash screen to
        /// properly when the already logged in user runs the app
        await Future.delayed(Duration(seconds: 1));
        await userRepository.initDatabase();
        yield AuthenticationAuthenticated(auto: true);
      } else {
        yield AuthenticationUnauthenticated();
      }
    }
    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await userRepository.persistAuth(event.auth);
      await userRepository.initDatabase();
      yield AuthenticationAuthenticated(auto: false);
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await userRepository.deleteAuth();
      await userRepository.deleteDatabase();
      yield AuthenticationUnauthenticated();
    }
  }
}
