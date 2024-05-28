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
  final Debug _debug = Debug(prefix: 'In FacebookAuth ->');

  @override
  late SimpleAuth visa;

  FacebookAuth() {
    visa = SimpleAuth(
        baseUrl: baseUrl,

        /// Sends a request to the user profile api
        /// endpoint. Returns an AuthData object.
        getAuthData: (Map<String, String> oauthData) async {
          if (debugMode) _debug.info('OAuth Data: $oauthData');

          final String? token = oauthData[OAuth.TOKEN_KEY];
          if (debugMode) _debug.info('OAuth token: $token');

          // User profile API endpoint.
          final String baseProfileUrlString = 'https://graph.facebook.com/me';
          final Uri profileUrl = Uri.parse('$baseProfileUrlString'
              '?access_token=$token'
              '&fields=first_name,last_name,email');

          final http.Response profileResponse = await http.get(profileUrl);
          final Map<String, dynamic> profileJson =
              json.decode(profileResponse.body);
          if (debugMode) _debug.info('Returned Profile Json: $profileJson');

          return authData(profileJson, oauthData);
        });
  }

  /// This function combines information
  /// from the user [json] and auth response [data]
  /// to build an [AuthData] object.
  @override
  AuthData authData(Map<String, dynamic> json, Map<String, String> data) {
    final String? accessToken = data[OAuth.TOKEN_KEY];
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
