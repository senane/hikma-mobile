import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  HomeEvent([List props = const []]) : super(props);
}

class SearchButtonPressedOnline extends HomeEvent {
  final String query;
  final String locationUuid;

  SearchButtonPressedOnline({
    @required this.query,
    @required this.locationUuid,
  }) : super([query, locationUuid]);

  @override
  String toString() =>
      'SearchButtonPressedOnline { query: $query, locationUuid, $locationUuid }';
}

class SearchButtonPressedOffline extends HomeEvent {
  final String query;
  final String locationUuid;

  SearchButtonPressedOffline({
    @required this.query,
    @required this.locationUuid,
  }) : super([query, locationUuid]);

  @override
  String toString() =>
      'SearchButtonPressedOffline { query: $query, locationUuid, $locationUuid }';
}

class ClearButtonPressed extends HomeEvent {
  @override
  String toString() => 'ClearButtonPressed';
}

class LogoutButtonPressed extends HomeEvent {
  @override
  String toString() => 'LogoutButtonPressed';
}
