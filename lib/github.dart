import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:visa/engine/debug.dart';

import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

/// Enables Github [OAuth] authentication
class GithubAuth extends Visa {
  final baseUrl = 'https://github.com/login/oauth/authorize';
  final Debug _debug = Debug(prefix: 'In GithubAuth ->');

  @override
  SimpleAuth visa;

  GithubAuth() {
    visa = SimpleAuth(
        baseUrl: baseUrl,

        /// Github returns a code which can be exchanged
        /// for a token. This function gets the token and
        /// Sends a request to the user profile api endpoint.
        /// Returns an AuthData object.
        getAuthData: (Map<String, String> oauthData) async {
          if (debugMode) _debug.info('OAuth Data: $oauthData');

          await _getToken(oauthData);
          final String token = oauthData[OAuth.TOKEN_KEY];
          if (debugMode) _debug.info('OAuth token: $token');

          // User profile API endpoint.
          final String baseProfileUrl = 'https://api.github.com/user';
          final Map<String, String> headers = {'Authorization': 'token $token'};
          final Map<String, dynamic> profileJson =
              await _getProfile(baseProfileUrl, headers);
          final Map<String, dynamic> emailJson =
              await _getEmail(baseProfileUrl, headers);

          profileJson['email'] = emailJson['email'];
          profileJson['emails'] = emailJson['emails'];

          if (debugMode) _debug.info('Modified Profile Json: $profileJson');
          return authData(profileJson, oauthData);
        });
  }

  /// This function combines information
  /// from the user [profileJson] and auth response [oauthData]
  /// to build an [AuthData] object.
  AuthData authData(
      Map<String, dynamic> profileJson, Map<String, String> oauthData) {
    final String accessToken = oauthData[OAuth.TOKEN_KEY];

    return AuthData(
        clientID: oauthData[OAuth.CLIENT_ID_KEY],
        accessToken: accessToken,
        userID: profileJson['id'].toString(),
        firstName: profileJson['first_name'],
        lastName: profileJson['last_name'],
        email: profileJson['email'],
        profileImgUrl: profileJson['avatar_url'],
        response: oauthData,
        userJson: profileJson);
  }

  /// Github's [OAuth] endpoint returns a code
  /// which can be exchanged for a token. This
  /// function performs the exchange and adds the
  /// returned data to the response [oauthData] map.
  _getToken(Map<String, String> oauthData) async {
    if (debugMode) _debug.info('Exchanging OAuth Code For Token');

    final Uri tokenEndpoint =
        Uri.parse('https://github.com/login/oauth/access_token');
    final http.Response tokenResponse =
        await http.post(tokenEndpoint, headers: {
      'Accept': 'application/json',
    }, body: {
      'client_id': oauthData[OAuth.CLIENT_ID_KEY],
      'client_secret': oauthData[OAuth.CLIENT_SECRET_KEY],
      'code': oauthData[OAuth.CODE_KEY],
      'redirect_uri': oauthData[OAuth.REDIRECT_URI_KEY],
      'state': oauthData[OAuth.STATE_KEY]
    });

    if (debugMode) _debug.info('Exchange Successful. Retrieved OAuth Token');

    final Map<String, dynamic> responseJson = json.decode(tokenResponse.body);
    final String tokenTypeKey = 'token_type';

    oauthData[OAuth.TOKEN_KEY] = responseJson[OAuth.TOKEN_KEY] as String;
    oauthData[OAuth.SCOPE_KEY] = responseJson[OAuth.SCOPE_KEY] as String;
    oauthData[tokenTypeKey] = responseJson[tokenTypeKey] as String;
  }

  /// Get's a user's Github profile data and
  /// isolates the first and last name.
  /// [baseProfileUrl] - Github base user api url
  /// [headers] - request header with auth token
  Future<Map<String, dynamic>> _getProfile(
      String baseProfileUrl, Map<String, String> headers) async {
    final Uri profileUrl = Uri.parse(baseProfileUrl);
    final http.Response profileResponse =
        await http.get(profileUrl, headers: headers);
    final Map<String, dynamic> profileJson = json.decode(profileResponse.body);

    if (debugMode) _debug.info('Returned Profile Json: $profileJson');

    if (profileJson['name'] != null){
      final List<String> name = profileJson['name'].split(' ');
      profileJson['first_name'] = name[0];
      profileJson['last_name'] = name[1];
    }

    return profileJson;
  }

  /// Get's a user's Github email data and
  /// isolates the primary email address.
  /// [baseProfileUrl] - Github base user api url
  /// [headers] - request header with auth token
  Future<Map<String, dynamic>> _getEmail(
      String baseProfileUrl, Map<String, String> headers) async {
    final Uri emailUrl = Uri.parse('$baseProfileUrl/emails');
    final http.Response emailResponse =
        await http.get(emailUrl, headers: headers);
    final List<dynamic> emailJson = json.decode(emailResponse.body);
    if (debugMode)
      _debug.info(
          'In GithubAuth -> Returned Email Response: ${emailResponse.body}');

    String email;

    for (var _email in emailJson) {
      if (_email['primary']) {
        email = _email['email'];
        break;
      }
    }

    return {'email': email, 'emails': emailJson};
  }
}
