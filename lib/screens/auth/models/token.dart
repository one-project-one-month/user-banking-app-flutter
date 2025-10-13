import 'package:equatable/equatable.dart';

class Token extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final DateTime? expiresAt;

  const Token({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresAt,
  });

  bool get isExpired {
    final exp = expiresAt;
    if (exp == null) return false;
    return DateTime.now().isAfter(exp);
  }

  Duration? get timeToExpiry {
    final exp = expiresAt;
    if (exp == null) return null;
    return exp.difference(DateTime.now());
  }

  String get authorizationHeader => '$tokenType $accessToken';

  Token copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    DateTime? expiresAt,
  }) {
    return Token(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }


  factory Token.fromJson(Map<String, dynamic> json) {
    final access = json['access_token'] ?? json['accessToken'] ?? json['token'] ?? json['jwt'];
    if (access is! String || access.isEmpty) {
      throw ArgumentError('Token.fromJson: access token not found in payload');
    }

    final tokenType = (json['token_type'] ?? json['tokenType'] ?? 'Bearer').toString();
    final refresh = json['refresh_token'] ?? json['refreshToken'];
    DateTime? expiresAt;

    if (json.containsKey('expires_at') || json.containsKey('expiresAt') || json.containsKey('expiry')) {
      expiresAt = _parseExpiresAt(json['expires_at'] ?? json['expiresAt'] ?? json['expiry']);
    } else if (json.containsKey('expires_in') || json.containsKey('expiresIn')) {
      final seconds = _parseInt(json['expires_in'] ?? json['expiresIn']);
      if (seconds != null) {
        expiresAt = DateTime.now().add(Duration(seconds: seconds));
      }
    }

    return Token(
      accessToken: access,
      refreshToken: (refresh is String) ? refresh : null,
      tokenType: tokenType,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      'token_type': tokenType,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }

  static DateTime? _parseExpiresAt(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
    
      if (value > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value > 1000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
   
      return DateTime.now().add(Duration(seconds: value));
    }
    if (value is num) {
      final intVal = value.toInt();
      return _parseExpiresAt(intVal);
    }
    if (value is String) {
      final intVal = int.tryParse(value);
      if (intVal != null) {
        return _parseExpiresAt(intVal);
      }
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType, expiresAt];

  @override
  String toString() {
    final tokenPreview = accessToken.length > 8
        ? '${accessToken.substring(0, 4)}...${accessToken.substring(accessToken.length - 4)}'
        : accessToken;
    return 'Token(type: $tokenType, access: $tokenPreview, refresh: ${refreshToken != null ? '***' : 'null'}, expiresAt: $expiresAt)';
  }
}
