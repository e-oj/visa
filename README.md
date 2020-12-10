# visa

Easy third party authentication for flutter apps.

## Getting Started

Install the visa package

## API

### Basic Usage 
#### AuthProvider().visa.authenticate
Super simple. Returns a WebView that's been set up for authentication. 
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
