import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/environment_config.dart';
import '../../core/errors/exceptions.dart';
import '../../shared/models/api_response.dart';

class ApiClient {
  final http.Client _client;
  String? _authToken;
  Future<String?> Function()? _tokenProvider;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void setTokenProvider(Future<String?> Function()? provider) {
    _tokenProvider = provider;
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    String? token = _authToken;
    if (_tokenProvider != null) {
      try {
        final fresh = await _tokenProvider!();
        if (fresh != null && fresh.isNotEmpty) {
          token = fresh;
          _authToken = fresh;
        }
      } catch (_) {
        // Fall back to stored _authToken
      }
    }

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final baseUrl = EnvironmentConfig.apiBaseUrl;
    final url = '$baseUrl$path';
    return Uri.parse(url).replace(queryParameters: queryParameters);
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      final headers = await _buildHeaders();
      final response = await _client
          .get(uri, headers: headers)
          .timeout(EnvironmentConfig.receiveTimeout);

      return _processResponse<T>(response, fromJson);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders();
      if (extraHeaders != null) {
        headers.addAll(extraHeaders);
      }
      final response = await _client
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(EnvironmentConfig.receiveTimeout);

      return _processResponse<T>(response, fromJson);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders();
      if (extraHeaders != null) {
        headers.addAll(extraHeaders);
      }
      final response = await _client
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(EnvironmentConfig.receiveTimeout);

      return _processResponse<T>(response, fromJson);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders();
      final response = await _client
          .delete(uri, headers: headers)
          .timeout(EnvironmentConfig.receiveTimeout);

      return _processResponse<T>(response, fromJson);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  ApiResponse<T> _processResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    final Map<String, dynamic> jsonBody;
    try {
      jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ServerException(
        'Invalid server response format: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(jsonBody, fromJson);
    } else {
      String? message = jsonBody['message'] as String?;
      if (message == null && jsonBody['error'] != null) {
        if (jsonBody['error'] is Map) {
          message = (jsonBody['error'] as Map)['message'] as String?;
        } else if (jsonBody['error'] is String) {
          message = jsonBody['error'] as String;
        }
      }
      throw ServerException(message ?? 'An error occurred', statusCode: response.statusCode);
    }
  }
}
