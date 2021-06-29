import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visa/engine/debug.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../auth-data.dart';

class JSAuth {
  /// Creates a new instance based on the given OAuth
  /// baseUrl and getAuthData function.
  JSAuth(
      {@required this.baseUrl,
      @required this.htmlSource,
      @required this.getAuthData});

  final String baseUrl; // OAuth base url
  final String htmlSource;

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
  WebViewController _webviewController;

  /// Creates an [OAuth] instance with the
  /// provided credentials. Returns a WebView
  /// That's been set up for authentication
  WebView authenticate(
      {@required String clientID,
      String clientSecret,
      @required String redirectUri,
      @required String state,
      @required String scope,
      @required Function onDone,
      bool newSession = false}) {
    JavascriptChannel jsChannel = JavascriptChannel(
        name: 'Visa', onMessageReceived: _jsAuthMessageHandler(onDone));

    return WebView(
      initialUrl: '',
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: <JavascriptChannel>{jsChannel},
      onWebViewCreated: (WebViewController controller) async {
        _webviewController = controller;
        await _loadHtml(
            clientID: clientID,
            redirectUri: redirectUri,
            state: state,
            scope: scope);
      },
    );
  }

  _jsAuthMessageHandler(onDone) => (JavascriptMessage jsMessage) {
        List<String> parts = jsMessage.message.split(':');

        if(parts.length < 2){
          _debug.info('JS MESSAGE: ${jsMessage.message}');
          return;
        }

        String msgType = parts[0];
        Map<String, dynamic> response = jsonDecode(parts[1]);
        AuthData authData = msgType == 'ERROR'
            ? AuthData(response: response)
            : getAuthData(response);

        onDone(authData);
      };

  _loadHtml(
      {@required String clientID,
      @required String redirectUri,
      @required String state,
      @required String scope}) async {
    String htmlPath = this.htmlSource;
    print(htmlPath);

    String markup = await rootBundle.loadString(htmlPath);
    markup = markup.replaceFirst('%CLIENT_ID%', clientID);
    markup = markup.replaceFirst('%STATE%', state);
    markup = markup.replaceFirst('%SCOPE%', scope);
    markup = markup.replaceAll('%REDIRECT_URI%', redirectUri);

    print('loaded: $markup');
    _webviewController.loadUrl(Uri.dataFromString(markup,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
