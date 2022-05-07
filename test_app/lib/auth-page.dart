import 'package:flutter/material.dart';
import 'package:visa/engine/visa.dart';
import 'package:visa/engine/debug.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:visa/fb.dart';
import 'package:visa/auth-data.dart';
import 'package:visa/discord.dart';
import 'package:visa/twitch.dart';
import 'package:visa/github.dart';
import 'package:visa/google.dart';
import 'package:visa/linkedin.dart';
import 'package:visa/spotify.dart';

import 'utils.dart';

class AuthPage extends StatelessWidget {
  AuthPage({Key? key, required this.thirdParty}) : super(key: key);

  final String thirdParty;
  final Debug _debug = Debug(prefix: 'In AuthPage ->');

  @override
  Widget build(BuildContext context) {
    WebView? authenticate = _getThirdPartyAuth(context);

    return Scaffold(
      appBar: Utils.getAppBar(context),
      body: authenticate,
    );
  }

  WebView? _getThirdPartyAuth(context) {
    done(AuthData authData) {
      _debug.info('Authentication Complete!');
      _debug.info('Data Gathered During Authentication: $authData');

      Navigator.pushReplacementNamed(context, '/complete-profile',
          arguments: authData);
    }

    var fbAuth = FacebookAuth();
    var discordAuth = DiscordAuth();
    var googleAuth = GoogleAuth();
    var twitchAuth = TwitchAuth();
    var githubAuth = GithubAuth();
    var linkedInAuth = LinkedInAuth();
    var spotifyAuth = SpotifyAuth();
    List<Visa> allProviders = [
      fbAuth,
      discordAuth,
      googleAuth,
      twitchAuth,
      githubAuth,
      linkedInAuth,
      spotifyAuth
    ];

    for (var provider in allProviders) {
      provider.debug = true;
    }

    switch (thirdParty) {
      case 'fb':
        return fbAuth.visa.authenticate(
            clientID: '139732240983759',
            redirectUri: 'https://www.e-oj.com/oauth',
            scope: 'public_profile,email',
            state: 'fbAuth',
            onDone: done);

      case 'twitch':
        return twitchAuth.visa.authenticate(
            clientID: 'fx9d4xcwzswjzwt8cfzj8lh8paphdu',
            redirectUri: 'https://www.e-oj.com/oauth',
            state: 'twitchAuth',
            scope: 'user:read:email',
            onDone: done);

      case 'discord':
        return discordAuth.visa.authenticate(
            clientID: '785323970999091211',
            redirectUri: 'https://www.e-oj.com/oauth',
            state: 'discordAuth',
            scope: 'identify email',
            onDone: done);

      case 'github':
        return githubAuth.visa.authenticate(
            clientID: 'e6a01102910a7a9d694e',
            clientSecret: 'a532ab8c42e9f884f276846fc7f32e069fc0133d',
            redirectUri: 'https://www.e-oj.com/oauth',
            state: 'githubAuth',
            scope: 'user',
            onDone: done);

      case 'google':
        return googleAuth.visa.authenticate(
            clientID: '463257508739-c03fcu5pej7odrci1tclk53qdd'
                'tsa0vo.apps.googleusercontent.com',
            redirectUri: 'https://www.e-oj.com/oauth',
            state: 'googleAuth',
            scope: 'https://www.googleapis.com/auth/user.emails.read '
                'https://www.googleapis.com/auth/userinfo.profile',
            onDone: done);

      case 'linkedIn':
        return linkedInAuth.visa.authenticate(
            clientID: '78lyweifjuavwi',
            clientSecret: 'SbUU4yfIdEghTeb8',
            redirectUri: 'https://www.e-oj.com/oauth',
            state: 'linkedInAuth',
            scope: 'r_liteprofile r_emailaddress',
            onDone: done);

      case 'spotify':
        return spotifyAuth.visa.authenticate(
            clientID: '5c711cec6f9740fc9b91cca9461cefb8',
            clientSecret: '8fd2691a84364c8ea30e31e1198c327e',
            redirectUri: 'https://www.e-oj.com/oauth',
            state: 'spotifyAuth',
            scope: 'user-read-email user-read-private',
            onDone: done);
      default:
        return null;
    }
  }
}
