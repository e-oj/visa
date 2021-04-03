import 'dart:convert';
import 'package:http/http.dart' as http;

import 'engine/debug.dart';
import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

/// Enables Google [OAuth] authentication
class GoogleAuth extends Visa {
  final baseUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
  String personFields;

  @override
  SimpleAuth visa;

  GoogleAuth({this.personFields = ""}) {
    personFields = _getPersonFields(personFields);

    visa = SimpleAuth(
        baseUrl: baseUrl,

        /// Sends a request to the user profile api
        /// endpoint. Returns an AuthData object.
        getAuthData: (Map<String, String> oauthData) async {
          if (debugMode) debug('In GoogleAuth -> OAuth Data: $oauthData');

          var token = oauthData[OAuth.TOKEN_KEY];
          if (debugMode) debug('In GoogleAuth -> OAuth token: $token');

          // User profile API endpoint.
          var baseProfileUrl = 'https://people.googleapis.com/v1/people/me';
          var profileUrl = '$baseProfileUrl?personFields=$personFields';

          var profileResponse = await http.get(Uri.parse(profileUrl),
              headers: {'Authorization': 'Bearer $token'});
          var profileJson = json.decode(profileResponse.body);
          if (debugMode)
            debug('In GoogleAuth -> Returned Profile Json: $profileJson');

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
        clientID: oauthData['clientID'],
        accessToken: accessToken,
        userID: profileJson['metadata']['sources'][0]['id'],
        firstName: profileJson['names'][0]['givenName'],
        lastName: profileJson['names'][0]['familyName'],
        email: profileJson['emailAddresses'][0]['value'],
        profileImgUrl: profileJson['photos'][0]['url'],
        response: oauthData,
        userJson: profileJson);
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
