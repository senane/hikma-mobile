import 'package:hikma_health/model/patient.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  HomeState([List props = const []]) : super(props);
}

class HomeInitial extends HomeState {

  final String query;
  final List<PatientSearchResult> patients;

  HomeInitial({@required this.query, @required this.patients}) :
        assert(patients != null),
        assert(query != null),
        super([query, patients]);

  @override
  String toString() => 'HomeInitial';
}

class HomeLoading extends HomeState {
  @override
  String toString() => 'HomeLoading';
}

class HomeLogout extends HomeState {
  @override
  String toString() => 'HomeLogout';
}
