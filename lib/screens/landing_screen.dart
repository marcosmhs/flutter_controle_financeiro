import 'package:fin/screens/auth/auth_screen.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:fin/controllers/auth_controller.dart';
import 'package:fin/screens/main_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

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
          return Scaffold(
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Fatal error!'),
                  const SizedBox(height: 20),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          );
        } else {
          return authController.currentUser.email == '' ? _autoLogin() : const MainScreen();
        }
      },
    );
  }
}
