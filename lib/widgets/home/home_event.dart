import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class HomeEvent extends Equatable {
  HomeEvent([List props = const []]) : super(props);
}

class SearchButtonPressed extends HomeEvent {
  final String query;

  SearchButtonPressed({@required this.query,}) : super([query]);

  @override
  String toString() =>
      'SearchButtonPressed { query: $query }';
}

class ClearButtonPressed extends HomeEvent {
  @override
  String toString() => 'ClearButtonPressed';
}

class LogoutButtonPressed extends HomeEvent {
  @override
  String toString() => 'LogoutButtonPressed';
}
