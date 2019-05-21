import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hikma_health/colors.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/widgets/login_screen.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:hikma_health/widgets/new_patient_screen.dart';
import 'package:hikma_health/widgets/patient_details_screen.dart';


class PatientSearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  bool _loading = false, _fieldEmpty = true, _online = false;
  String _basicAuth;
  final _secureStorage = FlutterSecureStorage();
  final _searchController = TextEditingController();
  final _searchNode = FocusNode();
  List<PatientSearchResult> _patientList;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;


  @override
  void initState() {
    super.initState();
    _secureStorage.read(key: 'auth').then((value) => _basicAuth = value);
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
          setState(() => _online = result != ConnectivityResult.none);
        });
  }

  @override
  Widget build(BuildContext context) {

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
                    PatientRegistrationPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            onPressed: () async {
              await _secureStorage.delete(key: 'auth');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
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
                    setState(() => _fieldEmpty = _searchController.text.isEmpty);
                  },
                  decoration: InputDecoration(
                    labelText: 'Search Patients',
                    suffixIcon: IconButton(
                      icon: _loading
                          ? CircularProgressIndicator(strokeWidth: 1)
                          : Icon(Icons.search),
                      onPressed: _fieldEmpty
                          ? null
                          : () async {
                        searchPatient(
                            'bb0e512e-d225-11e4-9c67-080027b662ec',
                            _searchController.text,
                            context
                        );
                      },
                    ),
                  ),
                  focusNode: _searchNode,
                  onSubmitted: (query) async {
                    searchPatient(
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
                    setState(() {
                      _searchNode.unfocus();
                      _searchController.clear();
                      _patientList = null;
                      _fieldEmpty = true;
                    });
                  },
                ),
              ],
            ),
          ),
          _buildPatientsList(),
        ],
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

  Widget _buildPatientsList() {
    return _loading
        ? Padding(
      padding: EdgeInsets.only(top: 128),
      child: CircularProgressIndicator(),
    )
        : Expanded(
      child: ListView.builder(
        itemCount: _patientList?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                    '$API_BASE/patientImage?patientUuid=${_patientList[index].uuid}',
                    headers: {'authorization': _basicAuth}
                ),
                backgroundColor: Colors.transparent
            ),
            title: Text(_patientList[index].name),
            subtitle: Text(_patientList[index].id),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PatientDetailsScreen(
                          uuid: _patientList[index].uuid
                      )
                  )
              );
            },
          );
        },
      ),
    );
  }

  void searchPatient(String locationUuid, String query, BuildContext context) async {
    if (_searchController.text.isNotEmpty) {
      _searchNode.unfocus();
      setState(() => _loading = true);
      _patientList = await queryPatient(locationUuid, query);
      setState(() => _loading = false);
    }
  }
}
