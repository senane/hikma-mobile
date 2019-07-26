import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hikma_health/model/location.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';

import 'locations.dart';

class LocationsViewBloc extends Bloc<LocationListEvent, LocationListState> {
  final UserRepository userRepository;

  LocationsViewBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  LocationListState get initialState => LocationListLoading();

  @override
  Stream<LocationListState> mapEventToState(LocationListEvent event) async* {
    if (event is LocationListOpened) {
      if (currentState is LocationListFailure) {
        yield LocationListReloading();
      }
      try {
        String currentLocationUuid = await userRepository.readLocationUuid();
        List<Location> locations = await getLocations();
        yield LocationListSuccess(
            currentLocationUuid: currentLocationUuid,
            locations: locations
        );
      } catch (error) {
        yield LocationListFailure(error: error.toString());
      }
    } else if (event is LocationChanged) {
      await userRepository.persistLocation(event.location);
      yield LocationListClosed();
    } else if (event is CloseButtonPressed) {
      yield LocationListClosed();
    }
  }
}
