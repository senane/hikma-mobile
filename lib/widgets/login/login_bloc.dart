import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hikma_health/authentication/authentication.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'login.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {

   if (event is LoginButtonPressed) {
      yield LoginLoading();
      try {
        final token = await userRepository.authenticate(
          username: event.username,
          password: event.password,
        );
        if (token != null) {
          authenticationBloc.dispatch(LoggedIn(auth: token));
        }
        yield LoginInitial();
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    } else if (event is LoginCancelled) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }
}
