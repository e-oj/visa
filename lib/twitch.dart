import 'dart:convert';
import 'package:http/http.dart' as http;

import 'engine/debug.dart';
import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

/// Enables Discord [OAuth] authentication
class TwitchAuth extends Visa {
  final baseUrl = 'https://id.twitch.tv/oauth2/authorize';

  @override
  SimpleAuth visa;

  TwitchAuth() {
    visa = SimpleAuth(
        baseUrl: baseUrl,

        /// Sends a request to the user profile api
        /// endpoint. Returns an AuthData object.
        getAuthData: (Map<String, String> oauthData) async {
          if (debugMode) debug('In TwitchAuth -> OAuth Data: $oauthData');

          var token = oauthData[OAuth.TOKEN_KEY];
          if (debugMode) debug('In TwitchAuth -> OAuth token: $token');

          // User profile API endpoint.
          var baseProfileUrl = 'https://api.twitch.tv/helix/users';
          var profileResponse = await http.get(Uri.parse(baseProfileUrl),
              headers: {
                'Authorization': 'Bearer $token',
                'Client-Id': oauthData['clientID']
              });
          var profileJson = json.decode(profileResponse.body);
          if (debugMode)
            debug('In TwitchAuth -> Returned Profile Json: $profileJson');

          return authData(profileJson, oauthData);
        });
  }

  /// This function combines information
  /// from the user [profileJson] and auth response [oauthData]
  /// to build an [AuthData] object.
  AuthData authData(
      Map<String, dynamic> profileJson, Map<String, String> oauthData) {
    final String accessToken = oauthData[OAuth.TOKEN_KEY];
    Map<String, dynamic> user = profileJson['data'][0];

    return AuthData(
        clientID: oauthData['clientID'],
        accessToken: accessToken,
        userID: user['id'],
        email: user['email'] as String,
        profileImgUrl: user['profile_image_url'] as String,
        response: oauthData,
        userJson: profileJson);
  }
}
