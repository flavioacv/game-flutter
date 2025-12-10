import 'package:pixel_adventure/core/value_validation/validators.dart';

/// A value object representing an email address.
///
/// The email address must be in a valid format, as determined by the regular expression
/// `r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$'`.
class Email {
  final String _value;

  const Email(this._value);

  bool get hasNoWhitespace => !_value[_value.length - 1].contains(' ');

  String? get isValidEmail {
    if (_value.isEmpty) {
      return 'Campo obrigatório';
    } else if (!Validators().isEmail(_value)) {
      return 'O Email é invalido ';
    } else {
      return null;
    }
  }

  bool get isValid {
    return _value.isNotEmpty && Validators().isEmail(_value);
  }

  @override
  String toString() => _value;
}
