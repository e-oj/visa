import 'package:visa/engine/debug.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../auth-data.dart';
import 'oauth.dart';

/// Magic class [SimpleAuth] makes it easy to
/// add new [OAuth] providers by handling the
/// shared authentication process and
/// delegating the platform specific user
/// retrieval process to [getAuthData], a function
/// provided through the constructor.
class SimpleAuth {
  /// Creates a new instance based on the given OAuth
  /// baseUrl and getAuthData function.
  SimpleAuth(
      {required this.baseUrl,
      required this.getAuthData,
      this.responseType,
      this.otherQueryParams});

  final String baseUrl; // OAuth base url
  final String? responseType;
  final Map<String, String>? otherQueryParams;

  /// This function makes the necessary api calls to
  /// get a user's profile data. It accepts a single
  /// argument: a Map<String, String> containing the
  /// full auth response including an api access token.
  /// An [AuthData] object is created from a combination
  /// of the passed in auth response and the user
  /// response returned from the api.
  ///
  /// @return [AuthData]
  final Function getAuthData;

  /// Debug mode?
  bool debugMode = false;
  final Debug _debug = Debug(prefix: 'In SimpleAuth ->');

  /// Creates an [OAuth] instance with the
  /// provided credentials. Returns a WebView
  /// That's been set up for authentication
  Future<WebViewWidget> authenticate(
      {required String clientID,
      String? clientSecret,
      required String redirectUri,
      required String state,
      required String scope,
      required Function onDone,
      bool newSession = false}) {
    final OAuth oAuth = OAuth(
        baseUrl: baseUrl,
        clientID: clientID,
        clientSecret: clientSecret,
        redirectUri: redirectUri,
        state: state,
        scope: scope,
        responseType: responseType,
        otherQueryParams: otherQueryParams,
        debugMode: debugMode);

    return oAuth.authenticate(
        clearCache: newSession,
        onDone: (responseData) async {
          if (debugMode) _debug.info('Response: $responseData');

          final String? token = responseData[OAuth.TOKEN_KEY];
          final String? code = responseData[OAuth.CODE_KEY];

          AuthData authData = token == null && code == null
              ? AuthData(response: responseData)
              : await getAuthData(responseData);

          if (debugMode) _debug.info('Returned Authentication Data: $authData');

          onDone(authData);
        });
  }
}
