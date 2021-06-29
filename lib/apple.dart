import 'package:visa/auth-data.dart';
import 'package:visa/engine/js-auth.dart';

class AppleAuth {
  final String baseUrl = '';
  final String sourceFile = 'packages/visa/html/apple-auth.html';

  JSAuth visa;

  AppleAuth() {
    visa = JSAuth(
        baseUrl: baseUrl,
        htmlSource: sourceFile,
        getAuthData: (Map<String, dynamic> data) {
          print('Apple auth data: $data');

          return AuthData(
              accessToken: "",
              email: "",
              firstName: "",
              lastName: "",
              userID: "",
              profileImgUrl: "",
              clientID: "",
              response: {"-": ""},
              userJson: {"-": ""});
        });
  }
}
