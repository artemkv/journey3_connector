import 'package:path_provider/path_provider.dart';

import 'dart:convert';
import 'dart:io';
import 'dateutil.dart';
import 'domain.dart';

const sessionFileName = 'journey.session.json';

class Persistence {
  Future<Session?> loadLastSession() async {
    final path = await getApplicationSupportDirectory();
    final file = File('${path.path}/$sessionFileName');
    if (!await file.exists()) {
      return null;
    }

    final jsonString = await file.readAsString();
    final json = jsonDecode(jsonString);
    final session = Session.fromJson(json, Timeline());
    return session;
  }

  Future<void> saveSession(Session session) async {
    final path = await getApplicationSupportDirectory();
    final file = File('${path.path}/$sessionFileName');
    final json = session.toJson();
    final jsonString = jsonEncode(json);
    await file.writeAsString(jsonString);
  }

// Only for debugging
  Future<void> removeSession() async {
    final path = await getApplicationSupportDirectory();
    final file = File('${path.path}/$sessionFileName');
    await file.delete();
  }
}
