import 'package:dio/dio.dart';

import '../core/config.dart';

/// Holds Directus session tokens obtained via Firebase token exchange.
class DirectusTokens {
  const DirectusTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresMs,
  });

  final String accessToken;
  final String refreshToken;

  /// Token lifetime in milliseconds (e.g. 900000 for 15 min).
  final int expiresMs;
}

/// Exchanges Firebase ID tokens for Directus session tokens via the
/// `directus-extension-bundle-firebase` endpoints and manages token refresh.
///
/// Lifecycle:
///  1. After Firebase sign-in, [AuthRepository] calls [linkAndAuthenticate]
///     with the Firebase ID token. This calls `/firebase/link` (creates
///     Directus user if needed) then `/firebase/auth` to obtain Directus
///     access + refresh tokens.
///  2. [DirectusClient] calls [getAccessToken] on every request. If the token
///     is about to expire, it is refreshed transparently via Directus
///     `/auth/refresh`.
///  3. On sign-out, [AuthRepository] calls [clear] to discard stored tokens.
class DirectusAuthService {
  DirectusAuthService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.directusBaseUrl,
                headers: {'Content-Type': 'application/json'},
                connectTimeout:
                    const Duration(milliseconds: AppConfig.connectionTimeoutMs),
                receiveTimeout:
                    const Duration(milliseconds: AppConfig.receiveTimeoutMs),
              ),
            );

  final Dio _dio;

  DirectusTokens? _tokens;
  DateTime? _expiresAt;

  /// Whether we currently hold valid Directus tokens.
  bool get hasTokens => _tokens != null;

  /// Returns a valid Directus access token, refreshing if necessary.
  ///
  /// Returns `null` when no tokens are available (user not linked yet).
  Future<String?> getAccessToken() async {
    if (_tokens == null) return null;

    // Refresh if token expires within the next 60 seconds.
    final now = DateTime.now();
    if (_expiresAt != null && _expiresAt!.difference(now).inSeconds < 60) {
      await _refresh();
    }

    return _tokens?.accessToken;
  }

  /// Links a Firebase user to Directus and obtains session tokens.
  ///
  /// [firebaseIdToken] — a fresh Firebase ID token.
  /// [firebaseUid] — the Firebase user UID.
  ///
  /// Throws on network or server errors — the caller ([AuthRepository])
  /// decides how to handle the failure.
  Future<void> linkAndAuthenticate({
    required String firebaseIdToken,
    required String firebaseUid,
  }) async {
    // Step 1: Link — creates Directus user if it doesn't exist.
    await _dio.post('/directus-extension-firebase-auth/link',
        data: {'id_token': firebaseIdToken});

    // Step 2: Reactivate if previously deleted (suspended) account.
    // Uses the static admin token because a suspended user can't auth.
    try {
      // Find user by firebase_uid
      final searchResponse = await _dio.get(
        '/users',
        queryParameters: {
          'filter[firebase_uid][_eq]': firebaseUid,
          'fields': 'id,status',
          'limit': '1',
        },
        options: Options(headers: {
          'Authorization': 'Bearer ${AppConfig.directusAccessToken}',
        }),
      );
      final users = (searchResponse.data?['data'] as List?) ?? [];
      if (users.isNotEmpty) {
        final user = users.first as Map<String, dynamic>;
        if (user['status'] == 'suspended') {
          final userId = user['id'];
          await _dio.patch(
            '/users/$userId',
            data: {'status': 'active'},
            options: Options(headers: {
              'Authorization': 'Bearer ${AppConfig.directusAccessToken}',
            }),
          );
        }
      }
    } catch (_) {
      // Best effort — continue with auth even if reactivation fails
    }

    // Step 3: Authenticate — get Directus tokens.
    final response = await _dio.post(
      '/directus-extension-firebase-auth/auth',
      data: {'uid': firebaseUid},
    );

    _storeTokens(response.data);
  }

  /// Discards stored tokens. Call on sign-out.
  void clear() {
    _tokens = null;
    _expiresAt = null;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _refresh() async {
    if (_tokens == null) return;

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': _tokens!.refreshToken, 'mode': 'json'},
      );
      _storeTokens(response.data);
    } on DioException {
      // Refresh failed — clear tokens so the next API call falls back to the
      // static access token and the user can re-authenticate.
      clear();
    }
  }

  void _storeTokens(dynamic responseData) {
    final data = responseData is Map && responseData.containsKey('data')
        ? responseData['data'] as Map<String, dynamic>
        : responseData as Map<String, dynamic>;

    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;
    final expiresMs = data['expires'] as int;

    _tokens = DirectusTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresMs: expiresMs,
    );
    _expiresAt = DateTime.now().add(Duration(milliseconds: expiresMs));
  }
}
