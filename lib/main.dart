import 'package:fin/controllers/category_controller.dart';
import 'package:fin/controllers/offer_controller.dart';
import 'package:fin/controllers/sub_category_controller.dart';
import 'package:fin/firebase_options.dart';
import 'package:fin/models/user.dart';
import 'package:fin/screens/you_sell/category/category_form.dart';
import 'package:fin/screens/you_sell/category/category_screen.dart';
import 'package:fin/screens/you_sell/offers/offer_evaluation_screen.dart';
import 'package:fin/screens/you_sell/offers/offers_form.dart';
import 'package:fin/screens/you_sell/offers/offers_screen.dart';
import 'package:fin/screens/you_sell/sub_category/sub_category_form.dart';
import 'package:fin/screens/you_sell/sub_category/sub_category_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:fin/routes.dart';
import 'package:fin/my_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:fin/controllers/auth_controller.dart';
import 'package:fin/controllers/entry_controller.dart';
import 'package:fin/controllers/entrytype_controller.dart';

import 'package:fin/screens/landing_screen.dart';
import 'package:fin/screens/main_screen.dart';
import 'package:fin/screens/screen_not_found.dart';
import 'package:fin/screens/auth/auth_screen.dart';
import 'package:fin/screens/auth/user_data_screen.dart';
import 'package:fin/screens/fin/entrytype/entrytype_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }

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
          create: (_) => EntryTypeController(User(), []),
          // em caso de update deve enviar os dados de ayth mais uma versão anterior dos dados
          update: (ctx, authController, previous) {
            return EntryTypeController(
              authController.currentUser,
              previous?.entryTypeList ?? [],
            );
          },
        ),
        ChangeNotifierProxyProvider<AuthController, EntryController>(
          create: (_) => EntryController(User(), []),
          update: (ctx, authController, previous) {
            return EntryController(authController.currentUser, previous?.entryList ?? []);
          },
        ),
        ChangeNotifierProxyProvider<AuthController, CategoryController>(
          create: (_) => CategoryController(User(), []),
          update: (ctx, authController, previous) {
            return CategoryController(authController.currentUser, previous?.categoryList ?? []);
          },
        ),
        ChangeNotifierProxyProvider<AuthController, SubCategoryController>(
          create: (_) => SubCategoryController(User(), []),
          update: (ctx, authController, previous) {
            return SubCategoryController(authController.currentUser, previous?.subCategoryList ?? []);
          },
        ),
        ChangeNotifierProxyProvider<AuthController, OfferController>(
          create: (_) => OfferController(User(), []),
          update: (ctx, authController, previous) {
            return OfferController(authController.currentUser, previous?.offerList ?? []);
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [
          Locale('pt', 'BR'), // English
        ],
        title: 'Fin',
        theme: MyTheme.theme,
        routes: {
          Routes.landingScreen: (ctx) => const LandingScreen(),
          Routes.authScreen: (ctx) => const AuthScreen(screenMode: ScreenMode.signIn),
          Routes.mainScreen: (ctx) => const MainScreen(),
          Routes.userDataScreen: (ctx) => const UserDataScreen(),
          Routes.entryTypeScreen: (ctx) => const EntryTypeScreen(),
          Routes.categoryScreen: (ctx) => const CategoryScreen(),
          Routes.categoryForm: (ctx) => const CategoryForm(),
          Routes.subCategoryScreen: (ctx) => const SubCategoryScreen(),
          Routes.subCategoryForm: (ctx) => const SubCategoryForm(),
          Routes.offersScreen: (ctx) => const OffersScreen(),
          Routes.offersForm: (ctx) => const OffersForm(),
          Routes.offersEvaluationScreen: (ctx) => const OffersEvaluationScreen(),
        },
        initialRoute: Routes.landingScreen,
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
