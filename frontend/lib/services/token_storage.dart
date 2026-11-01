import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps encrypted on-device storage for the access/refresh tokens.
/// Never store tokens in SharedPreferences — that's plain text, secure_storage isn't.
class TokenStorage {
  static const _accessTokenKey = 'atlas_access_token';
  static const _refreshTokenKey = 'atlas_refresh_token';

  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }
}
