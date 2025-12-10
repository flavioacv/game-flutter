/// A value object representing an email address.
///
/// The email address must be in a valid format, as determined by the regular expression
/// `r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$'`.
class User {
  final String _value;

  const User(this._value);

  bool get hasNoWhitespace => !_value[_value.length - 1].contains(' ');

  String? get isValidUser {
    if (_value.isEmpty) {
      return 'Campo obrigatório';
    } else if (!hasNoWhitespace) {
      return 'A user não deve ter espaços em branco no final';
    } else if (_value.length > 20) {
      return 'A user deve ter no maximo 20 caracteres';
    } else {
      return null;
    }
  }

  bool get isValid {
    return _value.isNotEmpty && _value.length <= 20 && hasNoWhitespace;
  }

  @override
  String toString() => _value;
}