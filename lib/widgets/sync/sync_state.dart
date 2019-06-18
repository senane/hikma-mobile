import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class SyncState extends Equatable {
  SyncState([List props = const []]) : super(props);
}

class SyncLoading extends SyncState {
  @override
  String toString() => 'SyncLoading';
}

class SyncSuccess extends SyncState {
  @override
  String toString() => 'SyncSuccessful';
}

class SyncFailure extends SyncState {

  final String error;

  SyncFailure({@required this.error}) :
        assert(error != null),
        super([error]);

  @override
  String toString() => 'SyncFailure';
}
