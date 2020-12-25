import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:visa/fb.dart';
import 'package:visa/auth-data.dart';
import 'package:visa/discord.dart';
import 'package:visa/twitch.dart';
import 'package:visa/github.dart';
import 'package:visa/google.dart';

import 'utils.dart';

class AuthPage extends StatelessWidget {
  AuthPage({Key key, @required this.thirdParty}) : super(key: key);

  final String thirdParty;

  @override
  Widget build(BuildContext context) {
    WebView authenticate = _getThirdPartyAuth(context);

    return Scaffold(
      appBar: Utils.getAppBar(context),
      body: authenticate,
    );
  }

  WebView _getThirdPartyAuth(context) {
    var done = (AuthData authData) {
      print(authData);

      Navigator.pushReplacementNamed(context, '/complete-profile',
          arguments: authData);
    };

    switch (thirdParty) {
      case 'fb':
        return FacebookAuth().visa.authenticate(
            clientID: '139732240983759',
            redirectUri: 'https://www.e-oj.com/oauth',
            scope: 'public_profile,email',
            state: 'fbAuth',
            onDone: done);

      case 'twitch':
        return TwitchAuth().visa.authenticate(
            clientID: 'fx9d4xcwzswjzwt8cfzj8lh8paphdu',
            redirectUri: 'https://www.e-oj.com/oauth',
            state: 'twitchAuth',
            scope: 'user:read:email',
            onDone: done);

      case 'discord':
        return DiscordAuth().visa.authenticate(
            clientID: '785323970999091211',
            redirectUri: 'https://www.e-oj.com/oauth',
            state: 'discordAuth',
            scope: 'identify email',
            onDone: done);

      case 'github':
        return GithubAuth().visa.authenticate(
            clientID: 'e6a01102910a7a9d694e',
            clientSecret: 'a532ab8c42e9f884f276846fc7f32e069fc0133d',
            redirectUri: 'https://www.e-oj.com/oauth',
            state: 'githubAuth',
            scope: 'user',
            onDone: done);

      case 'google':
        return GoogleAuth().visa.authenticate(
            clientID: '463257508739-c03fcu5pej7odrci1tclk53qdd'
                'tsa0vo.apps.googleusercontent.com',
            redirectUri: 'https://www.e-oj.com/oauth',
            state: 'googleAuth',
            scope: 'https://www.googleapis.com/auth/user.emails.read '
                'https://www.googleapis.com/auth/userinfo.profile',
            onDone: done);
    }

    return null;
  }
}
