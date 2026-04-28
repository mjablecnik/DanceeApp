import '../../i18n/strings.g.dart';

/// Resolves an auth error translation key emitted by [AuthRepository.mapFirebaseError]
/// (and stored in [AuthState.error.message]) into a user-visible translated string.
///
/// Falls back to the generic error message for unknown or unrecognised keys,
/// including any raw exception messages that are not translation keys.
String resolveAuthErrorKey(String key) {
  switch (key) {
    case 'auth.errors.invalidCredential':
      return t.auth.errors.invalidCredential;
    case 'auth.errors.userDisabled':
      return t.auth.errors.userDisabled;
    case 'auth.errors.emailAlreadyInUse':
      return t.auth.errors.emailAlreadyInUse;
    case 'auth.errors.weakPassword':
      return t.auth.errors.weakPassword;
    case 'auth.errors.tooManyRequests':
      return t.auth.errors.tooManyRequests;
    case 'auth.errors.networkError':
      return t.auth.errors.networkError;
    case 'auth.errors.generic':
      return t.auth.errors.generic;
    default:
      return t.auth.errors.generic;
  }
}

/// Resolves an API error translation key emitted by [DirectusClient] (via
/// [ApiException.message]) into a user-visible translated string.
///
/// Falls back to the generic API error message for unknown keys.
String resolveApiErrorKey(String key) {
  switch (key) {
    case 'api.errors.connectionTimeout':
      return t.api.errors.connectionTimeout;
    case 'api.errors.receiveTimeout':
      return t.api.errors.receiveTimeout;
    case 'api.errors.sendTimeout':
      return t.api.errors.sendTimeout;
    case 'api.errors.noConnection':
      return t.api.errors.noConnection;
    case 'api.errors.requestCancelled':
      return t.api.errors.requestCancelled;
    case 'api.errors.badRequest':
      return t.api.errors.badRequest;
    case 'api.errors.unauthorized':
      return t.api.errors.unauthorized;
    case 'api.errors.forbidden':
      return t.api.errors.forbidden;
    case 'api.errors.notFound':
      return t.api.errors.notFound;
    case 'api.errors.conflict':
      return t.api.errors.conflict;
    case 'api.errors.internalServerError':
      return t.api.errors.internalServerError;
    case 'api.errors.badGateway':
      return t.api.errors.badGateway;
    case 'api.errors.serviceUnavailable':
      return t.api.errors.serviceUnavailable;
    case 'api.errors.clientError':
      return t.api.errors.clientError;
    case 'api.errors.serverError':
      return t.api.errors.serverError;
    case 'api.errors.generic':
      return t.api.errors.generic;
    default:
      return t.api.errors.generic;
  }
}

/// Resolves a validation translation key returned by [FormValidators] into a
/// user-visible translated string. Returns [null] when [key] is [null] (valid
/// field). Falls back to the raw [key] string for unrecognised keys.
String? resolveValidationKey(String? key) {
  if (key == null) return null;
  switch (key) {
    case 'validation.emailRequired':
      return t.validation.emailRequired;
    case 'validation.invalidEmail':
      return t.validation.invalidEmail;
    case 'validation.fieldRequired':
      return t.validation.fieldRequired;
    case 'validation.passwordTooShort':
      return t.validation.passwordTooShort;
    case 'validation.passwordsDoNotMatch':
      return t.validation.passwordsDoNotMatch;
    default:
      return key;
  }
}
