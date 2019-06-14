import 'dart:convert';
import 'package:meta/meta.dart';
import 'database_helper.dart';

final DatabaseHelper dbHelper = DatabaseHelper.instance;

Future<String> queueJob({@required auth, @required Map body}) async {
  var data = json.encode(body).replaceAll('"null"', 'null');
  await dbHelper.insertToJobQueue(data, 1);
  await dbHelper.insertToPatients(body);
  return data;
}