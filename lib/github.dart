import 'dart:convert';
import 'package:http/http.dart' as http;

import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

/// Enables Github [OAuth] authentication
class GithubAuth implements Visa {
  final baseUrl = 'https://github.com/login/oauth/authorize';

  SimpleAuth visa;

  GithubAuth() {
    visa = SimpleAuth(
        baseUrl: baseUrl,

        /// Github returns a code which can be exchanged
        /// for a token. This function gets the token and
        /// Sends a request to the user profile api endpoint.
        /// Returns an AuthData object.
        getAuthData: (Map<String, String> data) async {
          await _getToken(data);
          var token = data[OAuth.TOKEN_KEY];
          // User profile API endpoint.
          var baseProfileUrl = 'https://api.github.com/user';
          var headers = {'Authorization': 'token $token'};
          var profileResponse =
              await http.get(baseProfileUrl, headers: headers);
          var emailResponse =
              await http.get('$baseProfileUrl/emails', headers: headers);
          Map<String, dynamic> profileJson = json.decode(profileResponse.body);
          List<dynamic> emailJson = json.decode(emailResponse.body);
          String emailString;

          for (var email in emailJson) {
            if (email['primary']) {
              emailString = email['email'];
              break;
            }
          }

          profileJson['email'] = emailString;
          profileJson['emails'] = emailJson;

          return authData(profileJson, data);
        });
  }

  /// This function combines information
  /// from the user [json] and auth response [data]
  /// to build an [AuthData] object.
  AuthData authData(Map<String, dynamic> json, Map<String, String> data) {
    var accessToken = data[OAuth.TOKEN_KEY];

    return AuthData(
        clientID: data[OAuth.CLIENT_ID_KEY],
        accessToken: accessToken,
        userID: json['id'].toString(),
        email: json['email'],
        profileImgUrl: json['avatar_url'],
        response: data,
        userJson: json);
  }

  /// Github's [OAuth] endpoint returns a code
  /// which can be exchanged for a token. This
  /// function performs the exchange and adds the
  /// returned data to the response [data] map.
  _getToken(Map<String, String> data) async {
    var tokenEndpoint = 'https://github.com/login/oauth/access_token';
    var tokenResponse = await http.post(tokenEndpoint, headers: {
      'Accept': 'application/json',
    }, body: {
      'client_id': data[OAuth.CLIENT_ID_KEY],
      'client_secret': data[OAuth.CLIENT_SECRET_KEY],
      'code': data[OAuth.CODE_KEY],
      'redirect_uri': data[OAuth.REDIRECT_URI_KEY],
      'state': data[OAuth.STATE_KEY]
    });

    var responseJson = json.decode(tokenResponse.body);
    var tokenTypeKey = 'token_type';

    data[OAuth.TOKEN_KEY] = responseJson[OAuth.TOKEN_KEY] as String;
    data[OAuth.SCOPE_KEY] = responseJson[OAuth.SCOPE_KEY] as String;
    data[tokenTypeKey] = responseJson[tokenTypeKey] as String;
  }
}
