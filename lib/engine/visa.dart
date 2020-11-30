import 'package:visa/auth-data.dart';

import 'simple-auth.dart';

abstract class Visa{
  SimpleAuth visa;

  AuthData authData(
      Map<String, dynamic> json,
      Map<String, String>data
  );
}