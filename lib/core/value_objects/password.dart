/// Value object representing a password.
class Password {
  final String _value;

  const Password(this._value);

  bool get hasSpecialDigit => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(_value);

  bool get hasNoWhitespace => !_value[_value.length - 1].contains(' ');

  String? get isValidPassword {
    if (_value.length < 2) {
      return 'A senha deve ter no mínimo 2 caracteres';
    } else if (!hasSpecialDigit) {
      return 'A senha não pode ter caracteres especiais';
    } else if (!hasNoWhitespace) {
      return 'A senha não deve ter espaços em branco';
    } else if (_value.length > 20) {
      return 'A senha deve ter no maximo 20 caracteres';
    } else {
      return null;
    }
  }

  bool get isValid {
    return _value.length >= 2 &&
        _value.length <= 20 &&
        hasSpecialDigit &&
        hasNoWhitespace;
  }

  @override
  String toString() => _value;
}