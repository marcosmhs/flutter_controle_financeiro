class FirebaseUser {
  late String userId;
  late String email;
  late String password;
  late String token;
  late DateTime? expirationDatetime;

  FirebaseUser({
    this.userId = '',
    this.email = '',
    this.password = '',
    this.expirationDatetime,
    this.token = '',
  });

  bool get isAuthenticated {
    return (expirationDatetime?.isAfter(DateTime.now()) ?? false) && token != '';
  }
}

class LocalUser {
  late String localId;
  late String name;
  late bool isAdmin;
}

class User extends FirebaseUser with LocalUser {}
