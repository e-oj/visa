# visa

Easy third party authentication for flutter apps.

## Getting Started

Install the visa package

## API

### Basic Usage 

#### Step 1 - Get a Provider.
There are 6 default OAuth providers at the moment:
<ul>
  FacebookAuth()<br/>
  TwitterAuth()<br/>
  TwitchAuth()<br/>
  DiscordAuth()<br/>
  GithubAuth()<br/>
  GoogleAuth({ String personFields })
</ul>

#### AuthProvider().visa.authenticate
Super simple. Returns a WebView that's been set up for authentication. 
```dart
visa.authenticate({
  bool newSession=false // If true, user has to reenter username and password even if they've logged in before
  String clientSecret, // Some providers (GitHub for instance) require the OAuth client secret (from developer portal).
  @required String clientID, // OAuth client ID (from developer portal)
  @required String redirectUri, // OAuth redirect url (from developer portal) 
  @required String state, // OAuth state string can be whatever you want.
  @required String scope, // OAuth scope (Check provider's API docs for allowed scopes)
  @required Function onDone, // Callback function which expects an AuthData object.
});
```

Here's an example:
```Dart
import 'package:visa/auth-data.dart';
import 'package:visa/fb.dart';

class AuthPage extends StatelessWidget {
  AuthPage({Key key, @required this.thirdParty}): super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      
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
  
  done(AuthData authData){
    print(authData);
    
    /// You can pass the [AuthData] object to a 
    /// post authentication screen. It contaions 
    /// all the user and OAuth data collected during
    /// the authentication process.
    Navigator.pushReplacementNamed(
        context, '/complete-profile', arguments: authData
    );
  };
}

```
