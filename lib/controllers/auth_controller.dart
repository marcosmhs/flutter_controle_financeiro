import 'dart:async';

//import 'package:fin/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fin/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/controllers/sharedpreferences_controller.dart';

class AuthController with ChangeNotifier {
  late User _currentUser;

  AuthController() {
    _currentUser = User();
  }

  User get currentUser {
    return _currentUser;
  }

  void logout() async {
    _currentUser = User();
    await SharedPreferencesController.removeValue(key: 'authLoginPassword');
    await SharedPreferencesController.removeValue(key: 'userData');
    await fb_auth.FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  Future<CustomReturn> signIn({required User user, bool saveLogin = false}) async {
    try {
      final credential = await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      if (credential.user != null) {
        final userDataDb = await FirebaseFirestore.instance.collection('finUserData').doc(credential.user!.uid).get();
        final userData = userDataDb.data();

        if (userData != null) {
          _currentUser = User(
            email: credential.user!.email!,
            userId: credential.user!.uid,
            token: await credential.user!.getIdToken(),
            name: userData['name'],
            isAdmin: userData['isAdmin'],
          );
          notifyListeners();
        }
        if (saveLogin) {
          await SharedPreferencesController.setMap(key: 'authLoginPassword', map: {
            'email': user.email,
            'pwd': user.password,
          });

          await SharedPreferencesController.setMap(
            key: 'userData',
            map: {
              'email': currentUser.email,
              'userId': currentUser.userId,
              'name': currentUser.name,
              'token': currentUser.token,
              'isAdmin': currentUser.isAdmin.toString(),
            },
          );
        }
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      return CustomReturn.authSignUpError(e.code);
    } catch (e) {
      return CustomReturn.error(e.toString());
    }

    notifyListeners();
    return CustomReturn.sucess;
  }

  Future<void> tryAutoSignIn() async {
    // se já está autenticado não precisa logar novamente
    if (!currentUser.email.isNotEmpty) {
      final storedUserData = await SharedPreferencesController.getMap(key: 'userData');
      // se os dados estão salvos pode seguir
      if (storedUserData.isNotEmpty) {
        //final localExpiredDate = DateTime.parse(storedUserData['expirationDatetime']);
        // se a data de expiração é anterior à data atual, ou seja, o login não está mais válido
        //if (localExpiredDate.isBefore(DateTime.now())) {
        final authLoginPassword = await SharedPreferencesController.getMap(key: 'authLoginPassword');

        if (authLoginPassword.isNotEmpty) {
          await signIn(
            user: User(email: authLoginPassword['email'], password: authLoginPassword['pwd']),
            saveLogin: true,
          );
        }
      }
    }
  }

  Future<CustomReturn> signUp({required User user}) async {
    try {
      final credential = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      if (credential.user?.uid == null) {
        await FirebaseFirestore.instance.collection('finUserData').doc(credential.user!.uid).set({
          'name': user.name,
          'idAdmin': user.isAdmin,
        });
      }
      return CustomReturn.sucess;
    } on fb_auth.FirebaseException catch (e) {
      return CustomReturn.error(e.code);
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> editUserData({required bool changeEmail, required User userData}) async {
    try {
      var user = fb_auth.FirebaseAuth.instance.currentUser;
      if (changeEmail) {
        await FirebaseFirestore.instance.collection('finUserData').doc(currentUser.userId).update({
          'email': userData.email,
        });

        await user!.updateEmail(userData.email);
        currentUser.email = userData.email;
      }

      await FirebaseFirestore.instance.collection('finUserData').doc(currentUser.userId).set({
        'name': userData.name,
        'isAdmin': currentUser.isAdmin,
      });
      currentUser.name = userData.name;

      if (userData.password != '') {
        await fb_auth.FirebaseAuth.instance.currentUser!.updatePassword(userData.password);
      }
      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }
}
