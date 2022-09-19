import 'dart:async';
import 'dart:convert';

//import 'package:fin/models/user.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/data/firebase_consts.dart';
import 'package:fin/controllers/sharedpreferences_controller.dart';

class AuthData {
  late String? _token;
  late String? _email;
  late String _userId;
  late String _name;
  late bool _admin;
  late DateTime? _expirationDatetime;

  AuthData({
    String email = '',
    String userId = '',
    String name = '',
    DateTime? expirationDatetime,
    String token = '',
    bool admin = false,
  }) {
    _token = token;
    _email = email;
    _userId = userId;
    _name = name;
    _expirationDatetime = expirationDatetime;
    _admin = admin;
  }

  static AuthData emptyData() {
    return AuthData(email: '', userId: '', token: '', name: '');
  }

  bool get isAuthenticated {
    return (_expirationDatetime?.isAfter(DateTime.now()) ?? false) && _token != '';
  }

  bool get admin {
    return isAuthenticated ? _admin : false;
  }

  String? get token {
    return isAuthenticated ? _token : '';
  }

  String? get email {
    return isAuthenticated ? _email : '';
  }

  String? get userId {
    return isAuthenticated ? _userId : '';
  }

  String? get name {
    return isAuthenticated ? _name : '';
  }

  DateTime? get expirationDatetime {
    return isAuthenticated ? _expirationDatetime : null;
  }
}

class AuthController with ChangeNotifier {
  late AuthData _currentUserData = AuthData.emptyData();

  AuthData get currentUserData {
    return _currentUserData;
  }

  void logout() {
    _currentUserData = AuthData.emptyData();
    SharedPreferencesController.removeValue(key: 'authLoginPassword').then((value) {
      SharedPreferencesController.removeValue(key: 'authData').then((_) {
        notifyListeners();
      });
    });
  }

  // este método centraliza a conexão com o firebase, alternando o trecho que representa o serviço acessado
  Future<Response> _connectFirebase({required String email, required String password, required String service}) async {
    final url = FirebaseConsts.userManagemantUrl(service);
    return await post(
      Uri.parse(url),
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
  }

  Future<CustomReturn> signIn({required String email, required String password, bool saveLogin = false}) async {
    final response = await _connectFirebase(email: email, password: password, service: 'signInWithPassword');

    if (response.statusCode >= 400) {
      if (response.statusCode == 404) {
        return CustomReturn(returnType: ReturnType.error, message: 'O serviço de login não foi encontrado');
      } else {
        return CustomReturn.authSignUpError(jsonDecode(response.body)['error']['message']);
      }
    }

    final body = jsonDecode(response.body);

    final userDataResponse = await get(
      //url/id_usuario/id_produto.json
      Uri.parse('${FirebaseConsts.finUserData}/${body['localId']}.json?auth=${body['idToken']}'),
    );

    _currentUserData = AuthData(
        email: body['email'],
        userId: body['localId'],
        name: userDataResponse.body == 'null' ? {} : jsonDecode(userDataResponse.body)['name'],
        expirationDatetime: DateTime.now().add(Duration(seconds: int.tryParse(body['expiresIn']) ?? 0)),
        token: body['idToken']);

    if (saveLogin) {
      SharedPreferencesController.saveMap(key: 'authLoginPassword', map: {
        'email': email,
        'pwd': password,
      });
      SharedPreferencesController.saveMap(
        key: 'authData',
        map: {
          'email': _currentUserData.email,
          'userId': _currentUserData.userId,
          'name': _currentUserData.name,
          'expirationDatetime': _currentUserData.expirationDatetime!.toIso8601String(),
          'token': _currentUserData.token
        },
      );
    }

    notifyListeners();
    return CustomReturn.sucess;
  }

  Future<void> tryAutoSignIn() async {
    // se já está autenticado não precisa logar novamente
    if (!_currentUserData.isAuthenticated) {
      final storedAuthData = await SharedPreferencesController.loadMap(key: 'authData');
      // se os dados estão salvos pode seguir
      if (storedAuthData.isNotEmpty) {
        final localExpiredDate = DateTime.parse(storedAuthData['expirationDatetime']);
        // se a data de expiração é anterior à data atual, ou seja, o login não está mais válido
        if (localExpiredDate.isBefore(DateTime.now())) {
          final authLoginPassword = await SharedPreferencesController.loadMap(key: 'authLoginPassword');
          if (authLoginPassword.isNotEmpty) {
            await signIn(email: authLoginPassword['email'], password: authLoginPassword['pwd'], saveLogin: true);
          }
        } else {
          // recria o objeto de autenticação
          _currentUserData = AuthData(
            email: storedAuthData['email'],
            userId: storedAuthData['userId'],
            name: storedAuthData['name'],
            expirationDatetime: localExpiredDate,
            token: storedAuthData['token'],
          );
        }
      }
    }
  }

  Future<CustomReturn> signUp({required String email, required String password, required String name}) async {
    final responseEmail = await _connectFirebase(email: email, password: password, service: 'signUp');

    if (responseEmail.statusCode >= 400) {
      if (responseEmail.statusCode == 404) {
        return CustomReturn(returnType: ReturnType.error, message: 'O serviço de login não foi encontrado');
      } else {
        return CustomReturn.authSignUpError(jsonDecode(responseEmail.body)['error']['message']);
      }
    }

    final body = jsonDecode(responseEmail.body);

    final responseUser = await put(
      // http.post
      Uri.parse('${FirebaseConsts.finUserData}/${body['localId']}.json/?auth=${body['idToken']}'),
      // Id fica em branco pois será gerado no banco
      body: jsonEncode({'name': name}),
    );

    if (responseUser.statusCode >= 400) {
      if (responseUser.statusCode == 404) {
        return CustomReturn(returnType: ReturnType.error, message: 'Erro ao gravar os dados do usuário');
      } else {
        return CustomReturn.authSignUpError(jsonDecode(responseUser.body)['error']['message']);
      }
    }

    return CustomReturn.sucess;
  }

  Future<CustomReturn> editUserData({
    required bool changeEmail,
    required String email,
    String password = '',
    required String name,
  }) async {
    final userManagemantUrl = FirebaseConsts.userManagemantUrl('update');
    Response response;
    if (changeEmail) {
      response = await post(
        Uri.parse(userManagemantUrl),
        body: jsonEncode({
          'idToken': _currentUserData._token,
          'email': email,
          'returnSecureToken': true,
        }),
      );

      if (response.statusCode >= 400) {
        if (response.statusCode == 404) {
          return CustomReturn(returnType: ReturnType.error, message: 'Erro ao gravar os dados do usuário');
        } else {
          return CustomReturn.changeUserError(jsonDecode(response.body)['error']['message']);
        }
      }
      // uma vez que não foram encontrados erros, podemos alterar os dados gerais
      _currentUserData._email = email;
    }

    if (password != '') {
      response = await post(
        Uri.parse(userManagemantUrl),
        body: jsonEncode({
          'idToken': _currentUserData._token,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      if (response.statusCode >= 400) {
        if (response.statusCode == 404) {
          return CustomReturn(returnType: ReturnType.error, message: 'Erro ao gravar os dados do usuário');
        } else {
          return CustomReturn.changeUserError(jsonDecode(response.body)['error']['message']);
        }
      }
    }

    if (name != _currentUserData._name) {
      final response = await put(
        Uri.parse('${FirebaseConsts.finUserData}/${currentUserData.userId}.json?auth=${currentUserData.token}'),
        body: jsonEncode({'name': name}),
      );
      if (response.statusCode >= 400) {
        if (response.statusCode == 404) {
          return CustomReturn(returnType: ReturnType.error, message: 'Erro ao gravar os dados do usuário');
        } else {
          return CustomReturn.authSignUpError(jsonDecode(response.body)['error']['message']);
        }
      }
      // uma vez que não foram encontrados erros, podemos alterar os dados gerais
      _currentUserData._name = name;
    }

    notifyListeners();
    return CustomReturn.sucess;
  }
}
