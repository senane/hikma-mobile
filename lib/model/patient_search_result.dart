class PatientSearchResult {
  final String uuid;
  final String id;
  final String name;

  PatientSearchResult.fromJson(Map jsonMap)
      : uuid = jsonMap['uuid'],
        id = jsonMap['identifier'],
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
