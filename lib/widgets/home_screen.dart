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
  final _key = GlobalKey<ScaffoldState>();
  String _basicAuth = createBasicAuth('superman', 'Admin123');
  bool _isLoading = false;
  final _searchController = TextEditingController();
  final _searchNode = FocusNode();
  List<PatientSearchResult> _patientList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
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
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Patients',
                    suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          searchPatient(
                              'bb0e512e-d225-11e4-9c67-080027b662ec',
                              _searchController.text,
                              context
                          );
                        }
                    ),
                  ),
                  focusNode: _searchNode,
                  onSubmitted: (query) async {
                    searchPatient(
                        'bb0e512e-d225-11e4-9c67-080027b662ec',
                        query,
                        context);
                  },
                ),
              ),
              _buildPatientsList(),
            ],
          ),
        )
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
      padding: EdgeInsets.all(16),
      child: CircularProgressIndicator(),
    )
        : Expanded(
      child: ListView.builder(
          itemCount: _patientList?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {

            return ListTile(
              leading: CircleAvatar(
                    radius: 16.0,
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
          }
      ),
    );
  }

  void searchPatient(String locationUuid, String query, BuildContext context) async {
    if (_searchController.text.isNotEmpty) {
      _searchNode.unfocus();
      setState(() => _isLoading = true);
      _patientList = await queryPatient(locationUuid, query);
      setState(() => _isLoading = false);
    } else {
      _key.currentState.showSnackBar(
          SnackBar(
            content: Text('Please type something '
                'in the search field then try again'),
            backgroundColor: hikmaPrimary,
          )
      );
    }
  }
}