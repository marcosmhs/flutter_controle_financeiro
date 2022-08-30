import 'package:fin/screens/auth/signin_component.dart';
import 'package:fin/screens/auth/signon_component.dart';
import 'package:flutter/material.dart';

enum ScreenMode { signIn, signOn }

class AuthScreen extends StatefulWidget {
  final ScreenMode screenMode;
  const AuthScreen({Key? key, required this.screenMode}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final sm = ModalRoute.of(context)?.settings.arguments;
    ScreenMode localScreenMode;

    if (sm == null) {
      localScreenMode = widget.screenMode;
    } else {
      localScreenMode = sm as ScreenMode;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Image.asset(
              'assets/images/logo.png',
              height: 100,
              width: 200,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: localScreenMode == ScreenMode.signIn ? const SignInComponent() : const SignOnComponent(screenMode: Mode.newUser),
            ),
          )
        ],
      ),
    );
  }
}
