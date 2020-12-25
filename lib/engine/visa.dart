import 'package:visa/auth-data.dart';

import 'simple-auth.dart';

/// Visa interface
abstract class Visa {
  /// a [SimpleAuth] instance
  SimpleAuth visa;

  /// This function combines information
  /// from the user [json] and auth response [data]
  /// to build an [AuthData] object.
  AuthData authData(Map<String, dynamic> json, Map<String, String> data);
}
