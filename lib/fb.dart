import 'dart:convert';
import 'package:http/http.dart' as http;

import 'engine/debug.dart';
import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

/// Enables Facebook [OAuth] authentication
class FacebookAuth extends Visa {
  final baseUrl = 'https://www.facebook.com/v8.0/dialog/oauth';

  @override
  SimpleAuth visa;

  FacebookAuth() {
    visa = SimpleAuth(
        baseUrl: baseUrl,

        /// Sends a request to the user profile api
        /// endpoint. Returns an AuthData object.
        getAuthData: (Map<String, String> oauthData) async {
          if (debugMode) debug('In FacebookAuth -> OAuth Data: $oauthData');

          final String token = oauthData[OAuth.TOKEN_KEY];
          if (debugMode) debug('In FacebookAuth -> OAuth token: $token');

          // User profile API endpoint.
          var baseProfileUrl = 'https://graph.facebook.com/me';
          final String profileUrl = '$baseProfileUrl'
              '?access_token=$token'
              '&fields=first_name,last_name,email';

          var profileResponse = await http.get(Uri.parse(profileUrl));
          var profileJson = json.decode(profileResponse.body);
          if (debugMode)
            debug('In FacebookAuth -> Returned Profile Json: $profileJson');

          return authData(profileJson, oauthData);
        });
  }

  /// This function combines information
  /// from the user [json] and auth response [data]
  /// to build an [AuthData] object.
  @override
  AuthData authData(Map<String, dynamic> json, Map<String, String> data) {
    final String accessToken = data[OAuth.TOKEN_KEY];
    final String profileImgUrl = 'https://graph.facebook.com/me/picture'
        '?type=large'
        '&access_token=$accessToken';

    return AuthData(
        clientID: data['clientID'],
        accessToken: accessToken,
        userID: json['id'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        email: json['email'] as String,
        profileImgUrl: profileImgUrl,
        response: data,
        userJson: json);
  }
}
