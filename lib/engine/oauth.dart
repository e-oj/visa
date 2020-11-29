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
    @required this.scope
  });

  final String baseUrl;
  final String clientID;
  final String redirectUri;
  final String state;
  final String scope;
  static const String TOKEN_KEY = 'access_token';

  WebView authenticate({@required Function onDone}){
    String authUrl = '$baseUrl'
        '?client_id=$clientID'
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
            returnedData['clientID'] = clientID;
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

