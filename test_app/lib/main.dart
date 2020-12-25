import 'package:flutter/material.dart';

import 'auth-page.dart';
import 'registration.dart';
import 'auth-result.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visa',
      theme: ThemeData(
        primaryColor: Colors.white,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => RegistrationPage(),
        '/complete-profile': (BuildContext context) => AuthResult(),
        '/fb-auth': (BuildContext context) => AuthPage(thirdParty: 'fb'),
        '/twitch-auth': (BuildContext context) =>
            AuthPage(thirdParty: 'twitch'),
        '/discord-auth': (BuildContext context) =>
            AuthPage(thirdParty: 'discord'),
        '/github-auth': (BuildContext context) =>
            AuthPage(thirdParty: 'github'),
        '/google-auth': (BuildContext context) => AuthPage(thirdParty: 'google')
      },
    );
  }
}
