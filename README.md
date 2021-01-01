# visa
This is an **OAuth 2.0** package that makes it super easy to add third party authentication to flutter apps. It has support for **FB**, **Google**, **Discord**, **Twitch**, and **Github** auth. It also provides support for adding new OAuth providers.

### Demo
<img src="https://drive.google.com/uc?export=view&id=1KRz_GgRGqiT7rkycPRgdQvjF4u7G7pg5" alt="demo" width="550"></img>

## Reference
- [Getting Started](#getting-started)
- [Basic Usage](#basic-usage)
  * [Get a Provider](#step-1---get-a-provider)
  * [Authenticate](#step-2---authenticate)
  * [Use AuthData](#step-3---use-authdata)
  * [Rejoice!](#step-4---rejoice)
- [Advanced Usage](#advanced-usage)
  * [Creating an OAuth Provider](#creating-an-oauth-provider)
  * [Constructor](#constructor)
  * [authData Function](#authdata-function)
  * [Handling Intermediate Steps](#handling-intermediate-steps)

## Getting Started

### Install visa:

- Open your pubspec.yaml file and add ```visa:``` under dependencies.
- From the terminal: Run flutter pub get.
- Add the relevant import statements in the Dart code.
```dart
// Possible imports:
import 'package:visa/fb.dart';
import 'package:visa/google.dart';
import 'package:visa/github.dart';
import 'package:visa/discord.dart';
import 'package:visa/twitch.dart';
import 'package:visa/auth-data.dart';
import 'package:visa/engine/oauth.dart';
import 'package:visa/engine/simple-auth.dart';
import 'package:visa/engine/visa.dart';
```

## Basic Usage 

### Step 1 - Get a Provider.
Implementing new providers is covered under *Advanced Usage*.
There are 6 default OAuth providers at the moment:
```dart
  FacebookAuth()
  TwitchAuth()
  DiscordAuth()
  GithubAuth()
  GoogleAuth({ String personFields })
```
#### Create a new instance:
```dart
FacebookAuth fbAuth = FacebookAuth();
SimpleAuth visa = fbAuth.visa;
```

### Step 2 - Authenticate.
As shown above, each provider contains a **SimpleAuth** instance called **visa**.
The SimpleAuth class has only one public function: **authenticate()**. It takes
in all the necessary OAuth credentials and returns a **WebView** that's been set 
up for authentication. 

#### SimpleAuth.authenticate({ params })
```dart
WebView authenticate({
  bool newSession=false // If true, user has to reenter username and password even if they've logged in before
  String clientSecret, // Some providers (GitHub for instance) require the OAuth client secret (from developer portal).
  @required String clientID, // OAuth client ID (from developer portal)
  @required String redirectUri, // OAuth redirect url (from developer portal) 
  @required String state, // OAuth state string can be whatever you want.
  @required String scope, // OAuth scope (Check provider's API docs for allowed scopes)
  @required Function onDone, // Callback function which expects an AuthData object.
});
```

Here's how you would use this function:
```Dart
import 'package:visa/auth-data.dart';
import 'package:visa/fb.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Simply Provide all the necessary credentials
      body: FaceBookAuth().visa.authenticate(
          clientID: '139732240983759',
          redirectUri: 'https://www.e-oj.com/oauth',
          scope: 'public_profile,email',
          state: 'fbAuth',
          onDone: done
      )
    );
  }
}
```
In the sample above, the named parameter **onDone** is a callback which recieves a single arument: an [AuthData](#step-3---use-authdata) object, which contains all the authentication info. We'll look at [AuthData](#step-3---use-authdata) in the next section but here's how you would pass an [AuthData](#step-3---use-authdata) object to the next screen via the **onDone** callback.

```dart
done(AuthData authData){
  print(authData);

  /// You can pass the [AuthData] object to a 
  /// post-authentication screen. It contaions 
  /// all the user and OAuth data collected during
  /// the authentication process. In this example,
  /// our post-authentication screen is "complete-profile".
  Navigator.pushReplacementNamed(
      context, '/complete-profile', arguments: authData
  );
}
```

### Step 3 - Use AuthData.
The AuthData object contains all the information collected throughout the authentication process. It contains both user data and authentication metadata. As shown in the code sample above, this object is passed to the "authenticate" callback function. Let's have a look at it's structure:
```dart
class AuthData {
  final String userID; // User's profile id
  final String firstName; // User's first name
  final String lastName; // User's last name
  final String email; // User's email
  final String profileImgUrl; // User's profile image url
  final Map<String, dynamic> userJson; // Full returned user json
  final Map<String, String> response; // Full returned auth response.
  final String clientID; // OAuth client id
  final String accessToken; // OAuth access token
}
```
It provides shortcuts to access **common user properties** (userId, name, email, profile image) as well as the **accessToken**. The complete, returned user json can be accessed through the **userJson** property and you can access the full authentication response (the response in which we recieved an API access token) through the **response** property. 

### Step 4 - Rejoice!
You have successfully implemented third party auth in your app! you're one step closer to launch. Rejoice!

## Advanced Usage
You might need an OAuth provider that's not currently supported. The Visa interface and the SimpleAuth class make this possible. Have a look at the Visa interface:
```dart
/// Visa interface
abstract class Visa{
  /// a [SimpleAuth] instance
  SimpleAuth visa;

  /// This function combines information
  /// from the user [json] and auth response [data]
  /// to build an [AuthData] object.
  AuthData authData(
      Map<String, dynamic> json,
      Map<String, String> data
  );
}
```
An here's the SimpleAuth constructor:
```dart
class SimpleAuth{

  /// Creates a new instance based on the given OAuth
  /// baseUrl and getAuthData function.
  const SimpleAuth ({
    @required this.baseUrl, @required this.getAuthData
  });
  
  
  final String baseUrl; // OAuth base url
  
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
}
```

### Creating an OAuth Provider
Adding a new provider simply means creating a new class that implements the visa interface. You can check out the source code for various implementations but here's the full Discord implementation as a reference.

#### Constructor:
```dart
/// Enables Discord [OAuth] authentication
class DiscordAuth implements Visa{
  // User profile API endpoint.
  final baseUrl = 'https://discord.com/api/oauth2/authorize';
  SimpleAuth visa;

  DiscordAuth(){
    visa = SimpleAuth(
        baseUrl: baseUrl,
        /// Sends a request to the user profile api
        /// endpoint. Returns an AuthData object.
        getAuthData: (Map <String, String> data) async {
          var token = data[OAuth.TOKEN_KEY];
          var baseProfileUrl = 'https://discord.com/api/users/@me';
          var profileResponse = await http.get(baseProfileUrl, headers: {
            'Authorization': 'Bearer $token',
          });
          var profileJson = json.decode(profileResponse.body);

          return authData(profileJson, data);
        }
    );
  }
}
```

#### authData function:
```dart
/// This function combines information
/// from the user [json] and auth response [data]
/// to build an [AuthData] object.
@override
AuthData authData(
    Map<String, dynamic> json,
    Map<String, String> data
){
  final String accessToken = data[OAuth.TOKEN_KEY];
  final String userId = json['id'] as String;
  final String avatar = json['avatar'] as String;
  final String profileImgUrl = 'https://cdn.discordapp.com/'
      'avatars/$userId/$avatar.png';

  return AuthData(
      clientID: data['clientID'],
      accessToken: accessToken,
      userID: userId,
      email: json['email'] as String,
      profileImgUrl: profileImgUrl,
      response: data,
      userJson: json
  );
}
```

#### Handling Intermediate Steps:
In some cases, the intitial request to an OAuth endpoint returns a code instead of an access token. This code has to be 
exchanged for an actual api access token. Github, for instance, uses this OAuth flow and the code above needs a few adjustments to accomodate
the intermediate step. Let's take a look at the first few lines of the getAuthData function created in the Github constructor:
```dart
getAuthData(Map <String, String> data) async {
    // This function retrieves the access token and
    // adds it to the data HashMap.
    await _getToken(data);
    
    // We can now access the token
    var token = data[OAuth.TOKEN_KEY];
    
    // ... Make api requests/retrieve user data  with the token
}
```
_getToken makes the request to exchange an OAuth code for an access token.

```dart
  /// Github's [OAuth] endpoint returns a code
  /// which can be exchanged for a token. This
  /// function performs the exchange and adds the
  /// returned data to the response [data] map.
  _getToken(Map<String, String> data) async {
    var tokenEndpoint = 'https://github.com/login/oauth/access_token';
    var tokenResponse = await http.post(tokenEndpoint,
        headers: {'Accept': 'application/json',},
        body: {
          'client_id': data[OAuth.CLIENT_ID_KEY],
          'client_secret': data[OAuth.CLIENT_SECRET_KEY],
          'code': data[OAuth.CODE_KEY],
          'redirect_uri': data[OAuth.REDIRECT_URI_KEY],
          'state': data[OAuth.STATE_KEY]
        });

    var responseJson = json.decode(tokenResponse.body);
    var tokenTypeKey = 'token_type';

    data[OAuth.TOKEN_KEY] = responseJson[OAuth.TOKEN_KEY] as String;
    data[OAuth.SCOPE_KEY] = responseJson[OAuth.SCOPE_KEY] as String;
    data[tokenTypeKey] = responseJson[tokenTypeKey] as String;
  }
}
```
And that's how to handle intermedite OAuth steps! If you end up creating a new provider, feel free to open a PR and I'll be happy to add it to the project.
Happy OAuthing!

## Reference:

- [Getting Started](#getting-started)
- [Basic Usage](#basic-usage)
  * [Get a Provider](#step-1---get-a-provider)
  * [Authenticate](#step-2---authenticate)
  * [Use AuthData](#step-3---use-authdata)
  * [Rejoice!](#step-4---rejoice)
- [Advanced Usage](#advanced-usage)
  * [Creating an OAuth Provider](#creating-an-oauth-provider)
  * [Constructor](#constructor)
  * [authData Function](#authdata-function)
  * [Handling Intermediate Steps](#handling-intermediate-steps)
  
  
