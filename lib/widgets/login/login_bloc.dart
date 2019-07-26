import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:hikma_health/authentication/authentication.dart';
import 'package:hikma_health/model/location.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';

import 'login.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  List<LoginLocation> locations;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginStarting();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {

    if (event is LoginStarted) {
      await userRepository.deleteInstance();
      yield LoginChooseInstance();

    } else if (event is LoginInstanceChosen) {
      yield LoginInstanceLoading();
      await userRepository.persistInstance(event.apiBase);
      try {
        locations = await getLocations(event.apiBase);
        yield LoginCredentials(locations: locations, instance: event.apiBase);
      } catch (error) {
        await userRepository.deleteInstance();
        yield LoginFailure(error: error.toString());
        yield LoginChooseInstance();
      }

    } else if (event is LoginButtonPressed) {
      yield LoginLoading();
      try {
        final auth = await userRepository.authenticate(
          username: event.username,
          password: event.password,
        );
        if (auth != null) {
          authenticationBloc.dispatch(LoggedIn(auth: auth, location: event.location));
        } else {
          yield LoginCredentials(
              locations: locations,
              instance: await userRepository.readInstance());
        }
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    } else if (event is LoginCancelled) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }
}
