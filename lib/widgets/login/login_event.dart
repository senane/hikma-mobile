import 'package:equatable/equatable.dart';
import 'package:hikma_health/model/location.dart';
import 'package:meta/meta.dart';

abstract class LoginEvent extends Equatable {
  LoginEvent([List props = const []]) : super(props);
}

class LoginStarted extends LoginEvent {
  @override
  String toString() => 'LoginStarted';
}


class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;
  final Location location;

  LoginButtonPressed({
    @required this.username,
    @required this.password,
    @required this.location
  }) : super([username, password, location]);

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password,'
          ' location: $location }';
}

class LoginCancelled extends LoginEvent {
  @override
  String toString() => 'LoginCancelled';
}
