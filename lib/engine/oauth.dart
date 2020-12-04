import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OAuth{
  const OAuth({
    @required this.baseUrl,
    @required this.clientID,
    @required this.redirectUri,
    @required this.state,
    @required this.scope,
    this.clientSecret
  });

  final String baseUrl;
  final String clientID;
  final String clientSecret;
  final String redirectUri;
  final String state;
  final String scope;
  static const String TOKEN_KEY = 'access_token';
  static const String CODE_KEY = 'code';
  static const String CLIENT_ID_KEY = 'clientID';
  static const String CLIENT_SECRET_KEY = 'clientSecret';
  static const String REDIRECT_URI_KEY = 'redirectURI';
  static const String STATE_KEY = 'state';
  static const String SCOPE_KEY = 'scope';

  WebView authenticate({@required Function onDone}){
    String clientSecretQuery = clientSecret != null
        ? '&client_secret=$clientSecret'
        : '';

    String authUrl = '$baseUrl'
        '?client_id=$clientID'
        '$clientSecretQuery'
        '&redirect_uri=$redirectUri'
        '&state=$state'
        '&scope=$scope'
        '&response_type=token';

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    return WebView(
        initialUrl: authUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onPageStarted: (url) async {
          if (url.startsWith(redirectUri)){
            var returnedData = _getQueryParams(url);
            returnedData[CLIENT_ID_KEY] = clientID;
            returnedData[REDIRECT_URI_KEY] = redirectUri;
            returnedData[STATE_KEY] = state;

            if(clientSecret != null){
              returnedData[CLIENT_SECRET_KEY] = clientSecret;
            }

            onDone(returnedData);
          }
        }
    );
  }

  Map<String, String> _getQueryParams(String url){
    final List<String> urlParams = url.split(RegExp('[?&# ]'));
    final Map<String, String> queryParams = HashMap();
    List<String> parts;

    for(String param in urlParams){
      if (!param.contains('=')) continue;

      parts = param.split('=');
      queryParams[parts[0]] = Uri.decodeFull(parts[1]);
    }

    return queryParams;
  }
}

