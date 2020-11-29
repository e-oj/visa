import 'dart:convert';
import 'package:http/http.dart' as http;

import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

class DiscordAuth implements Visa{
  final baseUrl = 'https://discord.com/api/oauth2/authorize';
  SimpleAuth visa;

  DiscordAuth(){
    visa = SimpleAuth(
        baseUrl: baseUrl,
        getAuthData: (Map <String, String> data) async {
          var token = data[OAuth.TOKEN_KEY];
          var baseProfileUrl = 'https://discord.com/api/users/@me';

          var profileResponse = await http.get(baseProfileUrl, headers: {
            'Authorization': 'Bearer $token',
          });

          print(profileResponse);

          var profileJson = Map<String, dynamic>.from(
              json.decode(profileResponse.body)
          );

          return getAuthData(profileJson, data);
        }
    );
  }

  @override
  AuthData getAuthData(
      Map<String, dynamic> json,
      Map<String, String> data
  ){
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
        userJson: json
    );
  }
}
