import 'package:flutter_sqlcipher/sqlite.dart';
import 'package:hikma_health/constants.dart';
import 'package:meta/meta.dart';

class PatientSearchResult {
  final String id;
  final String uuid;
  final String name;
  final int localId;

  PatientSearchResult.fromJson(Map jsonMap)
      : id = jsonMap['identifier'],
        uuid = jsonMap['uuid'],
        name = '${jsonMap['givenName']} ${jsonMap['familyName']}',
        localId = null;

  PatientSearchResult.fromRow(row)
      : id = row[columnPID],
        uuid = row[columnUuid],
        name = (row[columnGivenName] + ' ' + row[columnFamilyName]),
        localId = row[columnId];
}

class PatientSearchList {
  final List<PatientSearchResult> patientSearchList;

  PatientSearchList.fromJson(Map jsonMap)
      : patientSearchList = List<PatientSearchResult>() {
    for (var jsonPatient in jsonMap['pageOfResults']) {
      patientSearchList.add(PatientSearchResult.fromJson(jsonPatient));
    }
  }

  PatientSearchList.fromCursor(SQLiteCursor rows)
      : patientSearchList = List<PatientSearchResult> () {
    for (var row in rows) {
      patientSearchList.add(PatientSearchResult.fromRow(row));
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

  factory PatientPersonalInfo.fromRow(Map<String, dynamic> row) {
    void nullToString(key, value) {
      if (value == '') {
        row[key] = ' ';
      }
    }
    row.forEach(nullToString);
    return PatientPersonalInfo(
        uuid: row[columnUuid],
        patientId: row[columnPID],
        nationalId: row[columnNID],
        firstName: row[columnGivenName],
        middleName: row[columnMiddleName],
        lastName: row[columnFamilyName],
        birthDate: row[columnBirthDate].toString().substring(0, 10),
        gender: row[columnGender],
        firstNameLocal: row[columnFirstNameLocal],
        middleNameLocal: row[columnMiddleNameLocal],
        lastNameLocal: row[columnLastNameLocal],
        address: row[columnAddress1],
        cityVillage: row[columnCityVillage],
        district: row[columnCountyDistrict],
        state: row[columnStateProvince],
    );
  }

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

class PatientPostData {
  final Map patient;
  final List<Map> relationships;

  PatientPostData({this.patient, this.relationships});

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["patient"] = patient;
    // No relationships for now
    map["relationships"] = relationships;

    return map;
  }
}

class PatientData {
  final Map person;
  final List<Map> identifiers;

  PatientData({@required this.person, @required this.identifiers});

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["person"] = person;
    map["identifiers"] = identifiers;

    return map;
  }
}

class PersonData {
  final List<Map> names;
  final List<Map> addresses;
  final List<Map> attributes;
  final String gender;
  final String birthDate;
  final String birthTime;
  final bool birthDateEstimated;
  final String deathDate;
  final String causeOfDeath;

  PersonData({this.names, this.addresses, this.attributes, this.gender,
    this.birthDate, this.birthDateEstimated, this.birthTime,
    this.deathDate, this.causeOfDeath});

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['names'] = names;
    map['addresses'] = addresses;
    map['attributes'] = attributes;
    map['gender'] = gender;
    map['birthdate'] = birthDate;
    map['birthdateEstimated'] = birthDateEstimated;
    map['birthtime'] = birthTime == null ? 'null' : birthTime;
    map['deathDate'] = deathDate == null ? 'null' : deathDate;
    map['causeOfDeath'] = causeOfDeath == null ? '' : causeOfDeath;
    return map;
  }
}

class IdentifierData {
  final String identifierSourceUuid;
  final String identifierPrefix;
  final String identifierType;
  final dynamic preferred;
  final bool voided;

  IdentifierData({this.identifierSourceUuid, this.identifierPrefix,
    this.identifierType, this.preferred, this.voided});

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["identifierSourceUuid"] = identifierSourceUuid;
    map["identifierPrefix"] = identifierPrefix;
    map["identifierType"] = identifierType;
    map["preferred"] = preferred;
    map["voided"] = voided;

    return map;
  }
}

class NameData {
  final String givenName;
  final String middleName;
  final String familyName;
  final String display;
  final dynamic preferred;

  NameData({@required this.givenName, this.middleName, @required this.familyName,
    this.display, this.preferred});

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["givenName"] = givenName;
    map["middleName"] = middleName;
    map["familyName"] = familyName;
    map["display"] = '$givenName $familyName';
    map["preferred"] = preferred;

    return map;
  }
}

class AttributeData {
  final String uuid;
  final dynamic value;
  final String hydratedObject;

  AttributeData({
    @required this.uuid,
    @required this.value,
    this.hydratedObject});

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['attributeType'] = {'uuid': uuid};
    map["value"] = value;
    if (hydratedObject != null) {
      map["hydratedObject"] = hydratedObject;
    }

    return map;
  }
}

class AddressData {
  final String address1;
  final String address2;
  final String address3;
  final String cityVillage;
  final String countyDistrict;
  final String stateProvince;

  AddressData({this.address1, this.address2, this.address3,
    this.cityVillage, this.countyDistrict, this.stateProvince});

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['address1'] = address1;
    map['address2'] = address2;
    map['address3'] = address3;
    map['cityVillage'] = cityVillage;
    map['countyDistrict'] = countyDistrict;
    map['stateProvince'] = stateProvince;

    return map;
  }
}

class PatientIds {
  final String uuid, patientId, nationalId;

  PatientIds({
    @required this.uuid,
    @required this.patientId,
    @required this.nationalId,
  });

  factory PatientIds.fromJson(Map<String, dynamic> jsonMap) {

    Map identifiers = Map();
    for (Map attr in jsonMap['patient']['identifiers']) {
      String key = attr['identifierType']['uuid'];
      String value = attr['identifier'];
      identifiers[key] = value;
    }
    
    return PatientIds(
        uuid: jsonMap['patient']['uuid'],
        patientId: identifiers[UUID_MAP['patientIdentifier']],
        nationalId: identifiers[UUID_MAP['nationalIdentifier']],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['uuid'] = uuid;
    map['pid'] = patientId;
    map['nid'] = nationalId;

    return map;
  }
}
