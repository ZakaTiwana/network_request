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

A powerful and comprehensive Dart package for simplifying **HTTP requests** and interacting with **RESTful APIs** in Flutter and Dart applications. This package provides an organized and efficient way to handle all your **networking** needs, leveraging the robust [http package](https://pub.dev/packages/http) for actual **network calls**. Experience streamlined **API integration**, enhanced **debugging capabilities**, and a developer-friendly approach to **data fetching**.

## ✨ Features

- 🚀 Easily set up and manage your `API services` and `network layers`.
- 🐞 Get detailed `logs` for both API requests and API responses. Essential for quick bug fixing and `troubleshooting`.
- 🐚 Get `cURL commands` for every network request for easy debugging and reproduction outside your application.
- 📦 Out-of-the-box support for common HTTP content types like `application/json`, `text/plain`, `x-www-form-urlencoded`, and `multipart/form-data`.
- 📶 Get download and upload progress in simple callbacks.

## 📝 Logging Feature
Best suited for JSON APIs. Get detailed logs for both requests and responses with a `terminal-pastable cURL command` for every request, enabling quick reproduction and testing outside your application. This feature significantly speeds up debugging and facilitates clear communication with your backend team.

![Network Request Log Example](https://raw.githubusercontent.com/ZakaTiwana/network_request/main/assets/log%20print%20example.png)

## 🚀 Getting started

In your Dart/Flutter project add the following line to `pubspec.yaml` file
```yaml
network_request:
    git: https://github.com/ZakaTiwana/network_request.git
```
Or from pub.dev use
```yaml
network_request: 0.0.4
```

## 💡 Usage
 
The `network_request` package simplifies the process of making HTTP requests. Extend the `NetworkRequest` class and implement the required overrides to define your API manager.

### 1. Extending `NetworkRequest`

First, create a class that extends `NetworkRequest`. This class will serve as your API manager, where you configure base URLs, default headers, error decoders, and logging.

```dart
import 'package:network_request/network_request.dart';

void main() {
  var network = MockAPIManger();
  network.fetchUser(1);
}

class MockAPIManger extends NetworkRequest {
  @override
  String get baseUrl => 'https://jsonplaceholder.typicode.com'; // Example base URL

  @override
  Future<Map<String, String>> get defaultHeader async => {
        HttpHeaders.contentTypeHeader: 'application/json',
      };

  // Optional: Add authorization headers if needed
  @override
  Future<Map<String, String>> get authorizationHeader async => {};

  // Optional: Implement custom error decoding
  @override
  Exception? errorDecoder(dynamic data) {
    try {
      return MockAPIError.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  // Essential: Integrate the logging feature
  // This method provides detailed logs, including cURL commands
  @override
  void log(String logString) {
    print(logString);
  }

  // Optional: Implement refresh token logic
  @override
  Future<bool> tryToReauthenticate() async {
    return false;
  }
}
```

### 2. Defining API Endpoints
After setting up your `NetworkRequest` extension, you can define specific API endpoints using an extension (or any other perfered way such as passing this `MockAPIManger` object to your service class) on your manager class.


```dart
extension on MockAPIManger {
  Future<MockAPIUser> fetchUser(int id) {
    return call(
      Request(
        method: Method.GET,
        path: '/todos/$id', // Example path
        decode: (json) => MockAPIUser.fromJson(json),
      ),
    );
  }
}
```

### 3. Example Models for Decoding

To decode your API responses, you'll typically define data models.

```dart
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

Find more detailed examples in the `example` folder.

**Note:** A mock server API with Dart was also created to test `network_request` functionality. You can find its [source code here](https://github.com/ZakaTiwana/network_request_mock_api)

## 📚 Additional Information

Feel free to leave any suggestions :) 
