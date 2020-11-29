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

          return AuthData.fromTwitchJson(profileJson, data);
        }
    );
  }
}
