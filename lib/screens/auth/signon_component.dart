import 'package:fin/components/util/custom_textFormField.dart';
import 'package:fin/components/util/custom_dialog.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/controllers/auth_controller.dart';
import 'package:fin/fin_routes.dart';
import 'package:fin/screens/auth/auth_screen.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

enum Mode { newUser, editData }

class SignOnComponent extends StatefulWidget {
  final Mode screenMode;
  const SignOnComponent({Key? key, required this.screenMode}) : super(key: key);

  @override
  State<SignOnComponent> createState() => _SignOnComponentState();
}

class _SignOnComponentState extends State<SignOnComponent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _changeEmail = false;

  final Map<String, String> _formData = {
    'email': '',
    'password': '',
    'name': '',
  };

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
        if (widget.screenMode == Mode.newUser) {
          retorno = await authController.signUp(
            email: _formData['email']!,
            password: _formData['password']!,
            name: _formData['name']!,
          );
          if (retorno.returnType == ReturnType.sucess) {
            // ignore: use_build_context_synchronously
            Navigator.restorablePushNamedAndRemoveUntil(
              context,
              FinRoutes.landing,
              (route) => false,
            );
            CustomMessage(
              context: context,
              messageText: 'Login criado com sucesso',
              messageType: MessageType.sucess,
            );
          }
        } else {
          retorno = await authController.editUserData(
            changeEmail: _changeEmail,
            email: _formData['email']!,
            password: _formData['password']!,
            name: _formData['name']!,
          );
          if (retorno.returnType == ReturnType.sucess) {
            // ignore: use_build_context_synchronously
            CustomMessage(
              context: context,
              messageText: 'Dados alterados com sucesso',
              messageType: MessageType.sucess,
              durationInSeconds: 3,
            );
            if (!_changeEmail) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop(); // fecha a tela
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop(); // fecha o drawer
            } else {
              // ignore: use_build_context_synchronously
              Provider.of<AuthController>(context, listen: false).logout();
              // ignore: use_build_context_synchronously
              Navigator.restorablePushNamedAndRemoveUntil(
                context,
                FinRoutes.landing,
                (route) => false,
              );
            }
          }
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
    if (widget.screenMode == Mode.editData) {
      var authData = Provider.of<AuthController>(context, listen: false).currentUserData;
      _emailController.text = authData.email ?? '';
      _nameController.text = authData.name ?? '';
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (widget.screenMode == Mode.newUser) const SizedBox(height: 10),
            if (widget.screenMode == Mode.newUser)
              const Text('Fin', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            if (widget.screenMode == Mode.editData)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Switch.adaptive(
                    value: _changeEmail,
                    onChanged: (value) {
                      setState(() {
                        if (value) {
                          CustomDialog(context: context).informationDialog(
                            message: 'Se alterar seu e-mail será necessário fazer refazer o login',
                          );
                        }
                        _changeEmail = value;
                      });
                    },
                  ),
                  const Text("Alterar e-mail"),
                ],
              ),
            // email
            CustomTextEdit(
              enabled: _changeEmail || widget.screenMode == Mode.newUser,
              context: context,
              controller: _emailController,
              labelText: 'E-mail',
              hintText: 'Informe seu e-mail',
              onSave: (value) => _formData['email'] = value ?? '',
              prefixIcon: Icons.mail,
              keyboardType: TextInputType.emailAddress,
              nextFocusNode: _passwordFocus,
              validator: (value) {
                final finalValue = value ?? '';
                if (finalValue.trim().isEmpty) return 'Informe o e-mail';
                if (!finalValue.contains('@') || !finalValue.contains('.')) return 'Informe um e-mail válido';
                return null;
              },
            ),
            // senha
            CustomTextEdit(
              context: context,
              controller: _passwordController,
              labelText: 'Senha',
              hintText: 'Informe sua senha',
              isPassword: true,
              onSave: (value) => _formData['password'] = value ?? '',
              prefixIcon: Icons.lock,
              textInputAction: TextInputAction.next,
              focusNode: _passwordFocus,
              nextFocusNode: _confirmPasswordFocus,
              validator: (value) {
                final finalValue = value ?? '';
                if (widget.screenMode == Mode.newUser) {
                  if (finalValue.trim().isEmpty) return 'Informe a senha';
                  if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                  if (finalValue != _confirmPasswordController.text) return 'As senhas digitadas não são iguais';
                } else {
                  if (finalValue.trim().isNotEmpty && _confirmPasswordController.text.isNotEmpty) {
                    if (finalValue.trim().isEmpty) return 'Informe a senha';
                    if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                    if (finalValue != _confirmPasswordController.text) return 'As senhas digitadas não são iguais';
                  }
                }
                return null;
              },
            ),
            // confirmar senha
            CustomTextEdit(
              context: context,
              controller: _confirmPasswordController,
              labelText: 'Repita a senha',
              hintText: 'Informe sua senha novamente',
              isPassword: true,
              prefixIcon: Icons.lock,
              textInputAction: TextInputAction.next,
              focusNode: _confirmPasswordFocus,
              nextFocusNode: _nameFocus,
              validator: (value) {
                final finalValue = value ?? '';
                if (widget.screenMode == Mode.newUser) {
                  if (finalValue.trim().isEmpty) return 'Informe a senha';
                  if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                  if (finalValue != _passwordController.text) return 'As senhas digitadas não são iguais';
                } else {
                  if (finalValue.trim().isNotEmpty && _passwordController.text.isNotEmpty) {
                    if (finalValue.trim().isEmpty) return 'Informe a senha';
                    if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                    if (finalValue != _passwordController.text) return 'As senhas digitadas não são iguais';
                  }
                }
                return null;
              },
            ),
            // nome
            CustomTextEdit(
              context: context,
              controller: _nameController,
              labelText: 'Nome',
              hintText: 'Informe seu nome completo',
              onSave: (value) => _formData['name'] = value ?? '',
              prefixIcon: Icons.person,
              textInputAction: TextInputAction.next,
              focusNode: _nameFocus,
              validator: (value) {
                final finalValue = value ?? '';
                if (finalValue.trim().isEmpty) return 'O nome deve ser informado';
                return null;
              },
            ),
            _isLoading
                ? const CircularProgressIndicator.adaptive()
                // botão login
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text('Enviar dados'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // criar nova conta
                      ElevatedButton(
                        onPressed: () {
                          if (widget.screenMode == Mode.newUser) {
                            Navigator.of(context).pushNamed(
                              FinRoutes.authScreen,
                              arguments: ScreenMode.signIn,
                            );
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).disabledColor)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Text('Cancelar'),
                        ),
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
