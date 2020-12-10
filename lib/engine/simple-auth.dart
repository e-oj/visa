import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../auth-data.dart';
import 'oauth.dart';


/// Magic class [SimpleAuth] makes it easy to
/// add new [OAuth] providers by handling the
/// shared authentication process and
/// delegating the platform specific user
/// retrieval process to [getAuthData], a function
/// provided through the constructor.
class SimpleAuth{
  const SimpleAuth ({
    @required this.baseUrl, @required this.getAuthData
  });

  final String baseUrl;
  final Function getAuthData;

  /// Creates an [OAuth] instance with the
  /// provided credentials. Returns a WebView
  /// That's been set up for authentication
  WebView authenticate({
    @required String clientID, String clientSecret, @required String redirectUri,
    @required String state, @required String scope, @required Function onDone,
    bool newSession=false
  }){
    final OAuth oAuth = OAuth(
      baseUrl: baseUrl,
      clientID: clientID,
      redirectUri: redirectUri,
      state: state,
      scope: scope,
      clientSecret: clientSecret
    );

    return oAuth.authenticate(
      clearCache: newSession,
      onDone: (responseData) async {
        AuthData authData = await getAuthData(responseData);
        onDone(authData);
      }
    );
  }
}
