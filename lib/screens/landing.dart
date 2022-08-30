import 'package:fin/screens/auth/auth_screen.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:fin/controllers/auth_controller.dart';
import 'package:fin/screens/inicial_screen.dart';

class Landing extends StatelessWidget {
  const Landing({Key? key}) : super(key: key);

  Widget _autoLogin() {
    
    return const AuthScreen(screenMode: ScreenMode.signIn);
  }

  @override
  Widget build(BuildContext context) {
    AuthController authController = Provider.of(context);
    return FutureBuilder(
      future: authController.tryAutoSignIn(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.error != null) {
          return const Center(child: Text('erro'));
        } else {
          return authController.currentUserData.isAuthenticated == false
              ? _autoLogin()
              : const InicialScreen();
        }
      },
    );
  }
}
