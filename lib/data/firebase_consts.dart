class FirebaseConsts {
  static const String firebaseProject = 'redfive-fin';
  static const String apiKey = 'AIzaSyDje_axIcy3MJo7AysInLSTH9Jg8lsU9W0';

  static String userManagemantUrl(String service) {
    return 'https://identitytoolkit.googleapis.com/v1/accounts:$service?key=${FirebaseConsts.apiKey}';
  }

  static String get finUserData {
    return 'https://${FirebaseConsts.firebaseProject}-default-rtdb.firebaseio.com/finUserData';
  }

  static String get entryType {
    return 'https://${FirebaseConsts.firebaseProject}-default-rtdb.firebaseio.com/entryType';
  }

  static String get entry {
    return 'https://${FirebaseConsts.firebaseProject}-default-rtdb.firebaseio.com/entry';
  }

  static String get entryInstallment {
    return 'https://${FirebaseConsts.firebaseProject}-default-rtdb.firebaseio.com/entryInstallment';
  }

  static String get entryPayment {
    return 'https://${FirebaseConsts.firebaseProject}-default-rtdb.firebaseio.com/entryPayment';
  }
}
