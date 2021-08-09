import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:visa/engine/debug.dart';

import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

/// Enables Github [OAuth] authentication
class SpotifyAuth extends Visa {
  final baseUrl = 'https://accounts.spotify.com/authorize';
  final Debug _debug = Debug(prefix: 'In SpotifyAuth ->');

  @override
  SimpleAuth visa;

  SpotifyAuth() {
    visa = SimpleAuth(
        baseUrl: baseUrl,
        responseType: 'code',
        otherQueryParams: {'show_dialog': 'true'},

        /// Spotify returns a code which can be exchanged
        /// for a token. This function gets the token and
        /// calls a function which Sends a request to the
        /// user profile api endpoint. Returns an AuthData
        /// object.
        getAuthData: (Map<String, String> oauthData) async {
          if (debugMode) _debug.info('OAuth Data: $oauthData');

          await _getToken(oauthData);
          final String token = oauthData[OAuth.TOKEN_KEY];
          if (debugMode) _debug.info('OAuth token: $token');

          final Map<String, dynamic> profileJson = await _getProfile(token);

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
        profileImgUrl: profileJson['profile_image'],
        response: oauthData,
        userJson: profileJson);
  }

  /// Spotify's [OAuth] endpoint returns a code
  /// which can be exchanged for a token. This
  /// function performs the exchange and adds the
  /// returned data to the response [oauthData] map.
  _getToken(Map<String, String> oauthData) async {
    if (debugMode) _debug.info('Exchanging OAuth Code For Token');

    final Uri tokenEndpoint =
        Uri.parse('https://accounts.spotify.com/api/token');
    final http.Response tokenResponse =
        await http.post(tokenEndpoint, headers: {
      'Accept': 'application/json',
    }, body: {
      'grant_type': 'authorization_code',
      'code': oauthData[OAuth.CODE_KEY],
      'client_id': oauthData[OAuth.CLIENT_ID_KEY],
      'client_secret': oauthData[OAuth.CLIENT_SECRET_KEY],
      'redirect_uri': oauthData[OAuth.REDIRECT_URI_KEY]
    });

    if (debugMode) _debug.info('Exchange Successful. Retrieved OAuth Token');

    final Map<String, dynamic> responseJson = json.decode(tokenResponse.body);
    final String tokenTypeKey = 'token_type';
    final String expiryKey = 'expires_in';
    final String refreshTokenKey = 'refresh_token';

    oauthData[OAuth.TOKEN_KEY] = responseJson[OAuth.TOKEN_KEY] as String;
    oauthData[OAuth.SCOPE_KEY] = responseJson[OAuth.SCOPE_KEY] as String;
    oauthData[tokenTypeKey] = responseJson[tokenTypeKey] as String;
    oauthData[expiryKey] = responseJson[expiryKey].toString();
    oauthData[refreshTokenKey] = responseJson[refreshTokenKey];
  }

  /// Get's a user's Spotify profile data and
  /// isolates the first and last name.
  Future<Map<String, dynamic>> _getProfile(String token) async {
    // User profile API endpoint.
    final String profileUrlString = 'https://api.spotify.com/v1/me';
    final Uri profileUrl = Uri.parse(profileUrlString);
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    http.Response profileResponse =
        await http.get(profileUrl, headers: headers);

    final Map<String, dynamic> profileJson = json.decode(profileResponse.body);

    if (debugMode) _debug.info('Returned Profile Json: $profileJson');

    final String displayName = profileJson['display_name'];
    final List<dynamic> images = profileJson['images'];

    if (displayName != null) {
      List<String> names = displayName.split(' ');
      profileJson['first_name'] = names[0];

      if (names.length > 1) {
        profileJson['last_name'] = names[names.length - 1];
      }
    }

    if (images != null && images.length > 0) {
      profileJson['profile_image'] = images[0]['url'];
    }

    return profileJson;
  }
}
