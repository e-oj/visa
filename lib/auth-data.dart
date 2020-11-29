import 'dart:convert';

import 'engine/oauth.dart';

class AuthData{
  const AuthData({
    this.clientID, this.accessToken, this.firstName, this.lastName,
    this.userID, this.email, this.profileImgUrl, this.userJson,
    this.response,
  });

  final String userID;
  final String clientID;
  final String accessToken;
  final String firstName;
  final String lastName;
  final String email;
  final String profileImgUrl;
  final Map<String, dynamic> userJson;
  final Map<String, String> response;

  factory AuthData.fromTwitchJson(
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

  factory AuthData.fromDiscordJson(
      Map<String, dynamic> json,
      Map<String, String>data
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

  factory AuthData.fromFbJson(
      Map<String, dynamic> json,
      Map<String, String>data
  ){
    final String accessToken = data[OAuth.TOKEN_KEY];
    final String profileImgUrl = 'https://graph.facebook.com/me/picture'
        '?type=large'
        '&access_token=$accessToken';

    return AuthData(
        clientID: data['clientID'],
        accessToken: accessToken,
        userID: json['id'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        email: json['email'] as String,
        profileImgUrl: profileImgUrl,
        response: data,
        userJson: json
    );
  }

  String formatResponse(Map<String, String> response){
    StringBuffer result = StringBuffer('\n');

    for (MapEntry data in response.entries){
      result.write('\t\t\t\t');
      result.write(data.key);
      result.write(' = ');
      result.write(data.value);
      result.write('\n');
    }

    return result.toString();
  }

  String formatJson(Map<String, dynamic> json){
    JsonEncoder encoder = JsonEncoder.withIndent('    ');
    return encoder.convert(json);
  }

  @override
  String toString() {
    String responseString = formatResponse(response);
    String prettyUserJson = formatJson(userJson);
    return 'AuthData {\n\n'
        '\t\ttoken: $accessToken\n\n'
        '\t\tuser id: $userID\n\n'
        '\t\tfirst name: $firstName\n\n'
        '\t\tlast name: $lastName\n\n'
        '\t\temail: $email\n\n'
        '\t\tprofile image: $profileImgUrl\n\n'
        '\t\tresponse: $responseString\n'
        '\t\tuser json: $prettyUserJson\n\n'
        '}';
  }
}