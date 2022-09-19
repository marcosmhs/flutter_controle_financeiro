import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:fin/routes.dart';
import 'package:fin/controllers/auth_controller.dart';

class YouStoreDrawer extends StatelessWidget {
  const YouStoreDrawer({
    Key? key,
  }) : super(key: key);

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
            title: const Text('You Store Menu'),
            // remove o botão do drawer quando ele está aberto
            automaticallyImplyLeading: true,
          ),
          _option(
            context: context,
            icon: const Icon(Icons.sell),
            text: 'Anunciar um produto',
            defaultRoute: Routes.sellItemsScreen,
          ),
          const Spacer(),
          _option(
            context: context,
            icon: const Icon(Icons.settings),
            text: 'Configurações',
            defaultRoute: Routes.configScreen,
          ),
          const Divider(),
          _option(
            context: context,
            icon: const Icon(Icons.person_sharp),
            text: 'Alterar Dados',
            defaultRoute: Routes.userDataScreen,
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
                Routes.landingScreen,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
