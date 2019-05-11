import 'package:flutter/material.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/network/network_calls.dart';

class PatientDetailsScreen extends StatefulWidget {

  final String uuid;
  PatientDetailsScreen({@required this.uuid});

  @override
  State<StatefulWidget> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  bool _isLoading = true;
  String _basicAuth = createBasicAuth('superman', 'Admin123');
  PatientPersonalInfo _patientData;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      _loadPatientData();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Patient Details"),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                    radius: 64.0,
                    backgroundImage: NetworkImage(
                        '$API_BASE/patientImage?patientUuid=${widget.uuid}',
                        headers: {'authorization': _basicAuth}
                    ),
                    backgroundColor: Colors.transparent
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                Text(
                  '${_patientData.firstName} ${_patientData.lastName}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'sans-serif-condensed',
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 16)),
            _buildDataBit('Local Name', '${_patientData.firstNameLocal} ${_patientData.lastNameLocal}'),
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            _buildDataBit('Patient ID', _patientData.patientId),
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            _buildDataBit('National ID', _patientData.nationalId),
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            _buildDataBit('Birthday', _patientData.birthDate),
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            _buildDataBit('Gender', _patientData.gender),
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            _buildDataBit('Address', _patientData.address),
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            _buildDataBit('City/Village', _patientData.cityVillage),
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            _buildDataBit('State', _patientData.state),
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            _buildDataBit('District', _patientData.district),
          ],
        ),
      ),
    );
  }

  void _loadPatientData() async {
    _patientData = await getPatient(widget.uuid);
    setState(() => _isLoading = false);
  }

  Widget _buildDataBit(String description, data) {
    return RichText(
      text: TextSpan(
        // Note: Styles for TextSpans must be explicitly defined.
        // Child text spans will inherit styles from parent
        style: TextStyle(
            fontSize: 18,
            color: Colors.black87
        ),
        children: <TextSpan>[
          new TextSpan(
              text: '$description: ',
              style: new TextStyle(
                fontWeight: FontWeight.bold,
              )
          ),
          new TextSpan(text: '$data'),
        ],
      ),
    );
  }
}