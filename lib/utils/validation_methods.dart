import 'package:email_validator/email_validator.dart';

class ValidationMethods {
  static bool isEmailValid(String email) => EmailValidator.validate(email);

  static bool isPasswordValid(String password) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }
}
