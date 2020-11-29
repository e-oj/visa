import 'dart:convert';
import 'package:http/http.dart' as http;

import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

class TwitchAuth implements Visa{
  final baseUrl = 'https://id.twitch.tv/oauth2/authorize';
  SimpleAuth visa;

  TwitchAuth(){
    visa = SimpleAuth(
        baseUrl: baseUrl,
        getAuthData: (Map <String, String> data) async {
          var token = data[OAuth.TOKEN_KEY];
          var baseProfileUrl = 'https://api.twitch.tv/helix/users';

          var profileResponse = await http.get(baseProfileUrl, headers: {
            'Authorization': 'Bearer $token',
            'Client-Id': data['clientID']
          });

          print(profileResponse);

          var profileJson = Map<String, dynamic>.from(
              json.decode(profileResponse.body)
          );

          return getAuthData(profileJson, data);
        }
    );
  }

  AuthData getAuthData(
      Map<String, dynamic> json,
      Map<String, String>data
  ){
    final String accessToken = data[OAuth.TOKEN_KEY];
    Map<String, dynamic> user = json['data'][0];

    return AuthData(
        clientID: data['clientID'],
        accessToken: accessToken,
        userID: user['id'],
        email: user['email'] as String,
        profileImgUrl: user['profile_image_url'] as String,
        response: data,
        userJson: json
    );
  }
}
