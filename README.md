# visa

This is an **OAuth 2.0** package that makes it super easy to add third party authentication to flutter apps. It has support for **FB**, **Google**, **LinkedIn**, **Discord**, **Twitch**, **Github**, and **Spotify**, auth. It also provides support for adding new OAuth providers. You can read this [medium article](https://emmanuelolaojo.medium.com/so-you-want-social-login-oauth-2-0-with-flutter-38f51ab02bba?sk=0da0734ecad0df90d83db18c214d4ca9) for a brief introduction.

### Demo
<img src="https://drive.google.com/uc?export=view&id=1T_LX4CWsNNyEhWx64nMHtLJUST1papw0" alt="demo" width="550"></img>

## Reference
- [Getting Started](#getting-started)
- [Basic Usage](#basic-usage)
  * [Get a Provider](#step-1---get-a-provider)
  * [Authenticate](#step-2---authenticate)
  * [Use AuthData](#step-3---use-authdata)
  * [Rejoice!](#step-4---rejoice)
- [Debugging](#debugging)

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
import 'package:visa/linkedin.dart';
import 'package:visa/discord.dart';
import 'package:visa/twitch.dart';
import 'package:visa/spotify.dart';
```

## Basic Usage 

### Step 1 - Get a Provider.
There are 7 default OAuth providers at the moment:
```dart
  FacebookAuth()
  GoogleAuth({ String personFields })
  TwitchAuth()
  DiscordAuth()
  GithubAuth()
  LinkedInAuth()
  SpotifyAuth()
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
      body: FacebookAuth().visa.authenticate(
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

## Debugging
To get debug logs printed to the console, simply set the debug parameter on a provider to ```true```. Like this:
```dart
var fbAuth = FacebookAuth()
fbAuth.debug = true;
```

#### Happy OAuthing!

## Reference:

- [Getting Started](#getting-started)
- [Basic Usage](#basic-usage)
  * [Get a Provider](#step-1---get-a-provider)
  * [Authenticate](#step-2---authenticate)
  * [Use AuthData](#step-3---use-authdata)
  * [Rejoice!](#step-4---rejoice)
- [Debugging](#debugging)
