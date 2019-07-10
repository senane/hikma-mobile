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

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  int get _localId => widget.localId;
  String get _uuid => widget.uuid;
  UserRepository get _userRepository => widget.userRepository;
  EditPatientBloc _editPatientBloc;

  Map<String, TextEditingController> _fieldControllers;

  Map<String, TextEditingController> _initFieldControllers (state) {
    return {
      'firstName': TextEditingController(text: state.patientData.firstName),
      'middleName': TextEditingController(text: state.patientData.middleName),
      'lastName': TextEditingController(text: state.patientData.lastName),
      'firstNameLocal': TextEditingController(
          text: state.patientData.firstNameLocal),
      'middleNameLocal': TextEditingController(
          text: state.patientData.middleNameLocal),
      'lastNameLocal': TextEditingController(
          text: state.patientData.lastNameLocal),
      'gender': TextEditingController(text: state.patientData.gender),
      'birthDate': TextEditingController(text: state.patientData.birthDate),
      'address': TextEditingController(text: state.patientData.address),
      'city': TextEditingController(text: state.patientData.cityVillage),
      'district': TextEditingController(text: state.patientData.district),
      'state': TextEditingController(text: state.patientData.state),
    };
  }

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
    'birthDate': FocusNode(),
  };

  final Map _genders = {
    'M': 'Male',
    'F': 'Female',
    'O': 'Other',
  };

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
        if (state is EditPatientInitial) {
          _fieldControllers = _initFieldControllers(state);
        } else if (state is EditPatientEdited) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder(
        bloc: _editPatientBloc,
        builder: (context, state) {
          if (state is EditPatientLoading) {
            _editPatientBloc.dispatch(
              EditPatientStarted(localId: _localId, uuid: _uuid),
            );
            return Center(child: CircularProgressIndicator());
          } else if (state is EditPatientEdited) {
            return Center(child: CircularProgressIndicator());
          }

          print(_fieldControllers['firstName'].text);

          return Scaffold(
            appBar: AppBar(
              title: Text('Edit Patient'),
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
                        _buildPersonalInfoFields(state, _fieldControllers),
                        _buildAddressInfoFields(state, _fieldControllers),
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
                      state is EditPatientLoading
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
                            Map data = _parseData(_fieldControllers);
                            print('alpha');
                            print(widget.localId);
                            print(_localId);
                            _editPatientBloc
                                .dispatch(
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

  Widget _buildPersonalInfoFields(state, _fieldControllers) {
    return Column(
      children: <Widget>[
        _buildFormBuilderTextField(
            'first_name',
            state.patientData.firstName,
            'First Name',
            true,
            _fieldControllers['firstName'],
            _fieldNodes['firstName'],
            _fieldNodes['middleName'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'middle_name',
            state.patientData.middleName,
            'Middle Name',
            false,
            _fieldControllers['middleName'],
            _fieldNodes['middleName'],
            _fieldNodes['lastName'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'last_name',
            state.patientData.lastName,
            'Last Name',
            true,
            _fieldControllers['lastName'],
            _fieldNodes['lastName'],
            _fieldNodes['firstNameLocal'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'local_first_name',
            state.patientData.firstNameLocal,
            'Local First Name',
            false,
            _fieldControllers['firstNameLocal'],
            _fieldNodes['firstNameLocal'],
            _fieldNodes['middleNameLocal'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'local_middle_name',
            state.patientData.middleNameLocal,
            'Local Middle Name',
            false,
            _fieldControllers['middleNameLocal'],
            _fieldNodes['middleNameLocal'],
            _fieldNodes['lastNameLocal'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'local_last_name',
            state.patientData.lastNameLocal,
            'Local Last Name',
            false,
            _fieldControllers['lastNameLocal'],
            _fieldNodes['lastNameLocal'],
            _fieldNodes['birthDate'],
            TextInputAction.next),
        FormBuilderDateTimePicker(
          attribute: 'birth_date',
          inputType: InputType.date,
          format: DateFormat('yyyy-MM-dd'),
          decoration: InputDecoration(labelText: 'Birth date (YYYY-MM-DD)'),
          controller: _fieldControllers['birthDate'],
          validators: [
            FormBuilderValidators.required(
                errorText: 'This field cannot be empty'
            ),
          ],
          focusNode: _fieldNodes['birthDate'],
          initialValue: DateTime.parse(_fieldControllers['birthDate'].text),
        ),
        _padding(),
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
            _fieldControllers['gender'] = TextEditingController(
                text: value.substring(0, 1)
            );
          },
          initialValue: _genders[_fieldControllers['gender'].text],
        ),
        _padding(),
      ],
    );
  }

  Widget _buildAddressInfoFields(state, _fieldControllers) {
    return Column(
      children: <Widget>[
        _buildFormBuilderTextField(
            'address',
            state.patientData.address,
            'Address',
            false,
            _fieldControllers['address'],
            _fieldNodes['address'],
            _fieldNodes['city'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'city_village',
            state.patientData.cityVillage,
            'City/Village',
            true,
            _fieldControllers['city'],
            _fieldNodes['city'],
            _fieldNodes['district'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'district',
            state.patientData.district,
            'District',
            false,
            _fieldControllers['district'],
            _fieldNodes['district'],
            _fieldNodes['state'],
            TextInputAction.next),
        _buildFormBuilderTextField(
            'state_province',
            state.patientData.state,
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

  Widget _buildFormBuilderTextField(String attribute, String init, String label,
      bool required,
      TextEditingController controller, FocusNode node,
      FocusNode nextNode, TextInputAction action) {
    return Column (
      children: <Widget>[
        FormBuilderTextField(
          attribute: attribute,
//          initialValue: controller.text,
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
//          onChanged: (dynamic value) async {
//            controller = TextEditingController(text: value);
//          },
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
    return _fbKey.currentState.validate();
  }

  Map _parseData(_fieldControllers) {
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
        gender: _fieldControllers['gender'].text,
        birthDate: _fieldControllers['birthDate'].text,
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
