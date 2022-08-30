import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:fin/fin_routes.dart';
import 'package:fin/controllers/auth_controller.dart';

class FinDrawer extends StatelessWidget {
  const FinDrawer({Key? key}) : super(key: key);

  Column _option({
    required BuildContext context,
    required Icon icon,
    required String text,
    String defaultRoute = '',
    Function()? onTap,
  }) {
    return Column(
      children: [
        const Divider(height: 0),
        ListTile(
          leading: icon,
          title: Text(text),
          onTap: defaultRoute == ''
              ? onTap
              : () {
                  // fecha o drawer
                  Navigator.of(context).pop();
                  // abre a nova tela
                  Navigator.pushNamed(context, defaultRoute);
                },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Menu'),
            // remove o botão do drawer quando ele está aberto
            automaticallyImplyLeading: true,
          ),
          _option(
            context: context,
            icon: const Icon(Icons.type_specimen),
            text: 'Tipo de lançamento',
            defaultRoute: FinRoutes.entryTypeScreen,
          ),
          const Spacer(),
          _option(
            context: context,
            icon: const Icon(Icons.settings),
            text: 'Configurações',
            defaultRoute: FinRoutes.configScreen,
          ),
          const Divider(),
          _option(
            context: context,
            icon: const Icon(Icons.sync),
            text: 'Sincronização de dados',
            defaultRoute: FinRoutes.syncScreen,
          ),
          const Divider(),
          _option(
            context: context,
            icon: const Icon(Icons.person_sharp),
            text: 'Alterar Dados',
            defaultRoute: FinRoutes.userDataScreen,
          ),
          const Divider(),
          _option(
            context: context,
            icon: const Icon(Icons.exit_to_app_sharp),
            text: 'Sair',
            onTap: () {
              Provider.of<AuthController>(context, listen: false).logout();
              Navigator.restorablePushNamedAndRemoveUntil(
                context,
                FinRoutes.landing,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
