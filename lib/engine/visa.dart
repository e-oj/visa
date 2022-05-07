import 'package:visa/auth-data.dart';

import 'simple-auth.dart';

/// Visa abstract class
abstract class Visa {
  /// a [SimpleAuth] instance
  late SimpleAuth visa;

  /// Debug mode?
  bool debugMode = false;

  /// Sets debugMode and visa.debugMode
  /// to the given value (debugMode)
  set debug(bool debugMode) {
    this.debugMode = debugMode;
    this.visa.debugMode = debugMode;
  }

  /// This function combines information
  /// from the user [userJson] and auth response [oauthData]
  /// to build an [AuthData] object.
  AuthData authData(
      Map<String, dynamic> userJson, Map<String, String> oauthData);
}
