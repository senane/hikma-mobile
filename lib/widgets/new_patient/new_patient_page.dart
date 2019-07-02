import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikma_health/colors.dart';
import 'package:hikma_health/constants.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

import 'new_patient.dart';

class PatientRegistrationPage extends StatefulWidget {
  final UserRepository userRepository;

  PatientRegistrationPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  _PatientRegistrationPageState createState() => _PatientRegistrationPageState();
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  String _gender;
  DateTime _birthDate;
//  TimeOfDay _birthTime;

  final _fieldControllers = {
    'firstName': TextEditingController(),
    'middleName': TextEditingController(),
    'lastName': TextEditingController(),
    'firstNameLocal': TextEditingController(),
    'middleNameLocal': TextEditingController(),
    'lastNameLocal': TextEditingController(),
    'address': TextEditingController(),
    'city': TextEditingController(),
    'district': TextEditingController(),
    'state': TextEditingController(),
  };

  final _fieldNodes = {
    'firstName': FocusNode(),
    'middleName': FocusNode(),
    'lastName': FocusNode(),
    'firstNameLocal': FocusNode(),
    'middleNameLocal': FocusNode(),
    'lastNameLocal': FocusNode(),
    'gender': FocusNode(),
    'birthDate': FocusNode(),
    'birthTime': FocusNode(),
    'address': FocusNode(),
    'city': FocusNode(),
    'district': FocusNode(),
    'state': FocusNode(),
  };

  UserRepository get _userRepository => widget.userRepository;
  NewPatientBloc _newPatientBloc;

  @override
  void initState() {
    _newPatientBloc = NewPatientBloc(userRepository: _userRepository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _newPatientBloc,
      listener: (context, state) {
        if (state is NewPatientRegistered) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder(
        bloc: _newPatientBloc,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('New Patient'),
            ),
            body: SafeArea(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: <Widget>[
                  FormBuilder(
                    key: _fbKey,
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
                      state is NewPatientLoading
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
                            _newPatientBloc
                                .dispatch(SaveButtonClicked(data: data));
                          }
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _fieldNodes.forEach((_, v) => v.dispose());
//    _fieldControllers.forEach((_, v) => v.dispose());
    super.dispose();
  }

  Widget _buildPersonalInfoFields() {
    return Column(
      children: <Widget>[
        _buildFormBuilderTextField(
            'first_name',
            'First Name',
            true,
            _fieldControllers['firstName'],
            _fieldNodes['firstName'],
            _fieldNodes['middleName'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'middle_name',
            'Middle Name',
            false,
            _fieldControllers['middleName'],
            _fieldNodes['middleName'],
            _fieldNodes['lastName'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'last_name',
            'Last Name',
            true,
            _fieldControllers['lastName'],
            _fieldNodes['lastName'],
            _fieldNodes['firstNameLocal'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'local_first_name',
            'Local First Name',
            false,
            _fieldControllers['firstNameLocal'],
            _fieldNodes['firstNameLocal'],
            _fieldNodes['middleNameLocal'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'local_middle_name',
            'Local Middle Name',
            false,
            _fieldControllers['middleNameLocal'],
            _fieldNodes['middleNameLocal'],
            _fieldNodes['lastNameLocal'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'local_last_name',
            'Local Last Name',
            false,
            _fieldControllers['lastNameLocal'],
            _fieldNodes['lastNameLocal'],
            null,
            TextInputAction.next),
        FormBuilderRadio(
          decoration: InputDecoration(labelText: 'Gender'),
          leadingInput: true,
          attribute: "gender",
          validators: [
            FormBuilderValidators.required(
                errorText: 'This field cannot be empty'
            ),
          ],
          options: [
            "Male",
            "Female",
            "Other",
          ]
              .map((gender) => FormBuilderFieldOption(value: gender))
              .toList(growable: false),
          onChanged: (dynamic value) async {
            _gender = value.substring(0, 1);
          },
        ),
        _padding(),
        FormBuilderDateTimePicker(
          attribute: 'birth_date',
          inputType: InputType.date,
          format: DateFormat('yyyy-MM-dd'),
          decoration: InputDecoration(labelText: 'Birth date (YYYY-MM-DD)'),
          validators: [
            FormBuilderValidators.required(
                errorText: 'This field cannot be empty'
            ),
          ],
          onChanged: (dynamic value) async {
            _birthDate = value;
          },
        ),
        _padding(),
//        FormBuilderDateTimePicker(
//          attribute: 'birth_time',
//          inputType: InputType.time,
//          format: DateFormat('HH:MM'),
//          decoration: InputDecoration(labelText: 'Birth time'),
//          onChanged: (dynamic value) async {
//            _birthTime = value;
//          },
//        ),
//        _padding(),
      ],
    );
  }

  Widget _buildAddressInfoFields() {
    return Column(
      children: <Widget>[
        _buildFormBuilderTextField(
            'address',
            'Address',
            false,
            _fieldControllers['address'],
            _fieldNodes['address'],
            _fieldNodes['city'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'city_village',
            'City/Village',
            true,
            _fieldControllers['city'],
            _fieldNodes['city'],
            _fieldNodes['district'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'district',
            'District',
            false,
            _fieldControllers['district'],
            _fieldNodes['district'],
            _fieldNodes['state'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'state_province',
            'State/Province',
            false,
            _fieldControllers['state'],
            _fieldNodes['state'],
            null,
            TextInputAction.done),
      ],
    );
  }

  Widget _padding() {
    return Padding(padding: EdgeInsets.symmetric(vertical: 8));
  }

  Widget _buildFormBuilderTextField(String attribute, String label, bool required,
      TextEditingController controller, FocusNode node,
      FocusNode nextNode, TextInputAction action) {
    return Column (
      children: <Widget>[
        FormBuilderTextField(
          attribute: attribute,
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
          ),
          validators: [
                (value) {
              if (required && value.isEmpty) {
                return 'This field cannot be empty';
              }
            },
          ],
          focusNode: node,
          textInputAction: action,
          onFieldSubmitted: (value) {
            node.unfocus();
            if (nextNode != null) {
              FocusScope.of(context).requestFocus(nextNode);
            }
          },
        ),
        _padding(),
      ],
    );

  }

  bool _validateData() {
    return _fbKey.currentState.validate() && _birthDate != null;
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
