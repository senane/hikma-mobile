import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikma_health/authentication/authentication.dart';
import 'package:hikma_health/colors.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:hikma_health/widgets/login/login.dart';
import 'package:hikma_health/widgets/new_patient/new_patient.dart';
import 'package:hikma_health/widgets/patient_details/patient_details.dart';
import 'package:hikma_health/widgets/sync/sync.dart';

import 'home.dart';

class HomeScreen extends StatefulWidget {

  final UserRepository userRepository;

  HomeScreen({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _fieldEmpty = true, _online = true;
  String _basicAuth;
  final _searchController = TextEditingController();
  final _searchNode = FocusNode();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  HomeBloc _homeBloc;
  AuthenticationBloc _authenticationBloc;

  UserRepository get _userRepository => widget.userRepository;


  @override
  void initState() {
    super.initState();
    _userRepository.readAuth().then((auth) => _basicAuth = auth);
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _homeBloc = HomeBloc(
        userRepository: _userRepository,
        authenticationBloc: _authenticationBloc
    );
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
          setState(() {
            _online = result != ConnectivityResult.none;
            if (_online) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SyncView(userRepository: _userRepository);
                  }
              );
            }
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _homeBloc,
      listener: (context, state) {
        if (state is HomeLogout) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
                LoginPage(userRepository: _userRepository)),
          );
        }
        else if (state is HomeInitial) {
          _searchController.text = state.query;
          _fieldEmpty = _searchController.text.isEmpty;
        }
      },
      child: BlocBuilder<HomeEvent, HomeState>(
        bloc: _homeBloc,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Hikma Home"),
              centerTitle: true,
              leading: Padding(
                  padding: EdgeInsets.all(12),
                  child: ImageIcon(AssetImage('assets/logo.png'))
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  tooltip: 'Add new patient',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          PatientRegistrationPage(userRepository: _userRepository)),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.sync),
                  tooltip: 'Sync',
                  onPressed: () async {
                    await _userRepository.queueJob(0, 0, {});
                  },
                ),
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  tooltip: 'Logout',
                  onPressed: () {
                    _homeBloc.dispatch(LogoutButtonPressed());
                  },
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                _online
                    ? Container(width: 0, height: 0)
                    : Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  width: double.infinity,
                  color: Colors.red,
                  child: Text(
                    'Offline Mode',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      TextField(
                        controller: _searchController,
                        onChanged: (query) {
                          setState(() =>
                          _fieldEmpty = _searchController.text.isEmpty);
                        },
                        decoration: InputDecoration(
                          labelText: 'Search Patients',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: _fieldEmpty
                                ? null
                                : () async {
                              _searchPatient(
                                  'bb0e512e-d225-11e4-9c67-080027b662ec',
                                  _searchController.text,
                                  context
                              );
                            },
                          ),
                        ),
                        focusNode: _searchNode,
                        onSubmitted: (query) async {
                          _searchPatient(
                              'bb0e512e-d225-11e4-9c67-080027b662ec',
                              query,
                              context
                          );
                        },
                      ),
                      FlatButton(
                        child: Text('Clear'),
                        textColor: hikmaPrimary,
                        onPressed: _fieldEmpty
                            ? null
                            : () {
                          _searchNode.unfocus();
                          _homeBloc.dispatch(ClearButtonPressed());
                        },
                      ),
                    ],
                  ),
                ),
                state is HomeInitial
                    ? _buildPatientsList(state.patients)
                    : Padding(
                  padding: EdgeInsets.only(top: 64),
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _searchNode.dispose();
    _connectivitySubscription.cancel();
  }

  Widget _buildPatientsList(patientsList) {
    return Expanded(
      child: ListView.builder(
        itemCount: patientsList?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                    '$API_BASE/patientImage?patientUuid=${patientsList[index].uuid}',
                    headers: {'authorization': _basicAuth}
                ),
                backgroundColor: Colors.transparent
            ),
            title: Text(patientsList[index].name),
            subtitle: Text(patientsList[index].id),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDetailsScreen(
                    uuid: patientsList[index].uuid,
                    userRepository: _userRepository,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _searchPatient(String locationUuid, String query, BuildContext context) async {
    if (_searchController.text.isNotEmpty) {
      _searchNode.unfocus();
      _homeBloc.dispatch(
          SearchButtonPressed(locationUuid: locationUuid, query: query)
      );
    }
  }
}
