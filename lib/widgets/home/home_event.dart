import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  HomeEvent([List props = const []]) : super(props);
}

class SearchButtonPressed extends HomeEvent {
  final String query;
  final String locationUuid;

  SearchButtonPressed({
    @required this.query,
    @required this.locationUuid,
  }) : super([query, locationUuid]);

  @override
  String toString() =>
      'SearchButtonPressed { query: $query, locationUuid, $locationUuid }';
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
