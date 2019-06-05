import 'dart:async';

import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

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
        yield AuthenticationAuthenticated(auto: true);
      } else {
        yield AuthenticationUnauthenticated();
      }
    }
    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await userRepository.persistAuth(event.token);
      yield AuthenticationAuthenticated(auto: false);
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await userRepository.deleteAuth();
      yield AuthenticationUnauthenticated();
    }
  }
}
