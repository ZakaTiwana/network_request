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
- 🛑 Cancel/abort in-flight requests using `abortTrigger` (requires `http >= 1.5.0`).

## 📝 Logging Feature
Best suited for JSON APIs. Get detailed logs for both requests and responses with a `terminal-pastable cURL command` for every request, enabling quick reproduction and testing outside your application. This feature significantly speeds up debugging and facilitates clear communication with your backend team.

![Network Request Log Example](https://raw.githubusercontent.com/ZakaTiwana/network_request/main/assets/log%20print%20example.png)

## 🚀 Getting started

In your Dart/Flutter project add the following line to `pubspec.yaml` file

```yaml
network_request: 0.3.0
```

Or get the latest from github

```yaml
network_request:
    git: https://github.com/ZakaTiwana/network_request.git
```


## 💡 Usage
 
The `network_request` package simplifies the process of making HTTP requests. Extend the `NetworkRequest` class and implement the required overrides to define your API manager.

### 1. Extending `NetworkRequest`

First, create a class that extends `NetworkRequest`. This class will serve as your API manager, where you configure base URLs, default headers, error decoders, and logging.

```dart
import 'package:network_request/network_request.dart';

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
  // this is triggered in the case if status code is not in `successfulResponsesStatusCode`
  // which defaults to 200-299
  @override
  Exception? errorDecoder(CapturedResponse response) {
    try {
      return MockAPIError.fromJson(jsonDecode(response.body));
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
  // if you don't want to implement just send `false`
  @override
  Future<bool> tryToReauthenticate() async {
    final presistClient = client as http.Client;

    AuthTokenData authService = .. // for getting the refreshToken
    final refreshToken = authService.refreshToken;

    final result = await call<AuthTokenData>(
      Request(
        method: Method.POST,
        path: '/auth/token/refresh',
        version: 1,
        body: {
          'refreshToken': refreshToken,
        },
        decode: (json) => AuthTokenData.fromJson(json),

        /// Important Remeber to set it to `true`
        isRefreshRequest: true,
      ),

      // If we send the presistClient the same client will be used without
      // closing to trigger the previous API call that had failed and
      // triggered the unautorized / refresh token flow
      presistClient: presistClient,
    );

    // save the new token somewhere for future API calls.
    result.token...
    result.refreshToken...
    
    return true;
  }
}
```

There are order properties and methods you can use to further customize the API Manager extended from `NetworkRequest` such as.
- `initalizeClient` override it, to inialize a custom `http.Client`.
- `isRequestHttps` for letting the manager know if this a `http` or `https` connection.
- `trimJsonLogs`, `enableLog` & `enableCurlLog` for configuring logging.
- `unauthorizedStatusCode` a list of status code which will trigger `tryToReauthenticate`.
- `encodeBody` & `decodeBody` to add custom logic for encoding request body and/or decoding response result.

**Note:** Details are mentioned on the method comments.

### 2. Defining API Endpoints
To trigger an API endpoint, we have the method `call` in our `NetworkRequest`.
`call` takes a `Request` object in which we can define all the endpoint related information. such as what http `method` we are using, whats its `path`, what are the `query` parameters or its `body` if any & how to `decode` its OK response's body.

After setting up your `NetworkRequest` extension, you can define specific API endpoints using an extension on your manager class or any other perfered way such as passing this `MockAPIManger` object to your service class.


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

Call the endpoint method where appropriate.

```dart
void main() {
  var network = MockAPIManger();
  network.fetchUser(1);
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

### ⛔ Aborting requests (http 1.5.0)

The `http` package added native abort support in 1.5.0 via the `Abortable` API. This library exposes it through `Request.abortTrigger` so you can cancel any in-flight request.

- **How it works**:
  - Pass a `Future<void>` to `abortTrigger` when calling `NetworkRequest.call`.
  - Complete that future to abort the request.
  - Supported clients (e.g., `IOClient`, `BrowserClient`, `RetryClient`) observe the trigger and cancel sending/streaming.
  - The await will throw `http.RequestAbortedException` when abortion occurs.

- **Docs**: See the official `http` docs: [Aborting requests](https://pub.dev/packages/http#aborting-requests).

#### Basic abort example

```dart
import 'dart:async';
import 'package:network_request/network_request.dart';
import 'package:http/http.dart' as http;

Future<void> exampleAbort(NetworkRequest network) async {
  final abort = Completer<void>();

  // Abort shortly after starting (demo)
  Future<void>.delayed(const Duration(milliseconds: 100))
      .then((_) => abort.complete());

  try {
    await network.call(
      Request<void>(
        method: Method.GET,
        path: '/posts',
        decode: (_) {},
        abortTrigger: abort.future,
      ),
    );
  } on http.RequestAbortedException {
    // Handle cancellation gracefully
  }
}
```

### 🔎 All Functionalities at a glance

#### Request configuration (passed to `call`)
- `Request.method`: HTTP method (`Method` enum).
- `Request.path`: Endpoint path (with/without leading `/`).
- `Request.version`: Optional API version, prepended as `/v{n}`.
- `Request.query`: Query parameters `Map<String, String>`.
- `Request.headers`: Request-specific headers (override defaults).
- `Request.body`: JSON map, URL-encoded map, or plain string (based on `Content-Type`).
- `Request.files`: `List<http.MultipartFile>` for multipart/form-data uploads.
- `Request.encoding`: Request body encoding (default `utf8`).
- `Request.isRefreshRequest`: Mark as refresh-token call to avoid loops and custom errors.
- `Request.downloadProgress`: Callback `(bytes, totalBytes, percent)` for download progress.
- `Request.uploadProgress`: Callback `(bytes, totalBytes, percent)` for upload progress.
- `Request.abortTrigger`: Complete this `Future<void>` to cancel the in-flight request (requires `http >= 1.5.0`).

#### NetworkRequest class functionalities

- `baseUrl`: Domain for all requests (exclude scheme), e.g., `api.example.com`.
- `isRequestHttps`: Toggle between https (true) and http (false) URL building.
- `initalizeClient()`: Override to provide a custom `http.Client` (default: `RetryClient(http.Client())`).
- `defaultHeader`: Async default headers applied to every request.
- `authorizationHeader`: Async authorization headers applied to every request.
- `call<R>(Request<R> request, {http.Client? presistClient})`: Executes a request with logging, progress, multipart, abort, error decoding, and optional persistent client.
- `successfulResponsesStatusCode`: List of status codes considered success (default `200..299`).
- `unauthorizedStatusCode`: Status codes that trigger `tryToReauthenticate` (default `[401]`).
- `tryToReauthenticate({client})`: Implement refresh-token logic; return `true` to retry the original request.
- `errorDecoder(CapturedResponse)`: Return a custom `Exception` from an error response or `null` to fall back to `APIException`.
- `url(Request)`: Builds the final `Uri` from `baseUrl`, path, optional version `/v{n}`, and `query` map.
- `encodeBody(dynamic, {Encoding encoding = utf8})`: Encodes request body based on `Content-Type` (JSON, text/plain, x-www-form-urlencoded).
- `decodeBody(String)`: Decodes JSON, returns raw string if not JSON.
- `enableLog` / `enableCurlLog` / `trimJsonLogs`: Toggle request/response logging, cURL logging, and compact JSON logs.
- `log(String)`: Output logs (override to route to your logger).
- `logFormattedJson(dynamic)`: Pretty-prints JSON for logs (with trimming if long).

## 📚 Additional Information

Feel free to leave any suggestions :) 
