import 'package:fin/components/util/custom_textFormField.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/models/user.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:fin/controllers/auth_controller.dart';
import 'package:fin/routes.dart';
import 'package:fin/screens/auth/auth_screen.dart';

enum TextFieldType { email, password }

class SignInComponent extends StatefulWidget {
  const SignInComponent({Key? key}) : super(key: key);

  @override
  State<SignInComponent> createState() => _SignInComponentState();
}

class _SignInComponentState extends State<SignInComponent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  late String _email = '';
  late String _password = '';
  late bool _saveLogin = true;

  // utilizado para o controle de foco
  final _passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    setState(() => _isLoading = true);
    if (!(_formKey.currentState?.validate() ?? true)) {
      setState(() => _isLoading = false);
    } else {
      // salva os dados
      _formKey.currentState?.save();
      AuthController authController = Provider.of(context, listen: false);
      CustomReturn retorno;
      try {
        User user = User();
        user.email = _email;
        user.password = _password;
        retorno = await authController.signIn(
          user: user,
          saveLogin: _saveLogin,
        );
        if (retorno.returnType == ReturnType.sucess) {
          // ignore: use_build_context_synchronously
          Navigator.restorablePushNamedAndRemoveUntil(
            context,
            Routes.mainScreen,
            (route) => false,
          );
        }
        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == ReturnType.error) {
          CustomMessage(
            context: context,
            messageText: retorno.message,
            messageType: MessageType.error,
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text('Fin', style: Theme.of(context).textTheme.displayMedium),
          CustomTextEdit(
              context: context,
              controller: _emailController,
              labelText: 'E-mail',
              hintText: 'Informe seu e-mail',
              onSave: (value) => _email = value ?? '',
              prefixIcon: Icons.mail,
              nextFocusNode: _passwordFocus,
              validator: (value) {
                final finalValue = value ?? '';
                if (finalValue.trim().isEmpty) return 'Informe o e-mail';
                if (!finalValue.contains('@') || !finalValue.contains('.')) return 'Informe um e-mail válido';
                return null;
              }),
          CustomTextEdit(
            context: context,
            controller: _passwordController,
            labelText: 'Senha',
            hintText: 'Informe sua senha',
            isPassword: true,
            onSave: (value) => _password = value ?? '',
            prefixIcon: Icons.lock,
            textInputAction: TextInputAction.done,
            focusNode: _passwordFocus,
            validator: (value) {
              final finalValue = value ?? '';
              if (finalValue.trim().isEmpty) return 'Informe a senha';
              if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator.adaptive()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // botão login
                    TextButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.lock_open),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text(
                          'Entrar',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // criar nova conta
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.authScreen, arguments: ScreenMode.signOn),
                      //style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary)),
                      icon: const Icon(Icons.account_box),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Text('Criar Conta', style: Theme.of(context).textTheme.headline6),
                      ),
                    ),
                  ],
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Switch.adaptive(
                value: _saveLogin,
                onChanged: (value) {
                  setState(() {
                    _saveLogin = value;
                  });
                },
              ),
              const Text("Salvar dados de login"),
            ],
          ),
        ],
      ),
    );
  }
}
