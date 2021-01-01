import 'dart:convert';
import 'package:http/http.dart' as http;

import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

/// Enables Google [OAuth] authentication
class GoogleAuth implements Visa {
  final baseUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
  String personFields;
  SimpleAuth visa;

  GoogleAuth({this.personFields = ""}) {
    personFields = _getPersonFields(personFields);

    visa = SimpleAuth(
        baseUrl: baseUrl,

        /// Sends a request to the user profile api
        /// endpoint. Returns an AuthData object.
        getAuthData: (Map<String, String> data) async {
          var token = data[OAuth.TOKEN_KEY];
          // User profile API endpoint.
          var baseProfileUrl = 'https://people.googleapis.com/v1/people/me';
          var profileUrl = '$baseProfileUrl?personFields=$personFields';

          var profileResponse = await http
              .get(profileUrl, headers: {'Authorization': 'Bearer $token'});
          var profileJson = json.decode(profileResponse.body);

          return authData(profileJson, data);
        });
  }

  /// This function combines information
  /// from the user [json] and auth response [data]
  /// to build an [AuthData] object.
  AuthData authData(Map<String, dynamic> json, Map<String, String> data) {
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
        userJson: json);
  }

  /// Merges the provided personFields with
  /// the default personFields.
  _getPersonFields(String fields) {
    Set defaultFields = {'names', 'emailAddresses', 'metadata', 'photos'};
    Set inputFields = Set.from(fields.split(RegExp('[ ,]')));

    defaultFields.addAll(inputFields);

    return defaultFields.join(',');
  }
}
