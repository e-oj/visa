import 'dart:convert';
import 'package:http/http.dart' as http;

import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

class GoogleAuth implements Visa{
  final baseUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
  String personFields;
  SimpleAuth visa;

  GoogleAuth({this.personFields=""}){
    personFields = _getPersonFields(personFields);
    visa = SimpleAuth(
        baseUrl: baseUrl,
        getAuthData: (Map <String, String> data) async {
          var token = data[OAuth.TOKEN_KEY];
          var baseProfileUrl = 'https://people.googleapis.com/v1/people/me'
              '?personFields=$personFields';

          var profileResponse = await http.get(baseProfileUrl, headers: {
            'Authorization': 'Bearer $token'
          });
          var profileJson = json.decode(profileResponse.body);

          return authData(profileJson, data);
        }
    );
  }

  AuthData authData(
      Map<String, dynamic> json,
      Map<String, String>data
      ){
    final String accessToken = data[OAuth.TOKEN_KEY];

    return AuthData(
        clientID: data['clientID'],
        accessToken: accessToken,
        userID: json['metadata']['sources'][0]['id'],
        firstName: json['names'][0]['givenName'],
        lastName: json['names'][0]['familyName'],
        email: json['emailAddresses'][0]['value'],
        profileImgUrl: json['photos'][0]['url'],
        response: data,
        userJson: json
    );
  }

  _getPersonFields(String fields){
    Set defaultFields = {'names', 'emailAddresses', 'photos', 'metadata'};
    Set inputFields = Set.from(fields.split(','));

    defaultFields.addAll(inputFields);

    return defaultFields.join(',');
  }
}
