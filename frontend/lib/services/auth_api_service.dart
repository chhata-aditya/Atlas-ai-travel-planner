import 'package:dio/dio.dart';
import '../core/api_constants.dart';
import '../models/auth_response.dart';
import 'api_client.dart';
import 'token_storage.dart';

/// Thrown when the backend rejects a request with a meaningful message
/// (wrong password, duplicate email, etc.) — catch this in your UI to
/// show the actual error instead of a generic "something went wrong."
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthApiService {
  final Dio _dio = ApiClient.instance.dio;
  final TokenStorage _tokenStorage = TokenStorage();

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );
      final auth = AuthResponse.fromJson(response.data);
      await _tokenStorage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
      return auth;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final auth = AuthResponse.fromJson(response.data);
      await _tokenStorage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
      return auth;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<AuthResponse> oauthLogin({
    required String provider,
    required String email,
    String? name,
    String? idToken,
    String? avatarUrl,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.oauth,
        data: {
          'provider': provider,
          'email': email,
          if (name != null && name.isNotEmpty) 'name': name,
          if (idToken != null && idToken.isNotEmpty) 'idToken': idToken,
          if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
        },
      );
      final auth = AuthResponse.fromJson(response.data);
      await _tokenStorage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
      return auth;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
  }


  ApiException _mapError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      String? backendMsg;

      if (data is Map) {
        if (data['message'] != null && data['message'].toString().trim().isNotEmpty) {
          backendMsg = data['message'].toString().trim();
        } else if (data['error'] != null && data['error'].toString().trim().isNotEmpty) {
          backendMsg = data['error'].toString().trim();
        } else if (data['detail'] != null && data['detail'].toString().trim().isNotEmpty) {
          backendMsg = data['detail'].toString().trim();
        }
      } else if (data is String && data.trim().isNotEmpty) {
        backendMsg = data.trim();
      }

      // If backend gave a descriptive message, use it
      if (backendMsg != null &&
          backendMsg.isNotEmpty &&
          backendMsg.toLowerCase() != 'unauthorized' &&
          backendMsg.toLowerCase() != 'forbidden' &&
          backendMsg.toLowerCase() != 'bad request') {
        return ApiException(backendMsg, statusCode: statusCode);
      }

      // Contextual fallbacks for standard HTTP codes
      switch (statusCode) {
        case 401:
          return ApiException(
            'Incorrect email or password. Please check your credentials or create an account.',
            statusCode: statusCode,
          );
        case 404:
          return ApiException(
            'No account found with this email. Please register for a new account.',
            statusCode: statusCode,
          );
        case 409:
          return ApiException(
            'An account with this email already exists. Please sign in instead.',
            statusCode: statusCode,
          );
        case 400:
          return ApiException(
            backendMsg ?? 'Invalid information provided. Please check the fields.',
            statusCode: statusCode,
          );
        case 403:
          return ApiException(
            'Access denied. Please verify your login credentials.',
            statusCode: statusCode,
          );
        default:
          return ApiException(
            backendMsg ?? 'Something went wrong. Please try again.',
            statusCode: statusCode,
          );
      }
    }

    // No response at all -- server unreachable, wrong IP, or phone off network
    return ApiException(
      'Could not reach the server. Check your connection and try again.',
    );
  }
}
