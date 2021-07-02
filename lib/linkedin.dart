import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:visa/engine/debug.dart';

import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

/// Enables Github [OAuth] authentication
class LinkedInAuth extends Visa {
  final baseUrl = 'https://www.linkedin.com/oauth/v2/authorization';
  final Debug _debug = Debug(prefix: 'In LinkedInAuth ->');

  @override
  SimpleAuth visa;

  LinkedInAuth() {
    visa = SimpleAuth(
        baseUrl: baseUrl,
        responseType: 'code',

        /// Github returns a code which can be exchanged
        /// for a token. This function gets the token and
        /// Sends a request to the user profile api endpoint.
        /// Returns an AuthData object.
        getAuthData: (Map<String, String> oauthData) async {
          if (debugMode) _debug.info('OAuth Data: $oauthData');

          await _getToken(oauthData);
          final String token = oauthData[OAuth.TOKEN_KEY];
          if (debugMode) _debug.info('OAuth token: $token');
          //
          // // User profile API endpoint.
          // final String baseProfileUrlString = 'GET https://api.linkedin.com/v2/me';
          // final Uri profileUrl = Uri.parse(baseProfileUrlString);
          // final Uri emailUrl = Uri.parse('$baseProfileUrlString/emails');
          // final Map<String, String> headers = {'Authorization': 'token $token'};
          //
          // final http.Response profileResponse =
          // await http.get(profileUrl, headers: headers);
          // final Map<String, dynamic> profileJson =
          // json.decode(profileResponse.body);
          // if (debugMode) _debug.info('Returned Profile Json: $profileJson');
          //
          // final http.Response emailResponse =
          // await http.get(emailUrl, headers: headers);
          // final List<dynamic> emailJson = json.decode(emailResponse.body);
          // if (debugMode)
          //   _debug.info(
          //       'In GithubAuth -> Returned Email Response: ${emailResponse.body}');
          //
          // if (debugMode) _debug.info('Modified Profile Json: $profileJson');
          // return authData(profileJson, oauthData);
          return AuthData(
            accessToken: '',
            email: '',
            firstName: '',
            userID: '',
            lastName: '',
            profileImgUrl: '',
            userJson: {},
            clientID: '',
            response: oauthData
          );
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
    Uri.parse('https://www.linkedin.com/oauth/v2/accessToken');
    final http.Response tokenResponse =
    await http.post(tokenEndpoint, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    }, body: {
      'grant_type': 'authorization_code',
      'client_id': oauthData[OAuth.CLIENT_ID_KEY],
      'client_secret': oauthData[OAuth.CLIENT_SECRET_KEY],
      'code': oauthData[OAuth.CODE_KEY],
      'redirect_uri': oauthData[OAuth.REDIRECT_URI_KEY],
    });

    if (debugMode) _debug.info('Exchange Successful. Retrieved OAuth Token');

    final Map<String, dynamic> responseJson = json.decode(tokenResponse.body);
    final String expiryKey = 'expires_in';

    _debug.info('Token Response: ${tokenResponse.body}');

    oauthData[OAuth.TOKEN_KEY] = responseJson[OAuth.TOKEN_KEY];
    oauthData[expiryKey] = responseJson[expiryKey].toString();
  }
}
