import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikma_health/authentication/authentication.dart';
import 'package:hikma_health/colors.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:hikma_health/widgets/locations/locations.dart';
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
  final _searchController = TextEditingController();
  final _searchNode = FocusNode();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  HomeBloc _homeBloc;
  AuthenticationBloc _authenticationBloc;

  UserRepository get _userRepository => widget.userRepository;

  @override
  void initState() {
    super.initState();
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _homeBloc = HomeBloc(
        userRepository: _userRepository,
        authenticationBloc: _authenticationBloc
    );
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(
                (ConnectivityResult result) async {
              _homeBloc.dispatch(ClearButtonPressed());
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
            MaterialPageRoute(
                builder: (context) =>
                    LoginPage(userRepository: _userRepository)
            ),
          );
        } else if (state is HomeInitial) {
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
              centerTitle: false,
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
                          PatientRegistrationPage(
                              userRepository: _userRepository
                          )
                      ),
                    );
                  },
                ),
                _online
                    ? IconButton(
                  icon: Icon(Icons.sync),
                  tooltip: 'Sync',
                  onPressed: () async {
                    _searchPatient(_searchController.text);
                    setState(() {
                      if (_online) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return SyncView(userRepository: _userRepository);
                            }
                        );
                      }
                    });
                  },
                )
                    : Container(width: 0, height: 0),
                _online
                    ? IconButton(
                  icon: Icon(Icons.location_on),
                  tooltip: 'Change location',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return LocationsView(userRepository: _userRepository);
                      }
                    );
                  },
                )
                    : Container(width: 0, height: 0),
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
                    'Offline mode: Search results limited.',
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
                        focusNode: _searchNode,
                        onChanged: (query) {
                          setState(() =>
                          _fieldEmpty = _searchController.text.isEmpty
                          );
                        },
                        decoration: InputDecoration(
                          labelText: 'Search Patients',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: _fieldEmpty
                                ? null
                                : () async {
                              _searchPatient(_searchController.text);
                            },
                          ),
                        ),
                        onSubmitted: (query) async {
                          _searchPatient(query);
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
            title: Text(patientsList[index].name),
            subtitle: Text(patientsList[index].id),
            onTap: () async {
              int localId = patientsList[index].localId;
              if (localId == null) {
                localId = await _userRepository
                    .insertOrUpdatePatientByUuid(patientsList[index].uuid);
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDetailsScreen(
                    uuid: patientsList[index].uuid,
                    localId: localId,
                    userRepository: _userRepository,
                  ),
                ),
              ).then((_) {
                _searchPatient(_searchController.text);
              });
            },
          );
        },
      ),
    );
  }

  void _searchPatient(String query) async {
    if (_searchController.text.isNotEmpty) {
      _searchNode.unfocus();
      _homeBloc.dispatch(SearchButtonPressed(query: query));
    }
  }
}
