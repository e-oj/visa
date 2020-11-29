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
    @required String clientID, @required String redirectUri,
    @required String state, @required String scope, @required Function onDone
  }){
    final OAuth oAuth = OAuth(
      baseUrl: baseUrl,
      clientID: clientID,
      redirectUri: redirectUri,
      state: state,
      scope: scope,
    );

    return oAuth.authenticate(onDone: (token) async {
      AuthData authData = await getAuthData(token);
      onDone(authData);
    });
  }
}
