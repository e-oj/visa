import 'dart:convert';
import 'package:http/http.dart' as http;

import 'engine/debug.dart';
import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

/// Enables Discord [OAuth] authentication
class DiscordAuth extends Visa {
  final baseUrl = 'https://discord.com/api/oauth2/authorize';
  final Debug _debug = Debug(prefix: 'In DiscordAuth ->');

  @override
  late SimpleAuth visa;
  DiscordAuth() {
    visa = SimpleAuth(
        baseUrl: baseUrl,

        /// Sends a request to the user profile api
        /// endpoint. Returns an AuthData object.
        getAuthData: (Map<String, String> oauthData) async {
          if (debugMode) _debug.info('OAuth Data: $oauthData');

          final String? token = oauthData[OAuth.TOKEN_KEY];
          if (debugMode) _debug.info('OAuth token: $token');

          // User profile API endpoint.
          final Uri profileUrl = Uri.parse('https://discord.com/api/users/@me');
          final http.Response profileResponse =
              await http.get(profileUrl, headers: {
            'Authorization': 'Bearer $token',
          });
          final Map<String, dynamic> profileJson =
              json.decode(profileResponse.body);
          if (debugMode) _debug.info('Returned Profile Json: $profileJson');

          return authData(profileJson, oauthData);
        });
  }

  /// This function combines information
  /// from the user [profileJson] and auth response [oauthData]
  /// to build an [AuthData] object.
  @override
  AuthData authData(
      Map<String, dynamic> profileJson, Map<String, String> oauthData) {
    final String? accessToken = oauthData[OAuth.TOKEN_KEY];
    final String userId = profileJson['id'] as String;
    final String avatar = profileJson['avatar'] as String;
    final String profileImgUrl = 'https://cdn.discordapp.com/'
        'avatars/$userId/$avatar.png';

    return AuthData(
        clientID: oauthData['clientID'],
        accessToken: accessToken,
        userID: userId,
        email: profileJson['email'] as String,
        profileImgUrl: profileImgUrl,
        response: oauthData,
        userJson: profileJson);
  }
}
