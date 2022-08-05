import 'package:uuid/uuid.dart';

const uuid = Uuid();

class IdGenerator {
  String newId() {
    return uuid.v4();
  }
}
