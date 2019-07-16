import 'package:equatable/equatable.dart';

abstract class SyncEvent extends Equatable {
  SyncEvent([List props = const []]) : super(props);
}

class SyncStarted extends SyncEvent {
  @override
  String toString() => 'SyncStarted';
}
