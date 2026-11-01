import 'package:dio/dio.dart';
import '../core/api_constants.dart';
import 'token_storage.dart';

/// Single shared Dio instance for the whole app. Every screen/service
/// should use ApiClient.instance instead of creating its own Dio() —
/// that's how the auth header gets attached automatically everywhere.
class ApiClient {
  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  final TokenStorage _tokenStorage = TokenStorage();

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Don't attach a token to register/login themselves — there isn't one yet.
          final isAuthEndpoint = options.path.contains('/auth/');
          if (!isAuthEndpoint) {
            final token = await _tokenStorage.getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Token refresh-on-401 logic goes here later, once protected
          // endpoints exist. For now, just pass the error through.
          handler.next(error);
        },
      ),
    );
}
