import 'package:equatable/equatable.dart';
import 'package:hikma_health/model/location.dart';
import 'package:meta/meta.dart';

abstract class AuthenticationEvent extends Equatable {
  AuthenticationEvent([List props = const []]) : super(props);
}

class AppStarted extends AuthenticationEvent {
  @override
  String toString() => 'AppStarted';
}

class LoggedIn extends AuthenticationEvent {
  final String auth;
  final Location location;

  LoggedIn({@required this.auth, @required this.location})
      : super([auth, location]);

  @override
  String toString() => 'LoggedIn { auth: $auth, location: $location }';
}

class LoggedOut extends AuthenticationEvent {
  @override
  String toString() => 'LoggedOut';
}
