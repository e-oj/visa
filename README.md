# visa

Easy third party authentication for flutter apps. This README is under construction.

## Getting Started

Install the visa package

## Basic Usage 

### Step 1 - Get a Provider.
Implementing new providers is covered under *Advanced Usage*.
There are 6 default OAuth providers at the moment:
```dart
  FacebookAuth()
  TwitterAuth()
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
  AuthPage({Key key}): super(key: key);
  
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
      ),
    );
  }
}
```
In the sample above, the named parameter <i>OnDone</i> is a callback which recieves a single arument: an AuthData object, which contains all the authentication info. We'll look at AuthData in the next section but here's how you would pass an AuthData object to the next screen via the <i>onDone</i> callback.

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
