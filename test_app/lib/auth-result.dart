import 'package:flutter/material.dart';
import 'package:test_app/components/image-display.dart';
import 'package:visa/auth-data.dart';
import 'utils.dart';
import 'app-scale.dart';

class AuthResult extends StatefulWidget {
  const AuthResult({Key key}) : super(key: key);

  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<AuthResult> {
  Widget build(BuildContext context) {
    final scale = AppScale(context);
    final AuthData authData = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: Utils.getAppBar(context),
        body: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          ImageDisplay(
              height: 0.20,
              imageUrl: authData != null ? authData.profileImgUrl : null),
          Text(authData.toString())
        ])));
  }
}
