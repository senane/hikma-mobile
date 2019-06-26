import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:meta/meta.dart';

import 'sync.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final UserRepository userRepository;

  SyncBloc({@required this.userRepository,}) : assert(userRepository != null);

  @override
  SyncState get initialState => SyncLoading();

  @override
  Stream<SyncState> mapEventToState(SyncEvent event) async* {
    if (event is SyncStarted) {
      yield SyncLoading();
      try {
        await userRepository.executeJobs();
        await userRepository.updateAllPatients();
        // temporary simulation of the sync time
        await Future.delayed(Duration(seconds: 2));
        yield SyncSuccess();
      } catch (error) {
        yield SyncFailure(error: error);
      }
      yield SyncSuccess();
    }
  }
}
