import 'package:flutter/material.dart';
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
  String _basicAuth = createBasicAuth('superman', 'Admin123');
  bool _isLoading = false, _isFieldEmpty = true;
  final _searchController = TextEditingController();
  final _searchNode = FocusNode();
  List<PatientSearchResult> _patientList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    setState(() => _isFieldEmpty = _searchController.text.isEmpty);
                  },
                  decoration: InputDecoration(
                    labelText: 'Search Patients',
                    suffixIcon: IconButton(
                      icon: _isLoading
                          ? CircularProgressIndicator(strokeWidth: 1)
                          : Icon(Icons.search),
                      onPressed: _isFieldEmpty
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
                  onPressed: _isFieldEmpty
                      ? null
                      : () {
                    setState(() {
                      _searchNode.unfocus();
                      _searchController.clear();
                      _patientList = null;
                      _isFieldEmpty = true;
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
    _searchController.dispose();
    _searchNode.dispose();
    super.dispose();
  }

  Widget _buildPatientsList() {
    return _isLoading
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
      setState(() => _isLoading = true);
      _patientList = await queryPatient(locationUuid, query);
      setState(() => _isLoading = false);
    }
  }
}
