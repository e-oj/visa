import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:visa/engine/debug.dart';

import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

/// Enables LinkedIn [OAuth] authentication
class LinkedInAuth extends Visa {
  final baseUrl = 'https://www.linkedin.com/oauth/v2/authorization';
  final Debug _debug = Debug(prefix: 'In LinkedInAuth ->');

  @override
  late SimpleAuth visa;

  LinkedInAuth() {
    visa = SimpleAuth(
        baseUrl: baseUrl,
        responseType: 'code',

        /// LinkedIn returns a code which can be exchanged
        /// for a token. This function gets the token and
        /// Sends a request to the user profile api endpoint.
        /// Returns an AuthData object.
        getAuthData: (Map<String, String> oauthData) async {
          if (debugMode) _debug.info('OAuth Data: $oauthData');

          await _getToken(oauthData);
          final String? token = oauthData[OAuth.TOKEN_KEY];
          if (debugMode) _debug.info('OAuth token: $token');

          final String baseApiUrl = 'https://api.linkedin.com/v2';
          final Map<String, String> headers = {
            'Authorization': 'Bearer $token'
          };
          final Map<String, dynamic> profileJson =
              await _getProfile(baseApiUrl, headers);
          final Map<String, dynamic> emailJson =
              await _getEmail(baseApiUrl, headers);

          profileJson['emailJson'] = emailJson;
          if (debugMode) _debug.info('Modified Profile Json: $profileJson');

          return authData(profileJson, oauthData);
        });
  }

  /// This function combines information
  /// from the user [profileJson] and auth response [oauthData]
  /// to build an [AuthData] object.
  AuthData authData(
      Map<String, dynamic> profileJson, Map<String, String> oauthData) {
    final String? accessToken = oauthData[OAuth.TOKEN_KEY];

    return AuthData(
        clientID: oauthData[OAuth.CLIENT_ID_KEY],
        accessToken: accessToken,
        userID: profileJson['id'],
        firstName: profileJson['localizedFirstName'],
        lastName: profileJson['localizedLastName'],
        email: profileJson['emailJson']['email'],
        profileImgUrl: profileJson['profileImage'],
        response: oauthData,
        userJson: profileJson);
  }

  /// LinkedIn's [OAuth] endpoint returns a code
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

    oauthData[OAuth.TOKEN_KEY] = responseJson[OAuth.TOKEN_KEY];
    oauthData[expiryKey] = responseJson[expiryKey].toString();
  }

  /// Get's a user's LinkedIn profile data and
  /// isolates the profile image.
  /// [baseApiUrl] - LinkedIn base api url
  /// [headers] - request header with auth token
  Future<Map<String, dynamic>> _getProfile(
      String baseApiUrl, Map<String, String> headers) async {
    // User profile API endpoint.
    final String profileUrlString = '$baseApiUrl/me?projection='
        '(id,localizedFirstName,localizedLastName,'
        'profilePicture('
        'displayImage~digitalmediaAsset:playableStreams'
        '(elements)))';
    final Uri profileUrl = Uri.parse(profileUrlString);
    final http.Response profileResponse =
        await http.get(profileUrl, headers: headers);
    final Map<String, dynamic> profileJson = json.decode(profileResponse.body);

    if (debugMode) {
      _debug.info('Returned Profile Json: $profileJson');
    }

    profileJson['profileImage'] = profileJson['profilePicture']['displayImage~']
        ['elements'][0]['identifiers'][0]['identifier'];

    return profileJson;
  }

  /// Get's a user's LinkedIn email data and
  /// isolates the primary email address.
  /// [baseApiUrl] - LinkedIn base api url
  /// [headers] - request header with auth token
  Future<Map<String, dynamic>> _getEmail(
      String baseApiUrl, Map<String, String> headers) async {
    // User email API endpoint.
    final String emailUrlString = '$baseApiUrl/clientAwareMemberHandles?'
        'q=members&projection=(elements*(primary,type,handle~))';
    final Uri emailUrl = Uri.parse(emailUrlString);
    final http.Response emailResponse =
        await http.get(emailUrl, headers: headers);
    final Map<String, dynamic> emailJson = json.decode(emailResponse.body);

    if (debugMode) {
      _debug.info('Returned Email Response: ${emailResponse.body}');
    }

    String? email;
    List<dynamic> elements = emailJson['elements'];

    for (Map<String, dynamic> contact in elements) {
      if (contact['type'] == 'EMAIL' && contact['primary'] == true) {
        email = contact['handle~']['emailAddress'];
        break;
      }
    }

    if (debugMode) {
      _debug.info('Returned Email: $email}');
    }

    emailJson['email'] = email;

    return emailJson;
  }
}
