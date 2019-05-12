import 'package:hikma_health/constants.dart';
import 'package:meta/meta.dart';

class PatientSearchResult {
  final String id;
  final String uuid;
  final String name;

  PatientSearchResult.fromJson(Map jsonMap)
      : id = jsonMap['identifier'],
        uuid = jsonMap['uuid'],
        name = '${jsonMap['givenName']} ${jsonMap['familyName']}';
}

class PatientSearchList {
  final List<PatientSearchResult> patientSearchList;

  PatientSearchList.fromJson(Map jsonMap)
      : patientSearchList = List<PatientSearchResult>() {
    for (var jsonPatient in jsonMap['pageOfResults']) {
      patientSearchList.add(PatientSearchResult.fromJson(jsonPatient));
    }
  }
}

class PatientPersonalInfo {
  final String uuid, patientId, nationalId;
  final String firstName, middleName, lastName;
  final String firstNameLocal, middleNameLocal, lastNameLocal;
  final String birthDate, gender;
  final String address, cityVillage, state, district;

  PatientPersonalInfo({
    @required this.uuid,
    @required this.patientId,
    @required this.nationalId,
    @required this.firstName,
    @required this.middleName,
    @required this.lastName,
    @required this.birthDate,
    @required this.gender,
    @required this.firstNameLocal,
    @required this.middleNameLocal,
    @required this.lastNameLocal,
    @required this.address,
    @required this.cityVillage,
    @required this.district,
    @required this.state
  });

  factory PatientPersonalInfo.fromJson(Map<String, dynamic> jsonMap) {

    Map identifiers = Map();
    for (Map attr in jsonMap['identifiers']) {
      String key = attr['identifierType']['uuid'];
      String value = attr['identifier'];
      identifiers[key] = value;
    }

    Map personalData = jsonMap['person'];
    Map attributes = Map();
    for (Map attr in personalData['attributes']) {
      String key = attr['attributeType']['uuid'];
      var value = attr['value'];
      attributes[key] = value;
    }

    Map nameData = personalData['names'][0];
    Map addressData = personalData['addresses'][0];

    return PatientPersonalInfo(
        uuid: personalData['uuid'],
        patientId: identifiers[UUID_MAP['patientIdentifier']],
        nationalId: identifiers[UUID_MAP['nationalIdentifier']],
        firstName: nameData['givenName'],
        middleName: nameData['middleName'],
        lastName: nameData['familyName'],
        birthDate: personalData['birthdate'].toString().substring(0, 10),
        gender: personalData['gender'],
        firstNameLocal: attributes[UUID_MAP['firstLocalName']],
        middleNameLocal: attributes[UUID_MAP['middleLocalName']],
        lastNameLocal: attributes[UUID_MAP['lastLocalName']],
        address: addressData['address1'],
        cityVillage: addressData['cityVillage'],
        district: addressData['countyDistrict'],
        state: addressData['stateProvince']
    );
  }
}
