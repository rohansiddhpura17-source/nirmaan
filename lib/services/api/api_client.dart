import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/environment_config.dart';
import '../../core/errors/exceptions.dart';
import '../../shared/models/api_response.dart';

class ApiClient {
  final http.Client _client;
  String? _authToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
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
      final response = await _client
          .get(uri, headers: _buildHeaders())
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
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
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
      final message = jsonBody['message'] as String? ?? 'An error occurred';
      throw ServerException(message, statusCode: response.statusCode);
    }
  }
}
