import 'dart:convert';

class AuthData{
  const AuthData({
    this.clientID, this.accessToken, this.firstName, this.lastName,
    this.userID, this.email, this.profileImgUrl, this.userJson,
    this.response,
  });

  final String userID;
  final String clientID;
  final String accessToken;
  final String firstName;
  final String lastName;
  final String email;
  final String profileImgUrl;
  final Map<String, dynamic> userJson;
  final Map<String, String> response;

  String formatResponse(Map<String, String> response){
    StringBuffer result = StringBuffer('\n');

    for (MapEntry data in response.entries){
      result.write('\t\t\t\t');
      result.write(data.key);
      result.write(' = ');
      result.write(data.value);
      result.write('\n');
    }

    return result.toString();
  }

  String formatJson(Map<String, dynamic> json){
    return JsonEncoder.withIndent('    ').convert(json);
  }

  @override
  String toString() {
    String responseString = formatResponse(response);
    String prettyUserJson = formatJson(userJson);

    return 'AuthData {\n\n'
        '\t\ttoken: $accessToken\n\n'
        '\t\tuser id: $userID\n\n'
        '\t\tfirst name: $firstName\n\n'
        '\t\tlast name: $lastName\n\n'
        '\t\temail: $email\n\n'
        '\t\tprofile image: $profileImgUrl\n\n'
        '\t\tresponse: $responseString\n'
        '\t\tuser json: $prettyUserJson\n\n'
        '}';
  }
}