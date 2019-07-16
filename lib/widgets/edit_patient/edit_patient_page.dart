import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikma_health/colors.dart';
import 'package:hikma_health/constants.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/user_repository/user_repository.dart';

import 'edit_patient.dart';

class EditPatientPage extends StatefulWidget {

  final UserRepository userRepository;
  final int localId;
  final String uuid;

  EditPatientPage({
    Key key,
    @required this.userRepository,
    @required this.localId,
    @required this.uuid,
  })
      : assert(userRepository != null),
        assert(localId != null),
        assert(uuid != null),
        super(key: key);

  @override
  _EditPatientPageState createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {


  final _formKey = GlobalKey<FormState>();

  bool _justStarted = true;
  String _gender;
  DateTime _birthDate;

  Map<String, TextEditingController> _fieldControllers;

  final _fieldNodes = {
    'firstName': FocusNode(),
    'middleName': FocusNode(),
    'lastName': FocusNode(),
    'firstNameLocal': FocusNode(),
    'middleNameLocal': FocusNode(),
    'lastNameLocal': FocusNode(),
    'address': FocusNode(),
    'city': FocusNode(),
    'district': FocusNode(),
    'state': FocusNode(),
  };

  set _patientData(patientData) {
    _gender = patientData.gender;
    _birthDate = DateTime.parse(patientData.birthDate);
    _fieldControllers = {
      'firstName': TextEditingController(text: patientData.firstName),
      'middleName': TextEditingController(text: patientData.middleName),
      'lastName': TextEditingController(text: patientData.lastName),
      'firstNameLocal': TextEditingController(
          text: patientData.firstNameLocal),
      'middleNameLocal': TextEditingController(
          text: patientData.middleNameLocal),
      'lastNameLocal': TextEditingController(
          text: patientData.lastNameLocal),
      'address': TextEditingController(text: patientData.address),
      'city': TextEditingController(text: patientData.cityVillage),
      'district': TextEditingController(text: patientData.district),
      'state': TextEditingController(text: patientData.state),
    };
  }

  int get _localId => widget.localId;
  String get _uuid => widget.uuid;
  UserRepository get _userRepository => widget.userRepository;
  EditPatientBloc _editPatientBloc;

  @override
  void initState() {
    _editPatientBloc = EditPatientBloc(userRepository: _userRepository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _editPatientBloc,
      listener: (context, state) {
        if (state is EditPatientLoading) {
          _editPatientBloc.dispatch(
            EditPatientStarted(localId: _localId, uuid: _uuid),
          );
        } else if (state is EditPatientInitial) {
          _patientData = state.patientData;
        } else if (state is EditPatientSaved) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Patient'),
        ),
        body: BlocBuilder(
          bloc: _editPatientBloc,
          builder: (context, state) {
            return state is EditPatientLoading
                ? Center(child: CircularProgressIndicator())
                : SafeArea(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: <Widget>[
                  Form(
                    key: _formKey,
                    autovalidate: false,
                    child: Column(
                      children: <Widget>[
                        _buildPersonalInfoFields(),
                        _buildAddressInfoFields(),
                      ],
                    ),
                  ),
                  ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      state is EditPatientSaving
                          ? CircularProgressIndicator()
                          : RaisedButton(
                        child: Text('SAVE'),
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)
                        ),
                        color: hikmaPrimary,
                        textColor: Colors.white,
                        onPressed: () async {
                          if (_validateData()) {
                            Map data = _parseData();
                            _editPatientBloc.dispatch(
                                SaveButtonClicked(
                                  data: data,
                                  uuid: state.patientData.uuid,
                                  localId: _localId,
                                )
                            );
                          }
                        },
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fieldNodes.forEach((_, v) => v.dispose());
    _fieldControllers.forEach((_, v) => v.dispose());
    super.dispose();
  }

  Widget _buildPersonalInfoFields() {
    return Column(
      children: <Widget>[
        _buildTextField(
            'First Name',
            true,
            _fieldControllers['firstName'],
            _fieldNodes['firstName'],
            _fieldNodes['middleName'],
            TextInputAction.next),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        _buildTextField(
            'Middle Name',
            false,
            _fieldControllers['middleName'],
            _fieldNodes['middleName'],
            _fieldNodes['lastName'],
            TextInputAction.next),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        _buildTextField(
            'Last Name',
            true,
            _fieldControllers['lastName'],
            _fieldNodes['lastName'],
            _fieldNodes['firstNameLocal'],
            TextInputAction.next),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        _buildTextField(
            'Local First Name',
            false,
            _fieldControllers['firstNameLocal'],
            _fieldNodes['firstNameLocal'],
            _fieldNodes['middleNameLocal'],
            TextInputAction.next),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        _buildTextField(
            'Local Middle Name',
            false,
            _fieldControllers['middleNameLocal'],
            _fieldNodes['middleNameLocal'],
            _fieldNodes['lastNameLocal'],
            TextInputAction.next),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        _buildTextField(
            'Local Last Name',
            false,
            _fieldControllers['lastNameLocal'],
            _fieldNodes['lastNameLocal'],
            null,
            TextInputAction.next),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        DropdownButtonFormField(
            value: _gender,
            items: ['Male', 'Female', 'Other'].map((String gender) {
              return new DropdownMenuItem<String>(
                child: new Text(gender),
                value: gender.substring(0, 1),
              );
            }).toList(),
            onChanged: (String value) {
              setState(() => _gender = value);
            },
            hint: Text('Gender'),
            validator: (value) {
              return value == null
                  ? 'This field cannot be empty'
                  : null;
            }
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text(
                _birthDate == null
                    ? 'Birth date'
                    : _birthDate.toIso8601String().substring(0, 10),
                style: TextStyle(
                  color:
                  _birthDate == null && !_justStarted
                      ? Colors.red
                      : Colors.black,
                ),
              ),
              onPressed: () async {
                final DateTime selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _birthDate == null
                        ? DateTime.now()
                        : _birthDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now());
                if (selectedDate != null) {
                  setState(() => _birthDate = selectedDate);
                }
              },
            ),
//            FlatButton(
//              child: Text(_birthTime == null ? 'Birth time' : _birthTime.format(context)),
//              onPressed: () async {
//                final TimeOfDay selectedTime = await showTimePicker(
//                  context: context,
//                  initialTime: _birthTime == null ? TimeOfDay.now() : _birthTime,
//                );
//                if (selectedTime != null) {
//                  setState(() => _birthTime = selectedTime);
//                }
//              },
//            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressInfoFields() {
    return Column(
      children: <Widget>[
        _buildTextField(
            'Address',
            false,
            _fieldControllers['address'],
            _fieldNodes['address'],
            _fieldNodes['city'],
            TextInputAction.next),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        _buildTextField(
            'City/Village',
            true,
            _fieldControllers['city'],
            _fieldNodes['city'],
            _fieldNodes['district'],
            TextInputAction.next),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        _buildTextField(
            'District',
            false,
            _fieldControllers['district'],
            _fieldNodes['district'],
            _fieldNodes['state'],
            TextInputAction.next),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        _buildTextField(
            'State/Province',
            false,
            _fieldControllers['state'],
            _fieldNodes['state'],
            null,
            TextInputAction.done),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
      ],
    );
  }

  Widget _buildTextField(String label, bool required,
      TextEditingController controller, FocusNode node,
      FocusNode nextNode, TextInputAction action) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (value) {
        return required && value.isEmpty
            ? 'This field cannot be empty'
            : null;
      },
      focusNode: node,
      textInputAction: action,
      onFieldSubmitted: (value) {
        node.unfocus();
        if (nextNode != null) {
          FocusScope.of(context).requestFocus(nextNode);
        }
      },
    );
  }

  bool _validateData() {
    setState(() {
      _justStarted = false;
    });
    return _formKey.currentState.validate() && _birthDate != null;
  }

  Map _parseData() {
    final NameData nameData = NameData(
        givenName: _fieldControllers['firstName'].text,
        middleName: _fieldControllers['middleName'].text,
        familyName: _fieldControllers['lastName'].text,
        preferred: false
    );

    final AddressData addressData = AddressData(
      address1: _fieldControllers['address'].text,
      address2: '',
      address3: '',
      cityVillage: _fieldControllers['city'].text,
      countyDistrict: _fieldControllers['district'].text,
      stateProvince: _fieldControllers['state'].text,
    );

    final IdentifierData patientId = IdentifierData(
      identifierSourceUuid: 'c1e39ece-3f10-11e4-adec-0800271c1b75',
      identifierPrefix: 'BAH',
      identifierType: UUID_MAP['patientIdentifier'],
      preferred: true,
      voided: false,
    );

    final IdentifierData nationalId = IdentifierData(
      identifierSourceUuid: 'a1a7e96e-83b3-4c1c-b0c6-f24710e62a97',
      identifierPrefix: 'NAT',
      identifierType: UUID_MAP['nationalIdentifier'],
      preferred: false,
      voided: false,
    );

    final AttributeData firstLocalNameAttr = AttributeData(
      uuid: UUID_MAP['firstLocalName'],
      value: _fieldControllers['firstNameLocal'].text,
    );
    final AttributeData middleLocalNameAttr = AttributeData(
      uuid: UUID_MAP['middleLocalName'],
      value: _fieldControllers['middleNameLocal'].text,
    );
    final AttributeData lastLocalNameAttr = AttributeData(
      uuid: UUID_MAP['lastLocalName'],
      value: _fieldControllers['lastNameLocal'].text,
    );

    final PersonData person = PersonData(
        names: [nameData.toMap()],
        addresses: [addressData.toMap()],
        attributes: [
          firstLocalNameAttr.toMap(),
          middleLocalNameAttr.toMap(),
          lastLocalNameAttr.toMap()
        ],
        gender: _gender,
        birthDate: '${_birthDate.toIso8601String().substring(0, 23)}+0100',
        birthDateEstimated: true,
        causeOfDeath: ''
    );

    final PatientData patient = PatientData(
        person: person.toMap(),
        identifiers: [patientId.toMap(), nationalId.toMap()]
    );

    final PatientPostData data = PatientPostData(
      patient: patient.toMap(),
      relationships: [],
    );

    return data.toMap();
  }
}
