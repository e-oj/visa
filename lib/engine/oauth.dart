import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:visa/engine/debug.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// This class contains [OAuth] data and
/// functionality. It has one public method
/// that returns a [WebView] which has been set up
/// for OAuth 2.0 Authentication.
class OAuth {
  OAuth(
      {required this.baseUrl,
      required this.clientID,
      required this.redirectUri,
      required this.state,
      required this.scope,
      required this.debugMode,
      this.clientSecret,
      this.responseType,
      this.otherQueryParams});

  final String baseUrl; // OAuth url
  final String clientID; // OAuth clientID
  final String? clientSecret; // OAuth clientSecret
  final String? responseType; // OAuth clientSecret
  final String redirectUri; // OAuth redirectUri
  final String state; // OAuth state
  final String scope; // OAuth scope
  final Map<String, String>? otherQueryParams;
  final bool debugMode; // Debug mode?
  static const String TOKEN_KEY = 'access_token'; // OAuth token key
  static const String CODE_KEY = 'code'; // OAuth code key
  static const String STATE_KEY = 'state'; // OAuth state key
  static const String SCOPE_KEY = 'scope'; // OAuth scope key
  static const String CLIENT_ID_KEY = 'clientID'; // custom client id key
  static const String CLIENT_SECRET_KEY =
      'clientSecret'; // custom client secret key
  static const String REDIRECT_URI_KEY =
      'redirectURI'; // custom redirect uri key
  final String userAgent = 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/87.0.4280.86 Mobile Safari/537.36'; // UA
  final Debug _debug = Debug(prefix: 'In OAuth ->');

  /// Sets up a [WebView] for OAuth authentication.
  /// [onDone] is called when authentication is
  /// completed successfully.
  WebView authenticate({required Function onDone, bool clearCache = false}) {
    String clientSecretQuery =
        clientSecret != null ? '&client_secret=$clientSecret' : '';
    String responseTypeQuery =
        '&response_type=${responseType == null ? 'token' : responseType}';
    String otherParams = '';

    if (otherQueryParams != null) {
      for (String key in otherQueryParams.keys) {
        otherParams += '&$key=${otherQueryParams[key]}';
      }
    }

    String authUrl = '$baseUrl'
        '?client_id=$clientID'
        '$clientSecretQuery'
        '&redirect_uri=$redirectUri'
        '&state=$state'
        '&scope=$scope'
        '$responseTypeQuery'
        '$otherParams';

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    return WebView(
        onWebViewCreated: (controller) async {
          if (clearCache) {
            if (debugMode) _debug.info('Clearing Cache and Cookies...');
            CookieManager cookieManager = CookieManager();

            await cookieManager.clearCookies();
            await controller.clearCache();
          }
        },
        userAgent: userAgent,
        initialUrl: authUrl,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: _getNavigationDelegate(onDone));
  }

  /// Returns a navigation delegate that attempts
  /// to match the redirect url whenever the browser
  /// navigates to a new page. Once the redirect url
  /// is found, it calls the [onDone] callback.
  _getNavigationDelegate(onDone) => (NavigationRequest request) {
        String url = request.url;

        if (debugMode) _debug.info('Inspecting Url Before Loading: $url');

        if (url.startsWith(redirectUri)) {
          if (debugMode) _debug.info('Found Redirect Url: $url');

          var returnedData = _getQueryParams(url);
          returnedData[CLIENT_ID_KEY] = clientID;
          returnedData[REDIRECT_URI_KEY] = redirectUri;
          returnedData[STATE_KEY] = state;

          if (clientSecret != null) {
            returnedData[CLIENT_SECRET_KEY] = clientSecret;
          }

          onDone(returnedData);
        } else if (debugMode) {
          _debug.info('Redirect Url Not Found');
          _debug.info('Url = $url');
          _debug.info('Redirect Url = $redirectUri');
        }

        return NavigationDecision.navigate;
      };

  /// Parses url query params into a map
  /// @param url: The url to parse.
  Map<String, String> _getQueryParams(String url) {
    if (debugMode) _debug.info('Getting Query Params From Url: $url');

    final List<String> urlParams = url.split(RegExp('[?&# ]'));
    final Map<String, String> queryParams = HashMap();
    List<String> parts;

    for (String param in urlParams) {
      if (!param.contains('=')) continue;

      parts = param.split('=');
      queryParams[parts[0]] = Uri.decodeFull(parts[1]);
    }

    if (debugMode) _debug.info('Extracted Query Params: $queryParams');
    return queryParams;
  }
}
