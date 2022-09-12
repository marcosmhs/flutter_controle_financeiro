import 'package:fin/my_theme.dart';
import 'package:flutter/material.dart';

import 'package:fin/controllers/auth_controller.dart';
import 'package:fin/controllers/entry_controller.dart';
import 'package:fin/controllers/entrytype_controller.dart';
import 'package:fin/screens/landing.dart';

import 'package:fin/screens/screen_not_found.dart';
import 'package:fin/screens/auth/auth_screen.dart';
import 'package:fin/screens/auth/user_data_screen.dart';
import 'package:fin/screens/entrytype/entrytype_screen.dart';
import 'package:fin/screens/inicial_screen.dart';

// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:fin/fin_routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProxyProvider<AuthController, EntryTypeController>(
          // inicializa o controller com token em branco e lista de produtos vazia
          create: (_) => EntryTypeController(AuthData.emptyData(), []),
          // em caso de update deve enviar os dados de ayth mais uma versão anterior dos dados
          update: (ctx, authController, previous) {
            return EntryTypeController(
              authController.currentUserData,
              previous?.entryTypeList ?? [],
            );
          },
        ),
        ChangeNotifierProxyProvider<AuthController, EntryController>(
          // inicializa o controller com token em branco e lista de produtos vazia
          create: (_) => EntryController(AuthData.emptyData(), []),
          // em caso de update deve enviar os dados de ayth mais uma versão anterior dos dados
          update: (ctx, authController, previous) {
            return EntryController(
              authController.currentUserData,
              previous?.entryList ?? [],
            );
          },
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [
          Locale('pt', 'BR'), // English
        ],
        title: 'Fin',
        theme: MyTheme.theme,
        routes: {
          FinRoutes.landing: (ctx) => const Landing(),
          FinRoutes.authScreen: (ctx) => const AuthScreen(screenMode: ScreenMode.signIn),
          FinRoutes.inicialScreen: (ctx) => const InicialScreen(),
          FinRoutes.userDataScreen: (ctx) => const UserDataScreen(),
          FinRoutes.entryTypeScreen: (ctx) => const EntryTypeScreen(),
        },
        initialRoute: FinRoutes.landing,
        // Executado quando uma tela não é encontrada
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (_) {
            return ScreenNotFound(settings.name.toString());
          });
        },
      ),
    );
  }
}
