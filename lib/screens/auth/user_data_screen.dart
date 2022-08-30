import 'package:fin/components/fin_scafold.dart';
import 'package:fin/screens/auth/signon_component.dart';
import 'package:flutter/material.dart';

class UserDataScreen extends StatefulWidget {
  const UserDataScreen({Key? key}) : super(key: key);

  @override
  State<UserDataScreen> createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  @override
  Widget build(BuildContext context) {
    return const FinScafold(
      title: 'Alterar seus dados',
      showAppDrawer: false,
      body: SignOnComponent(screenMode: Mode.editData),
    );
  }
}
