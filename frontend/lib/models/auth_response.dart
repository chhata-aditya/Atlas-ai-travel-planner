/// Mirrors the backend's AuthResponse DTO exactly (same field names,
/// just camelCase-to-camelCase since Jackson already sends camelCase JSON).
class AuthResponse {
  final String userId;
  final String name;
  final String email;
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  AuthResponse({
    required this.userId,
    required this.name,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
    );
  }
}
