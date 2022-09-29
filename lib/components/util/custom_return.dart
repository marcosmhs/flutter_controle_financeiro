// ignore: depend_on_referenced_packages
import 'package:http/http.dart';

enum ReturnType { error, sucess, info }

class CustomReturn {
  final ReturnType returnType;
  final String message;
  final String returnCode;

  CustomReturn({
    required this.returnType,
    required this.message,
    this.returnCode = '0',
  });

  static CustomReturn get unauthorizedError {
    return CustomReturn(
      returnType: ReturnType.error,
      message: 'Sem autorização de acesso',
      returnCode: '401',
    );
  }

  static CustomReturn error(String message) {
    return CustomReturn(
      returnType: ReturnType.error,
      message: message,
    );
  }

  static CustomReturn get offline {
    return CustomReturn(
      returnType: ReturnType.error,
      message: 'Sem conexão com internet',
      returnCode: '0',
    );
  }

  static CustomReturn? httpResponseError({required Response response}) {
    if (response.statusCode >= 400) {
      return CustomReturn(
        returnType: ReturnType.error,
        message: 'Erro HTTP',
        returnCode: response.statusCode.toString(),
      );
    }

    if (response.body == 'null') {
      return CustomReturn(returnType: ReturnType.error, message: 'Sem retorno do Firebase');
    }

    return null;
  }

  static CustomReturn authSignUpError(String error) {
    Map<String, String> authErrors = {
      'EMAIL_EXISTS': 'E-mail já existe',
      'OPERATION_NOT_ALLOWED': 'Erro interno, acesso por e-mail e senha desativado',
      'USER_DISABLED': 'Usuário desativado',
      'INVALID_PASSWORD': 'Senha inválida',
      'INVALID_EMAIL': 'E-mail inválido',
      'EMAIL_NOT_FOUND': 'E-mail não encontrado',
      'weak-password': 'Senha inválida - muito fraca',
      'email-already-in-use': 'E-mail já existe',
      'operation-not-allowed': 'Operação não permitida',
      'invalid-email': 'E-mail inválido',
      'user-disabled': 'Usuário desativado',
      'user-not-found': 'Usuário não encontrado',
      'wrong-password': 'Senha incorreta',
    };
    if (authErrors[error] == null) {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro não tratado: $error');
    } else {
      return CustomReturn(returnType: ReturnType.error, message: authErrors[error] ?? '');
    }
  }

  static CustomReturn changeUserError(String error) {
    Map<String, String> authErrors = {
      'EMAIL_EXISTS': 'O e-mail informado já está em uso',
      'INVALID_ID_TOKEN': 'Erro interno, token inválido',
      'WEAK_PASSWORD': 'A senha deve ter 6 ou mais caracteres',
    };
    if (authErrors[error] == null) {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro não tratado: $error');
    } else {
      return CustomReturn(returnType: ReturnType.error, message: authErrors[error] ?? '');
    }
  }

  static CustomReturn get sucess {
    return CustomReturn(
      returnType: ReturnType.sucess,
      message: 'Sucesso',
    );
  }
}
