class User {
  late String userId;
  late String email;
  late String password;
  late String token;
  //late DateTime? expirationDatetime;
  late String name;
  late bool isAdmin;

  User({
    this.userId = '',
    this.email = '',
    this.password = '',
    this.token = '',
    //this.expirationDatetime,
    this.name = '',
    this.isAdmin = false,
  });

  //bool get isAuthenticated {
  //  return (expirationDatetime?.isAfter(DateTime.now()) ?? false) && token != '';
  //}
}
