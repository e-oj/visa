import 'package:visa/auth-data.dart';
import 'package:visa/engine/js-auth.dart';

class AppleAuth {
  final String baseUrl = "";
  final String sourceFile = "apple-auth.html";

  JSAuth visa;

  AppleAuth() {
    visa = JSAuth(
        baseUrl: baseUrl,
        htmlSource: sourceFile,
        getAuthData: (Map<String, String> data) {
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
