import 'dart:convert';

import 'package:hikma_health/database/database_helper.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import '../constants.dart';
import 'network_calls.dart';

UserRepository userRepository;

executeJob(String auth, job, DatabaseHelper dbHelper) async {

  final int jobId = await job['job_id'];

  if (jobId == JOB_CREATE_PATIENT) {
    Map dataMap = json.decode(job['data']);
    PatientIds patientIds = await createPatient(auth: auth, body: dataMap);

    print(job);

    if (patientIds != null) {
      await dbHelper.updateLocalPatientIds(job['record_id'], patientIds);
      await dbHelper.removeFromJobQueue(job['id']);

      String idString = job['id'].toString();
      print('removed job $idString');
    }
  }
}