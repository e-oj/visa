import 'dart:convert';
import 'package:http/http.dart' as http;

import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

/// Enables Discord [OAuth] authentication
class DiscordAuth implements Visa {
  final baseUrl = 'https://discord.com/api/oauth2/authorize';
  SimpleAuth visa;

  DiscordAuth() {
    visa = SimpleAuth(
        baseUrl: baseUrl,

        /// Sends a request to the user profile api
        /// endpoint. Returns an AuthData object.
        getAuthData: (Map<String, String> data) async {
          var token = data[OAuth.TOKEN_KEY];
          // User profile API endpoint.
          var baseProfileUrl = 'https://discord.com/api/users/@me';
          var profileResponse = await http.get(baseProfileUrl, headers: {
            'Authorization': 'Bearer $token',
          });
          var profileJson = json.decode(profileResponse.body);

          return authData(profileJson, data);
        });
  }

  /// This function combines information
  /// from the user [json] and auth response [data]
  /// to build an [AuthData] object.
  @override
  AuthData authData(Map<String, dynamic> json, Map<String, String> data) {
    final String accessToken = data[OAuth.TOKEN_KEY];
    final String userId = json['id'] as String;
    final String avatar = json['avatar'] as String;
    final String profileImgUrl = 'https://cdn.discordapp.com/'
        'avatars/$userId/$avatar.png';

    return AuthData(
        clientID: data['clientID'],
        accessToken: accessToken,
        userID: userId,
        email: json['email'] as String,
        profileImgUrl: profileImgUrl,
        response: data,
        userJson: json);
  }
}
