import 'package:equatable/equatable.dart';
import 'package:hikma_health/model/location.dart';
import 'package:meta/meta.dart';

abstract class LocationListState extends Equatable {
  LocationListState([List props = const []]) : super(props);
}

class LocationListLoading extends LocationListState {
  @override
  String toString() => 'LocationListLoading';
}

class LocationListReloading extends LocationListState {
  @override
  String toString() => 'LocationListReloading';
}

class LocationListSuccess extends LocationListState {

  final String currentLocationUuid;
  final List<Location> locations;

  LocationListSuccess({
    @required this.currentLocationUuid,
    @required this.locations
  })
      : assert(currentLocationUuid != null),
        assert(locations != null),
        super([locations]);

  @override
  String toString() => 'LocationListSuccess';
}

class LocationListFailure extends LocationListState {
  final String error;

  LocationListFailure({@required this.error}) : super([error]);

  @override
  String toString() => 'LocationListFailure { error: $error }';
}

class LocationListClosed extends LocationListState {
  @override
  String toString() => 'LocationListClosed';
}
