// ignore: depend_on_referenced_packages
import 'package:nanoid/nanoid.dart';

class UidGenerator {
  static String get confirmId {
    return customAlphabet('abcdefghijklmnopqrstuwyxz', 5);
  }

  static String get localStorageUid {
    return 'localstorage-${nanoid(10)}';
  }

  static String get firebaseLocalUid {
    return 'fb-local-${nanoid(13)}';
  }
}
