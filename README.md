<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A package to send network request in an organized manner. [http package](https://pub.dev/packages/http) is used to make actual request

## Features

- A easy way to create Network Service
- Logs for Request, Response
- cURL command as logs
- Can handel `application/json`, `text/plain`, `x-www-form-urlencoded` and `multipart/form-data` out of the box

## Getting started

In your Dart/Flutter project add the following line to `pubspec.yaml` file
```yaml
network_request:
    git: https://github.com/ZakaTiwana/network_request.git
```
 
## Usage
 
Extend the `NetworkRequest` class and implement the required overrides and then add function to call an endpoint. For example
```dart
void main() {
  var network = MockAPIManger();
  network.fetchUser(1);
}

class MockAPIManger extends NetworkRequest {
  // Can add authorization headers. Like basic Auth
  // or Bearer token
  @override
  Map<String, String> get authorizationHeader => {};

  @override
  String get baseUrl => 'localhost:8080';

  @override
  Map<String, String> get defaultHeader => {
        HttpHeaders.contentTypeHeader: 'application/json',
      };

  // If response is outside of status 200 to 299
  // then tries to parse response body too this Exception
  @override
  Exception? errorDecoder(dynamic data) {
    try {
      return MockAPIError.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  // Gives a well formatted log of Request and Response
  // Also cURL command as logs are passed here
  @override
  void log(String logString) {
    print(logString);
  }

  // Can impplement refresh token logic here
  @override
  Future<bool> tryToReauthenticate() async {
    return false;
  }
}

extension on MockAPIManger {
  Future<MockAPIUser> fetchUser(int id) {
    return call(
      Request(
        method: Method.GET,
        path: '/user/$id',
        decode: (json) => MockAPIUser.fromJson(json),
      ),
    );
  }
}

class MockAPIError implements Exception {
  final int statusCode;
  final String message;
  const MockAPIError(this.message, this.statusCode);

  @override
  String toString() {
    return 'Status Code: $statusCode, message: $message ';
  }

  factory MockAPIError.fromJson(Map<String, dynamic> json) {
    return MockAPIError(json['message'], json['statusCode']);
  }
}

class MockAPIUser {
  const MockAPIUser({
    required this.id,
    required this.name,
    required this.profilePic,
  });
  final int id;
  final String name;
  final String? profilePic;

  factory MockAPIUser.fromJson(Map<String, dynamic> json) {
    return MockAPIUser(
      id: json['id'],
      name: json['name'],
      profilePic: json['profilePic'],
    );
  }
}
```

Find detail examples in `example` folder
**Note:** A mock server API with dart was also created to test `network_request` functionality. you can find its [source code here](https://github.com/ZakaTiwana/network_request_mock_api)
## Additional information

Feel free to leave any suggestions :) 
