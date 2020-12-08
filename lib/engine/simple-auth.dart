import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../auth-data.dart';
import 'oauth.dart';

class SimpleAuth{
  const SimpleAuth ({
    @required this.baseUrl, @required this.getAuthData
  });

  final String baseUrl;
  final Function getAuthData;

  WebView authenticate({
    @required String clientID, String clientSecret, @required String redirectUri,
    @required String state, @required String scope, @required Function onDone
  }){
    final OAuth oAuth = OAuth(
      baseUrl: baseUrl,
      clientID: clientID,
      redirectUri: redirectUri,
      state: state,
      scope: scope,
      clientSecret: clientSecret
    );

    return oAuth.authenticate(onDone: (responseData) async {
      AuthData authData = await getAuthData(responseData);
      onDone(authData);
    });
  }
}
