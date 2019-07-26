import 'package:equatable/equatable.dart';
import 'package:hikma_health/model/location.dart';
import 'package:meta/meta.dart';

abstract class LoginState extends Equatable {
  LoginState([List props = const []]) : super(props);
}

class LoginStarting extends LoginState {
  @override
  String toString() => 'LoginStarting';
}

class LoginChooseInstance extends LoginState {
  @override
  String toString() => 'LoginStarting';
}

class LoginCredentials extends LoginState {

  final List<LoginLocation> locations;
  final String instance;

  LoginCredentials({@required this.instance, @required this.locations})
      : super([instance, locations]);

  @override
  String toString() => 'LoginCreditials';
}

class LoginLoading extends LoginState {
  @override
  String toString() => 'LoginLoading';
}

class LoginInstanceLoading extends LoginState {
  @override
  String toString() => 'LoginInstanceLoading';
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({@required this.error}) : super([error]);

  @override
  String toString() => 'LoginFailure { error: $error }';
}
