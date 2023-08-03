import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'utils.dart';
import 'app-scale.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  Widget build(BuildContext context) {
    AppScale scale = AppScale(context);
    final double iconWidth = scale.ofHeight(0.0245);

    return Scaffold(
      appBar: Utils.getAppBar(context, canGoBack: false),
      body: SingleChildScrollView(
          child: Container(
              color: Colors.white,
              child: Container(
                  color: HexColor('#f5f5f5'),
                  width: scale.ofWidth(1),
                  padding: EdgeInsets.fromLTRB(
                      0, scale.ofHeight(0.027), 0, scale.ofHeight(0.027)),
                  child: Column(children: [
                    Utils.getButton(
                        text: 'Sign up with Facebook',
                        color: HexColor('#4267B2'),
                        textColor: Colors.white,
                        icon: Image.asset('assets/fb.png', width: iconWidth),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/fb-auth')),
                    Utils.getButton(
                        text: 'Sign up with Google',
                        color: Colors.white,
                        textColor: HexColor('#4D4D4D'),
                        icon:
                        Image.asset('assets/google.png', width: iconWidth),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/google-auth')),
                    Utils.getButton(
                        text: 'Sign up with Twitch',
                        color: HexColor('#6441A4'),
                        textColor: Colors.white,
                        icon:
                            Image.asset('assets/twitch.png', width: iconWidth),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/twitch-auth')),
                    Utils.getButton(
                        text: 'Sign up with Discord',
                        color: HexColor('#7289DA'),
                        textColor: Colors.white,
                        icon:
                            Image.asset('assets/discord.png', width: iconWidth),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/discord-auth')),
                    Utils.getButton(
                        text: 'Sign up with Github',
                        color: HexColor('#211F1F'),
                        textColor: Colors.white,
                        icon:
                            Image.asset('assets/github.png', width: iconWidth),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/github-auth')),
                    Utils.getButton(
                        text: 'Sign up with LinkedIn',
                        color: HexColor('#2867B2'),
                        textColor: Colors.white,
                        icon: Image.asset('assets/linkedin.png',
                            width: iconWidth + 2),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/linkedin-auth')),
                    Utils.getButton(
                        text: 'Sign up with Spotify',
                        color: HexColor('#1DB954'),
                        textColor: Colors.white,
                        icon:
                            Image.asset('assets/spotify.png', width: iconWidth),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/spotify-auth'))
                  ])))),
    );
  }
}
