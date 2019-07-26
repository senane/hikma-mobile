import 'package:equatable/equatable.dart';
import 'package:hikma_health/model/location.dart';
import 'package:meta/meta.dart';

abstract class LocationListEvent extends Equatable {
  LocationListEvent([List props = const []]) : super(props);
}

class LocationListOpened extends LocationListEvent {
  @override
  String toString() => 'LocationListOpened';
}

class LocationChanged extends LocationListEvent {
  final Location location;

  LocationChanged({@required this.location}) : super([location]);

  @override
  String toString() =>
      'LocationChanged { name: ${location.name}, uuid: ${location.uuid} }';
}

class CloseButtonPressed extends LocationListEvent {
  @override
  String toString() => 'CloseButtonPressed';
}
