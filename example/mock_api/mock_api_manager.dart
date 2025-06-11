import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:network_request/network_request.dart';
import 'package:network_request/src/model/captured_response.dart';

import 'models/mock_api_error.dart';

class MockAPIManger extends NetworkRequest {
  @override
  Future<Map<String, String>> get authorizationHeader async => {};

  @override
  String get baseUrl => 'localhost:8080';

  @override
  Future<Map<String, String>> get defaultHeader async => {
        HttpHeaders.contentTypeHeader: 'application/json',
      };

  @override
  Exception? errorDecoder(CapturedResponse response) {
    try {
      return MockAPIError.fromJson(jsonDecode(response.body));
    } catch (_) {
      return null;
    }
  }

  @override
  void log(String logString) {
    print(logString);
  }

  /// This is just an example on how we can use `tryToReauthenticate` logic.
  @override
  Future<bool> tryToReauthenticate({dynamic client}) async {
    final presistClient = client as http.Client;

    var authService = AuthTokenData.dummy();
    final refreshToken = authService.refreshToken;

    final result = await call<AuthTokenData>(
      Request(
        method: Method.POST,
        path: '/auth/refresh',
        body: {
          'refreshToken': refreshToken,
        },
        decode: (json) => AuthTokenData.fromJson(json),

        /// Important Remeber to set it to `true`
        isRefreshRequest: true,
      ),

      /// If we send the presistClient the same client will be used without
      /// closing to trigger the previous API call that had failed and
      /// triggered the unautorized / refresh token flow
      presistClient: presistClient,
    );

    return result.token.isNotEmpty;
  }

  @override
  bool get isRequestHttps => false;
}

class AuthTokenData {
  final String token;
  final String refreshToken;

  const AuthTokenData({
    required this.token,
    required this.refreshToken,
  });

  factory AuthTokenData.dummy() => AuthTokenData(
        token: 'token',
        refreshToken: 'refreshToken',
      );

  factory AuthTokenData.fromJson(dynamic data) {
    var json = Map<String, String>.from(data);
    return AuthTokenData(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}
