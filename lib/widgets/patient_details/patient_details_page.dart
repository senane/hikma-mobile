import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:hikma_health/widgets/charts/simple_line.dart';
import 'package:hikma_health/widgets/edit_patient/edit_patient_page.dart';
import '../../colors.dart';
import 'patient_details.dart';
import 'patient_details_state.dart';

class PatientDetailsScreen extends StatefulWidget {

  final String uuid;
  final int localId;
  final UserRepository userRepository;
  PatientDetailsScreen({
    Key key,
    @required this.uuid,
    @required this.localId,
    @required this.userRepository
  })
      : assert(uuid != null),
//        assert(localId != null),
        assert(userRepository != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  String _basicAuth;
  PatientDetailsBloc _patientBloc;

  int get _localId => widget.localId;
  String get _uuid => widget.uuid;
  UserRepository get _userRepository => widget.userRepository;

  @override
  void initState() {
    super.initState();
    _patientBloc = PatientDetailsBloc(userRepository: _userRepository);
    _userRepository.readAuth().then((auth) => _basicAuth = auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Patient Details"),
        ),
        body: BlocBuilder(
          bloc: _patientBloc,
          builder: (BuildContext context, state) {
            if (state is PatientDetailsLoading) {
              _patientBloc.dispatch(
                  PatientDetailsStarted(localId: _localId, uuid: _uuid),
              );
              return Center(child: CircularProgressIndicator());
            }
            return Center(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 64.0,
                        backgroundImage: NetworkImage(
                          '$API_BASE/patientImage?patientUuid=${widget.uuid}',
                          headers: {'authorization': _basicAuth},
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                      Text(
                        '${state.patientData.firstName} '
                            '${state.patientData.lastName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'sans-serif-condensed',
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        color: hikmaPrimary,
                        tooltip: 'Edit',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPatientPage(
                                uuid: _uuid,
                                localId: _localId,
                                userRepository: _userRepository,
                              ),
                            ),
                          ).then((value) {
                            print('reloading');
                            _patientBloc.dispatch(
                                PatientDetailsStarted(
                                    localId: _localId,
                                    uuid: _uuid
                                )
                            );
                            print('reloaded');
                          });
                        },
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 16)),
                  _buildDataBit(
                    'Local Name',
                    '${state.patientData.firstNameLocal} '
                        '${state.patientData.lastNameLocal}',
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  _buildDataBit('Patient ID', state.patientData.patientId),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  _buildDataBit('National ID', state.patientData.nationalId),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  _buildDataBit('Birthday', state.patientData.birthDate),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  _buildDataBit('Gender', state.patientData.gender),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  _buildDataBit('Address', state.patientData.address),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  _buildDataBit('City/Village', state.patientData.cityVillage),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  _buildDataBit('State', state.patientData.state),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  _buildDataBit('District', state.patientData.district),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  Container(
                    height: 300,
                    child: SimpleLineChart.withDummyData(),
                  ),
                ],
              ),
            );
          },

        )
    );
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
