enum ReturnType { error, sucess, info }

class CustomReturn {
  final ReturnType returnType;
  final String message;
  final int returnCode;

  CustomReturn({
    required this.returnType,
    required this.message,
    this.returnCode = 0,
  });

  static CustomReturn get unauthorizedError {
    return CustomReturn(
      returnType: ReturnType.error,
      message: 'Sem autorização de acesso',
      returnCode: 401,
    );
  }

  static CustomReturn get offline {
    return CustomReturn(
      returnType: ReturnType.error,
      message: 'Sem conexão com internet',
      returnCode: 0,
    );
  }

  static CustomReturn httpError({int? errorCode}) {
    return CustomReturn(
      returnType: ReturnType.error,
      message: 'Erro HTTP',
      returnCode: errorCode ?? 0,
    );
  }

  static CustomReturn authSignUpError(String error) {
    Map<String, String> authErrors = {
      'EMAIL_EXISTS': 'E-mail já existe',
      'OPERATION_NOT_ALLOWED': 'Erro interno, acesso por e-mail e senha desativado',
      'USER_DISABLED': 'Usuário desativado',
      'INVALID_PASSWORD': 'Senha inválida',
      'INVALID_EMAIL': 'E-mail inválido',
      'EMAIL_NOT_FOUND': 'E-mail não encontrado'
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
