import 'package:meta/meta.dart';

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