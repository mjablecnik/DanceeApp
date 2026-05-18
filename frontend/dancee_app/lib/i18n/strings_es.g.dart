///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsEs extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEs _root = this; // ignore: unused_field

	@override 
	TranslationsEs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsCommonEs common = _TranslationsCommonEs._(_root);
	@override late final _TranslationsNavEs nav = _TranslationsNavEs._(_root);
	@override late final _TranslationsAuthEs auth = _TranslationsAuthEs._(_root);
	@override late final _TranslationsApiEs api = _TranslationsApiEs._(_root);
	@override late final _TranslationsValidationEs validation = _TranslationsValidationEs._(_root);
	@override late final _TranslationsOnboardingEs onboarding = _TranslationsOnboardingEs._(_root);
	@override late final _TranslationsEventsEs events = _TranslationsEventsEs._(_root);
	@override late final _TranslationsCoursesEs courses = _TranslationsCoursesEs._(_root);
	@override late final _TranslationsProfileEs profile = _TranslationsProfileEs._(_root);
	@override late final _TranslationsPremiumEs premium = _TranslationsPremiumEs._(_root);
	@override late final _TranslationsSavedEs saved = _TranslationsSavedEs._(_root);
	@override late final _TranslationsAuthGateEs authGate = _TranslationsAuthGateEs._(_root);
	@override late final _TranslationsContactEs contact = _TranslationsContactEs._(_root);
}

// Path: common
class _TranslationsCommonEs extends TranslationsCommonEn {
	_TranslationsCommonEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Dancee';
	@override String get showAll => 'Ver todo';
	@override late final _TranslationsCommonMonthsEs months = _TranslationsCommonMonthsEs._(_root);
	@override String get date => 'Fecha';
	@override String get save => 'Guardar';
	@override String get share => 'Compartir';
	@override String get map => 'Mapa';
	@override String get skip => 'Omitir';
	@override String get continue_ => 'Continuar';
	@override String get back => 'Volver';
	@override String get finish => 'Finalizar';
	@override String get cancel => 'Cancelar';
	@override String get allow => 'Permitir';
	@override String get support => 'Soporte';
	@override String get faq => 'FAQ';
	@override String get clear => 'Limpiar';
	@override String get clearFilters => 'Borrar filtros';
	@override String get current => 'Actual';
	@override String get saveChanges => 'Guardar cambios';
	@override String get loading => 'Cargando...';
	@override String get retry => 'Reintentar';
	@override String get logoutSuccess => 'Has cerrado sesión correctamente.';
	@override String from({required Object time}) => 'Desde ${time}';
	@override late final _TranslationsCommonFormEs form = _TranslationsCommonFormEs._(_root);
}

// Path: nav
class _TranslationsNavEs extends TranslationsNavEn {
	_TranslationsNavEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get events => 'Eventos';
	@override String get courses => 'Cursos';
	@override String get saved => 'Guardados';
	@override String get profile => 'Perfil';
	@override String get home => 'Inicio';
	@override String get search => 'Buscar';
}

// Path: auth
class _TranslationsAuthEs extends TranslationsAuthEn {
	_TranslationsAuthEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'Descubre el mundo del baile';
	@override String get orContinueWith => 'o continúa con';
	@override String get continueWithGoogle => 'Continuar con Google';
	@override String get continueWithApple => 'Continuar con Apple';
	@override String get termsPrefix => 'Al continuar aceptas nuestros ';
	@override String get termsOfUse => 'Términos de uso';
	@override String get and => ' y ';
	@override String get privacyPolicy => 'Política de privacidad';
	@override String get agreeWith => 'Acepto ';
	@override String get orRegisterWith => 'o regístrate con';
	@override late final _TranslationsAuthLoginEs login = _TranslationsAuthLoginEs._(_root);
	@override late final _TranslationsAuthRegisterEs register = _TranslationsAuthRegisterEs._(_root);
	@override late final _TranslationsAuthForgotPasswordEs forgotPassword = _TranslationsAuthForgotPasswordEs._(_root);
	@override late final _TranslationsAuthPasswordStrengthEs passwordStrength = _TranslationsAuthPasswordStrengthEs._(_root);
	@override late final _TranslationsAuthErrorsEs errors = _TranslationsAuthErrorsEs._(_root);
	@override late final _TranslationsAuthEmailVerificationEs emailVerification = _TranslationsAuthEmailVerificationEs._(_root);
	@override late final _TranslationsAuthDeleteAccountEs deleteAccount = _TranslationsAuthDeleteAccountEs._(_root);
}

// Path: api
class _TranslationsApiEs extends TranslationsApiEn {
	_TranslationsApiEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsApiErrorsEs errors = _TranslationsApiErrorsEs._(_root);
}

// Path: validation
class _TranslationsValidationEs extends TranslationsValidationEn {
	_TranslationsValidationEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get emailRequired => 'Por favor, ingresa tu dirección de e-mail';
	@override String get invalidEmail => 'Por favor, ingresa una dirección de e-mail válida';
	@override String get fieldRequired => 'Este campo es obligatorio';
	@override String get passwordTooShort => 'La contraseña debe tener al menos 8 caracteres';
	@override String get passwordsDoNotMatch => 'Las contraseñas no coinciden';
}

// Path: onboarding
class _TranslationsOnboardingEs extends TranslationsOnboardingEn {
	_TranslationsOnboardingEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOnboardingStep1Es step1 = _TranslationsOnboardingStep1Es._(_root);
	@override late final _TranslationsOnboardingStep2Es step2 = _TranslationsOnboardingStep2Es._(_root);
	@override late final _TranslationsOnboardingStep3Es step3 = _TranslationsOnboardingStep3Es._(_root);
}

// Path: events
class _TranslationsEventsEs extends TranslationsEventsEn {
	_TranslationsEventsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get featuredEvents => 'Eventos destacados';
	@override String get upcomingEvents => 'Próximos eventos';
	@override String get noEventsFound => 'No se encontraron eventos';
	@override String get noEventsForFilter => 'No hay eventos que coincidan con tus filtros. Intenta ajustar tu selección o borrar los filtros.';
	@override String get danceStyles => 'Estilos de baile';
	@override String get danceStylesLabel => 'ESTILOS DE BAILE';
	@override String get location => 'Ubicación';
	@override late final _TranslationsEventsDetailEs detail = _TranslationsEventsDetailEs._(_root);
	@override late final _TranslationsEventsFilterEs filter = _TranslationsEventsFilterEs._(_root);
	@override late final _TranslationsEventsFiltersEs filters = _TranslationsEventsFiltersEs._(_root);
	@override late final _TranslationsEventsEditEs edit = _TranslationsEventsEditEs._(_root);
}

// Path: courses
class _TranslationsCoursesEs extends TranslationsCoursesEn {
	_TranslationsCoursesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cursos de baile';
	@override String get subtitle => 'Encuentra tu curso';
	@override String get featuredCourses => 'Cursos destacados';
	@override String get allCourses => 'Todos los cursos';
	@override String get noCoursesFound => 'No se encontraron cursos';
	@override String get noCoursesForFilter => 'No hay cursos que coincidan con tus filtros. Intenta ajustar tu selección o borrar los filtros.';
	@override late final _TranslationsCoursesCourseTypesEs courseTypes = _TranslationsCoursesCourseTypesEs._(_root);
	@override late final _TranslationsCoursesDetailEs detail = _TranslationsCoursesDetailEs._(_root);
	@override late final _TranslationsCoursesEditEs edit = _TranslationsCoursesEditEs._(_root);
}

// Path: profile
class _TranslationsProfileEs extends TranslationsProfileEn {
	_TranslationsProfileEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Perfil';
	@override String get loading => 'Cargando perfil...';
	@override String get error => 'Error al cargar el perfil. Por favor, inténtalo de nuevo.';
	@override late final _TranslationsProfileLegalPageEs legalPage = _TranslationsProfileLegalPageEs._(_root);
	@override late final _TranslationsProfileSectionsEs sections = _TranslationsProfileSectionsEs._(_root);
	@override late final _TranslationsProfileAccountEs account = _TranslationsProfileAccountEs._(_root);
	@override late final _TranslationsProfileSettingsEs settings = _TranslationsProfileSettingsEs._(_root);
	@override late final _TranslationsProfileSupportEs support = _TranslationsProfileSupportEs._(_root);
	@override late final _TranslationsProfileAppInfoEs appInfo = _TranslationsProfileAppInfoEs._(_root);
	@override late final _TranslationsProfileDangerEs danger = _TranslationsProfileDangerEs._(_root);
	@override late final _TranslationsProfileChangePasswordEs changePassword = _TranslationsProfileChangePasswordEs._(_root);
	@override late final _TranslationsProfileEditProfileEs editProfile = _TranslationsProfileEditProfileEs._(_root);
}

// Path: premium
class _TranslationsPremiumEs extends TranslationsPremiumEn {
	_TranslationsPremiumEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dancee Premium';
	@override String get bannerSubtitle => 'Desbloquea todas las funciones';
	@override String get heroTitle => 'Desbloquea todo el potencial';
	@override String get heroSubtitle => 'Obtén acceso a todas las funciones premium y mejora tus experiencias de baile';
	@override String get featuresTitle => 'Qué obtienes con Premium';
	@override String get testimonialsTitle => 'Qué dicen nuestros usuarios';
	@override String get faqTitle => 'Preguntas frecuentes';
	@override String get ctaTitle => '¿Listo para empezar?';
	@override String get ctaSubtitle => 'Únete a miles de bailarines satisfechos';
	@override String get ctaButton => 'Obtener Premium ahora';
	@override String get ctaNote => '7 días gratis · Cancela cuando quieras';
}

// Path: saved
class _TranslationsSavedEs extends TranslationsSavedEn {
	_TranslationsSavedEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Eventos guardados';
	@override String get subtitle => 'Tus eventos favoritos';
	@override String get emptyTitle => 'Sin eventos guardados';
	@override String get emptySubtitle => 'Los eventos que guardes aparecerán aquí';
}

// Path: authGate
class _TranslationsAuthGateEs extends TranslationsAuthGateEn {
	_TranslationsAuthGateEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Inicio de sesión requerido';
	@override String get message => 'Crea una cuenta o inicia sesión para acceder a tus eventos guardados y perfil.';
	@override String get actionMessage => 'Necesitas iniciar sesión para usar esta función.';
	@override String get login => 'Iniciar sesión';
	@override String get register => 'Crear cuenta';
	@override String get logoutTitle => 'Sesión cerrada correctamente';
	@override String get logoutMessage => 'Puedes iniciar sesión de nuevo en cualquier momento.';
}

// Path: contact
class _TranslationsContactEs extends TranslationsContactEn {
	_TranslationsContactEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get teamName => 'Equipo Dancee';
	@override String get description => 'Nos encantaría leer tus comentarios...';
	@override String get responseTime => 'Tiempo de respuesta';
	@override String get responseTimeDetail => 'Normalmente respondemos en 24 horas en días laborables. ¡Gracias por tu paciencia!';
	@override String get deviceInfo => 'Información del dispositivo';
	@override String get autoAttached => 'Adjuntado automáticamente';
	@override late final _TranslationsContactFormEs form = _TranslationsContactFormEs._(_root);
	@override late final _TranslationsContactDeviceInfoLabelsEs deviceInfoLabels = _TranslationsContactDeviceInfoLabelsEs._(_root);
}

// Path: common.months
class _TranslationsCommonMonthsEs extends TranslationsCommonMonthsEn {
	_TranslationsCommonMonthsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get jan => 'Ene';
	@override String get feb => 'Feb';
	@override String get mar => 'Mar';
	@override String get apr => 'Abr';
	@override String get may => 'May';
	@override String get jun => 'Jun';
	@override String get jul => 'Jul';
	@override String get aug => 'Ago';
	@override String get sep => 'Sep';
	@override String get oct => 'Oct';
	@override String get nov => 'Nov';
	@override String get dec => 'Dic';
}

// Path: common.form
class _TranslationsCommonFormEs extends TranslationsCommonFormEn {
	_TranslationsCommonFormEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get email => 'E-mail';
	@override String get emailHint => 'tu@email.com';
	@override String get password => 'Contraseña';
	@override String get passwordPlaceholder => '••••••••';
	@override String get confirmPassword => 'Confirmar contraseña';
	@override String get firstName => 'Nombre';
	@override String get firstNameHint => 'Tu nombre';
	@override String get lastName => 'Apellido';
	@override String get lastNameHint => 'Tu apellido';
	@override String get city => 'Ciudad';
	@override String get phone => 'Teléfono';
	@override String get fullName => 'Nombre completo';
}

// Path: auth.login
class _TranslationsAuthLoginEs extends TranslationsAuthLoginEn {
	_TranslationsAuthLoginEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¡Bienvenido de vuelta!';
	@override String get subtitle => 'Inicia sesión y continúa explorando eventos de baile';
	@override String get stayLoggedIn => 'Mantener sesión iniciada';
	@override String get forgotPassword => '¿Olvidaste tu contraseña?';
	@override String get submit => 'Iniciar sesión';
	@override String get noAccount => '¿No tienes cuenta?';
	@override String get register => 'Regístrate';
}

// Path: auth.register
class _TranslationsAuthRegisterEs extends TranslationsAuthRegisterEn {
	_TranslationsAuthRegisterEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Crear una cuenta';
	@override String get subtitle => 'Regístrate y empieza a explorar eventos de baile';
	@override String get passwordsMatch => 'Las contraseñas coinciden';
	@override String get passwordsMismatch => 'Las contraseñas no coinciden';
	@override String get newsletter => 'Quiero recibir noticias sobre eventos de baile';
	@override String get submit => 'Crear cuenta';
	@override String get hasAccount => '¿Ya tienes cuenta?';
	@override String get login => 'Iniciar sesión';
}

// Path: auth.forgotPassword
class _TranslationsAuthForgotPasswordEs extends TranslationsAuthForgotPasswordEn {
	_TranslationsAuthForgotPasswordEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¿Olvidaste tu contraseña?';
	@override String get subtitle => 'Ingresa tu e-mail y te enviaremos un enlace para restablecer tu contraseña';
	@override String get submit => 'Enviar enlace';
	@override String get checkInbox => 'Revisa tu bandeja de entrada';
	@override String get checkInboxDetail => 'Después de enviar recibirás un e-mail con un enlace para restablecer tu contraseña. El enlace es válido por 24 horas.';
	@override String get rememberPassword => '¿Recordaste tu contraseña?';
	@override String get login => 'Iniciar sesión';
	@override String get needHelp => '¿Necesitas ayuda?';
}

// Path: auth.passwordStrength
class _TranslationsAuthPasswordStrengthEs extends TranslationsAuthPasswordStrengthEn {
	_TranslationsAuthPasswordStrengthEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get weak => 'Contraseña débil';
	@override String get medium => 'Media';
	@override String get strong => 'Contraseña fuerte';
	@override String get veryStrong => 'Muy fuerte';
	@override String get hint => 'Al menos 8 caracteres';
}

// Path: auth.errors
class _TranslationsAuthErrorsEs extends TranslationsAuthErrorsEn {
	_TranslationsAuthErrorsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get invalidCredential => 'E-mail o contraseña inválidos';
	@override String get userDisabled => 'Esta cuenta ha sido desactivada';
	@override String get emailAlreadyInUse => 'Ya existe una cuenta con este e-mail';
	@override String get weakPassword => 'La contraseña es demasiado débil';
	@override String get tooManyRequests => 'Demasiados intentos. Por favor, inténtalo más tarde';
	@override String get networkError => 'Error de red. Por favor, verifica tu conexión';
	@override String get generic => 'Ocurrió un error. Por favor, inténtalo de nuevo';
}

// Path: auth.emailVerification
class _TranslationsAuthEmailVerificationEs extends TranslationsAuthEmailVerificationEn {
	_TranslationsAuthEmailVerificationEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Verifica tu e-mail';
	@override String subtitle({required Object email}) => 'Enviamos un e-mail de verificación a ${email}';
	@override String get resend => 'Reenviar e-mail de verificación';
	@override String get resendConfirmed => 'E-mail de verificación enviado. Por favor, revisa tu bandeja de entrada.';
	@override String get checkVerified => 'He verificado mi e-mail';
	@override String get notVerifiedYet => 'E-mail aún no verificado. Por favor, revisa tu bandeja de entrada.';
	@override String get signOut => 'Cerrar sesión';
}

// Path: auth.deleteAccount
class _TranslationsAuthDeleteAccountEs extends TranslationsAuthDeleteAccountEn {
	_TranslationsAuthDeleteAccountEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get confirmTitle => '¿Eliminar cuenta?';
	@override String get confirmBody => 'Esta acción elimina permanentemente todos tus datos. No se puede deshacer.';
	@override String get reauthPrompt => 'Por favor, confirma tu contraseña para continuar';
	@override String get success => 'Tu cuenta ha sido eliminada';
	@override String get error => 'No se pudo eliminar la cuenta. Por favor, inténtalo de nuevo.';
}

// Path: api.errors
class _TranslationsApiErrorsEs extends TranslationsApiErrorsEn {
	_TranslationsApiErrorsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get connectionTimeout => 'Se agotó el tiempo de conexión. Por favor, verifica tu red.';
	@override String get receiveTimeout => 'El servidor tardó demasiado en responder. Por favor, inténtalo de nuevo.';
	@override String get sendTimeout => 'Se agotó el tiempo de envío. Por favor, inténtalo de nuevo.';
	@override String get noConnection => 'Sin conexión a internet. Por favor, verifica tu red.';
	@override String get requestCancelled => 'La solicitud fue cancelada.';
	@override String get badRequest => 'Solicitud incorrecta. Por favor, inténtalo de nuevo.';
	@override String get unauthorized => 'Sesión expirada. Por favor, inicia sesión de nuevo.';
	@override String get forbidden => 'Acceso denegado. Por favor, contacta con soporte.';
	@override String get notFound => 'El recurso solicitado no fue encontrado.';
	@override String get conflict => 'Ocurrió un conflicto. Por favor, inténtalo de nuevo.';
	@override String get internalServerError => 'Error del servidor. Por favor, inténtalo más tarde.';
	@override String get badGateway => 'El servidor no está disponible temporalmente. Por favor, inténtalo más tarde.';
	@override String get serviceUnavailable => 'El servicio no está disponible. Por favor, inténtalo más tarde.';
	@override String get clientError => 'Ocurrió un error. Por favor, inténtalo de nuevo.';
	@override String get serverError => 'Error del servidor. Por favor, inténtalo más tarde.';
	@override String get generic => 'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';
}

// Path: onboarding.step1
class _TranslationsOnboardingStep1Es extends TranslationsOnboardingStep1En {
	_TranslationsOnboardingStep1Es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¿Qué bailes te gustan?';
	@override String get subtitle => 'Elige tus estilos de baile favoritos para ofrecerte eventos relevantes';
}

// Path: onboarding.step2
class _TranslationsOnboardingStep2Es extends TranslationsOnboardingStep2En {
	_TranslationsOnboardingStep2Es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¿Cuál es tu nivel?';
	@override String get subtitle => 'Nos ayudará a recomendarte eventos y cursos adecuados';
}

// Path: onboarding.step3
class _TranslationsOnboardingStep3Es extends TranslationsOnboardingStep3En {
	_TranslationsOnboardingStep3Es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¿Dónde te encuentras?';
	@override String get subtitle => 'Encontraremos los eventos de baile más cercanos en tu zona';
	@override String get radius10km => '10 km';
	@override String get radius25km => '25 km';
	@override String get radius50km => '50 km';
	@override String get radiusAll => 'Todo el país';
	@override String get cityHint => 'Ej. Madrid, Barcelona...';
	@override String get searchRadius => 'Buscar eventos en un radio de';
	@override String get useCurrentLocation => 'Usar ubicación actual';
}

// Path: events.detail
class _TranslationsEventsDetailEs extends TranslationsEventsDetailEn {
	_TranslationsEventsDetailEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get header => 'Detalle del evento';
	@override String get description => 'Descripción del evento';
	@override String get additionalInfo => 'Información adicional';
	@override String get admission => 'Entrada';
	@override String get dresscode => 'Código de vestimenta';
	@override String get buyTickets => 'Comprar entradas';
	@override String get originalSource => 'Fuente original';
	@override String get program => 'Programa del evento';
	@override String get notFound => 'Evento no encontrado';
	@override String lector({required Object name}) => 'Instructor: ${name}';
	@override String dj({required Object name}) => 'DJ: ${name}';
}

// Path: events.filter
class _TranslationsEventsFilterEs extends TranslationsEventsFilterEn {
	_TranslationsEventsFilterEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String selectedCount({required Object count}) => '${count} seleccionados';
	@override String get selectedStyles => 'ESTILOS SELECCIONADOS';
	@override String get apply => 'Aplicar filtro';
	@override String applyCount({required Object count}) => 'Aplicar filtro (${count})';
	@override String get selectLocation => 'Seleccionar ubicación';
	@override String get searchCityHint => 'Buscar ciudad o área...';
	@override String get useMyLocation => 'Usar mi ubicación';
	@override String get useMyLocationSubtitle => 'Encuentra automáticamente eventos cerca de ti';
	@override String get popularCities => 'Ciudades populares';
	@override String get allCities => 'Todas las ciudades';
	@override String get selectedRegions => 'REGIONES SELECCIONADAS';
	@override String get noResults => 'Sin resultados';
	@override String get abroad => 'Extranjero';
	@override String get unknownRegion => 'Ubicación desconocida';
}

// Path: events.filters
class _TranslationsEventsFiltersEs extends TranslationsEventsFiltersEn {
	_TranslationsEventsFiltersEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get today => 'Hoy';
	@override String get thisWeek => 'Esta semana';
	@override String get thisMonth => 'Este mes';
	@override String get thisWeekend => 'Este fin de semana';
	@override String get all => 'Todo';
	@override String get evening => 'Nocturno';
	@override String get weekend => 'Fin de semana';
	@override String get multiDay => 'Varios días';
}

// Path: events.edit
class _TranslationsEventsEditEs extends TranslationsEventsEditEn {
	_TranslationsEventsEditEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get header => 'Editar evento';
	@override String get submit => 'Guardar cambios';
	@override String get success => 'Evento actualizado correctamente';
	@override String get error => 'Error al actualizar el evento';
}

// Path: courses.courseTypes
class _TranslationsCoursesCourseTypesEs extends TranslationsCoursesCourseTypesEn {
	_TranslationsCoursesCourseTypesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get all => 'Todo';
	@override String get workshop => 'Taller';
	@override String get regular => 'Curso regular';
}

// Path: courses.detail
class _TranslationsCoursesDetailEs extends TranslationsCoursesDetailEn {
	_TranslationsCoursesDetailEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get header => 'Detalle del curso';
	@override String get notFound => 'Curso no encontrado';
	@override String get description => 'Descripción del curso';
	@override String get details => 'Detalles del curso';
	@override String get whatYouLearn => 'Qué aprenderás';
	@override String get aboutInstructor => 'Sobre el instructor';
	@override String get shareCourse => 'Compartir curso';
	@override String get coursePrice => 'Precio del curso';
	@override String get priceUnknown => 'Precio no especificado';
	@override String get availableSpots => 'Plazas disponibles';
	@override String get register => 'Inscribirse al curso';
	@override String get startDate => 'Fecha de inicio';
	@override String get endDate => 'Fecha de fin';
	@override String get day => 'Día';
	@override String get time => 'Hora';
	@override String get lessons => 'Lecciones';
	@override String get duration => 'Duración';
	@override String get level => 'Nivel';
	@override late final _TranslationsCoursesDetailLevelsEs levels = _TranslationsCoursesDetailLevelsEs._(_root);
	@override late final _TranslationsCoursesDetailDaysEs days = _TranslationsCoursesDetailDaysEs._(_root);
	@override String lessonsCount({required Object count}) => '${count} lecciones';
	@override String durationMin({required Object count}) => '${count} min';
	@override String participantsCount({required Object current, required Object max}) => '${current} / ${max} participantes';
	@override String spotsAvailable({required Object count}) => '${count} plazas disponibles';
}

// Path: courses.edit
class _TranslationsCoursesEditEs extends TranslationsCoursesEditEn {
	_TranslationsCoursesEditEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get header => 'Editar curso';
	@override String get submit => 'Guardar cambios';
	@override String get success => 'Curso actualizado correctamente';
	@override String get error => 'Error al actualizar el curso';
}

// Path: profile.legalPage
class _TranslationsProfileLegalPageEs extends TranslationsProfileLegalPageEn {
	_TranslationsProfileLegalPageEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Cargando contenido...';
	@override String get error => 'Error al cargar el contenido. Por favor, inténtalo de nuevo.';
	@override String get retry => 'Reintentar';
}

// Path: profile.sections
class _TranslationsProfileSectionsEs extends TranslationsProfileSectionsEn {
	_TranslationsProfileSectionsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get account => 'Cuenta';
	@override String get settings => 'Ajustes';
	@override String get support => 'Soporte';
	@override String get appInfo => 'Sobre la app';
	@override String get dangerZone => 'Zona de peligro';
}

// Path: profile.account
class _TranslationsProfileAccountEs extends TranslationsProfileAccountEn {
	_TranslationsProfileAccountEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get editProfile => 'Editar perfil';
	@override String get changePassword => 'Cambiar contraseña';
}

// Path: profile.settings
class _TranslationsProfileSettingsEs extends TranslationsProfileSettingsEn {
	_TranslationsProfileSettingsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get language => 'Idioma';
	@override String get czech => 'Checo';
	@override String get notifications => 'Notificaciones';
	@override String get english => 'Inglés';
	@override String get spanish => 'Español';
}

// Path: profile.support
class _TranslationsProfileSupportEs extends TranslationsProfileSupportEn {
	_TranslationsProfileSupportEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get contactAuthor => 'Contactar al autor';
	@override String get rateApp => 'Valorar app';
}

// Path: profile.appInfo
class _TranslationsProfileAppInfoEs extends TranslationsProfileAppInfoEn {
	_TranslationsProfileAppInfoEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get version => 'Versión de la app';
	@override String get termsOfUse => 'Términos de uso';
	@override String get privacy => 'Privacidad';
}

// Path: profile.danger
class _TranslationsProfileDangerEs extends TranslationsProfileDangerEn {
	_TranslationsProfileDangerEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get logout => 'Cerrar sesión';
	@override String get logoutConfirmBody => '¿Seguro que quieres cerrar sesión?';
	@override String get deleteAccount => 'Eliminar cuenta';
}

// Path: profile.changePassword
class _TranslationsProfileChangePasswordEs extends TranslationsProfileChangePasswordEn {
	_TranslationsProfileChangePasswordEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cambiar contraseña';
	@override String get secureAccount => 'Asegura tu cuenta';
	@override String get secureAccountDetail => 'Una contraseña segura debe contener al menos 8 caracteres, letras mayúsculas y minúsculas, números y caracteres especiales.';
	@override String get currentPassword => 'Contraseña actual';
	@override String get currentPasswordHint => 'Ingresa la contraseña actual';
	@override String get newPassword => 'Nueva contraseña';
	@override String get newPasswordHint => 'Ingresa la nueva contraseña';
	@override String get confirmPassword => 'Confirmar nueva contraseña';
	@override String get confirmPasswordHint => 'Ingresa la nueva contraseña de nuevo';
	@override String get save => 'Guardar nueva contraseña';
	@override String get requirements => 'REQUISITOS DE CONTRASEÑA';
	@override String get req8chars => 'Mínimo 8 caracteres';
	@override String get reqUppercase => 'Al menos una letra mayúscula (A-Z)';
	@override String get reqLowercase => 'Al menos una letra minúscula (a-z)';
	@override String get reqNumber => 'Al menos un número (0-9)';
	@override String get reqSpecial => 'Al menos un carácter especial (!@#\$%^&*)';
	@override String get forgotPassword => '¿Olvidaste tu contraseña?';
	@override String get strengthVeryWeak => 'Seguridad de contraseña: Muy débil';
	@override String get strengthWeak => 'Seguridad de contraseña: Débil';
	@override String get strengthMedium => 'Seguridad de contraseña: Media';
	@override String get strengthStrong => 'Seguridad de contraseña: Fuerte';
	@override String get success => 'Contraseña cambiada con éxito.';
	@override String get error => 'Error al cambiar la contraseña. Por favor, inténtalo de nuevo.';
	@override String get incorrectPassword => 'La contraseña actual es incorrecta.';
}

// Path: profile.editProfile
class _TranslationsProfileEditProfileEs extends TranslationsProfileEditProfileEn {
	_TranslationsProfileEditProfileEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Editar perfil';
	@override late final _TranslationsProfileEditProfileSectionsEs sections = _TranslationsProfileEditProfileSectionsEs._(_root);
	@override String get changePhoto => 'Cambiar foto';
	@override String get bio => 'Descripción';
	@override String get bioHint => 'Escribe algo sobre ti...';
	@override String get selectDanceStyles => 'Selecciona tus estilos de baile favoritos';
	@override String get yourLevel => 'Tu nivel de baile';
	@override String get instagram => 'Instagram';
	@override String get instagramHint => '@tu_usuario';
	@override String get facebook => 'Facebook';
	@override String get facebookHint => 'facebook.com/tu.nombre';
	@override late final _TranslationsProfileEditProfileNotificationsEs notifications = _TranslationsProfileEditProfileNotificationsEs._(_root);
	@override late final _TranslationsProfileEditProfileNotificationSubtitlesEs notificationSubtitles = _TranslationsProfileEditProfileNotificationSubtitlesEs._(_root);
	@override String get save => 'Guardar cambios';
	@override String get updateSuccess => 'Perfil actualizado con éxito.';
	@override String get updateError => 'Error al actualizar el perfil. Por favor, inténtalo de nuevo.';
	@override late final _TranslationsProfileEditProfileExperienceLevelsEs experienceLevels = _TranslationsProfileEditProfileExperienceLevelsEs._(_root);
	@override late final _TranslationsProfileEditProfileAvatarEs avatar = _TranslationsProfileEditProfileAvatarEs._(_root);
}

// Path: contact.form
class _TranslationsContactFormEs extends TranslationsContactFormEn {
	_TranslationsContactFormEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get subject => 'Asunto del mensaje';
	@override String get feedback => 'Comentario';
	@override String get reportBug => 'Reportar error';
	@override String get featureRequest => 'Sugerencia de mejora';
	@override String get other => 'Otro';
	@override String get title => 'Título del mensaje';
	@override String get titleHint => 'Describe brevemente tu problema o sugerencia';
	@override String get message => 'Mensaje';
	@override String get messageHint => 'Describe tu problema en detalle...';
	@override String get replyEmail => 'Tu e-mail de respuesta';
	@override String get sending => 'Enviando...';
	@override String get sent => '¡Enviado!';
	@override String get submit => 'Enviar mensaje';
	@override String get success => 'Tu mensaje ha sido enviado. ¡Nos pondremos en contacto contigo pronto!';
	@override String get error => 'Error al enviar el mensaje. Por favor, inténtalo de nuevo.';
	@override String get typeRequired => 'Por favor, selecciona un tipo de mensaje';
	@override String get titleRequired => 'Por favor, ingresa un título';
	@override String get messageRequired => 'Por favor, ingresa un mensaje';
	@override String get emailRequired => 'Por favor, ingresa tu e-mail de respuesta';
}

// Path: contact.deviceInfoLabels
class _TranslationsContactDeviceInfoLabelsEs extends TranslationsContactDeviceInfoLabelsEn {
	_TranslationsContactDeviceInfoLabelsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get app => 'App:';
	@override String get device => 'Dispositivo:';
	@override String get os => 'Sistema:';
}

// Path: courses.detail.levels
class _TranslationsCoursesDetailLevelsEs extends TranslationsCoursesDetailLevelsEn {
	_TranslationsCoursesDetailLevelsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get beginner => 'Principiante';
	@override String get intermediate => 'Intermedio';
	@override String get advanced => 'Avanzado';
	@override String get allLevels => 'Todos los niveles';
}

// Path: courses.detail.days
class _TranslationsCoursesDetailDaysEs extends TranslationsCoursesDetailDaysEn {
	_TranslationsCoursesDetailDaysEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get monday => 'Lunes';
	@override String get tuesday => 'Martes';
	@override String get wednesday => 'Miércoles';
	@override String get thursday => 'Jueves';
	@override String get friday => 'Viernes';
	@override String get saturday => 'Sábado';
	@override String get sunday => 'Domingo';
}

// Path: profile.editProfile.sections
class _TranslationsProfileEditProfileSectionsEs extends TranslationsProfileEditProfileSectionsEn {
	_TranslationsProfileEditProfileSectionsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get personalInfo => 'Información personal';
	@override String get aboutMe => 'Sobre mí';
	@override String get favoriteDances => 'Bailes favoritos';
	@override String get level => 'Nivel';
	@override String get socialNetworks => 'Redes sociales';
	@override String get notifications => 'Notificaciones';
}

// Path: profile.editProfile.notifications
class _TranslationsProfileEditProfileNotificationsEs extends TranslationsProfileEditProfileNotificationsEn {
	_TranslationsProfileEditProfileNotificationsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get newEvents => 'Nuevos eventos';
	@override String get eventReminders => 'Recordatorios de eventos';
	@override String get marketing => 'Mensajes de marketing';
}

// Path: profile.editProfile.notificationSubtitles
class _TranslationsProfileEditProfileNotificationSubtitlesEs extends TranslationsProfileEditProfileNotificationSubtitlesEn {
	_TranslationsProfileEditProfileNotificationSubtitlesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get newEvents => 'Recibe notificaciones sobre nuevos eventos en tu zona';
	@override String get eventReminders => 'Recordatorios antes de tus eventos guardados';
	@override String get marketing => 'Mensajes promocionales y ofertas';
}

// Path: profile.editProfile.experienceLevels
class _TranslationsProfileEditProfileExperienceLevelsEs extends TranslationsProfileEditProfileExperienceLevelsEn {
	_TranslationsProfileEditProfileExperienceLevelsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get beginner => 'Principiante';
	@override String get slightlyAdvanced => 'Ligeramente avanzado';
	@override String get advanced => 'Avanzado';
	@override String get expert => 'Experto';
}

// Path: profile.editProfile.avatar
class _TranslationsProfileEditProfileAvatarEs extends TranslationsProfileEditProfileAvatarEn {
	_TranslationsProfileEditProfileAvatarEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get sourceTitle => 'Cambiar foto de perfil';
	@override String get takePhoto => 'Tomar una foto';
	@override String get chooseFromGallery => 'Elegir de la galería';
	@override String get uploadError => 'Error al subir la foto. Por favor, inténtalo de nuevo.';
	@override String get linkError => 'Error al actualizar la foto de perfil. Por favor, inténtalo de nuevo.';
	@override String get permissionRequired => 'Se requiere permiso de cámara o galería para cambiar tu foto.';
	@override String get permissionDeniedTitle => 'Permiso requerido';
	@override String get permissionDeniedMessage => 'Has denegado el acceso permanentemente. Por favor, actívalo en la configuración de tu dispositivo para cambiar tu foto de perfil.';
	@override String get openSettings => 'Abrir configuración';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.appName' => 'Dancee',
			'common.showAll' => 'Ver todo',
			'common.months.jan' => 'Ene',
			'common.months.feb' => 'Feb',
			'common.months.mar' => 'Mar',
			'common.months.apr' => 'Abr',
			'common.months.may' => 'May',
			'common.months.jun' => 'Jun',
			'common.months.jul' => 'Jul',
			'common.months.aug' => 'Ago',
			'common.months.sep' => 'Sep',
			'common.months.oct' => 'Oct',
			'common.months.nov' => 'Nov',
			'common.months.dec' => 'Dic',
			'common.date' => 'Fecha',
			'common.save' => 'Guardar',
			'common.share' => 'Compartir',
			'common.map' => 'Mapa',
			'common.skip' => 'Omitir',
			'common.continue_' => 'Continuar',
			'common.back' => 'Volver',
			'common.finish' => 'Finalizar',
			'common.cancel' => 'Cancelar',
			'common.allow' => 'Permitir',
			'common.support' => 'Soporte',
			'common.faq' => 'FAQ',
			'common.clear' => 'Limpiar',
			'common.clearFilters' => 'Borrar filtros',
			'common.current' => 'Actual',
			'common.saveChanges' => 'Guardar cambios',
			'common.loading' => 'Cargando...',
			'common.retry' => 'Reintentar',
			'common.logoutSuccess' => 'Has cerrado sesión correctamente.',
			'common.from' => ({required Object time}) => 'Desde ${time}',
			'common.form.email' => 'E-mail',
			'common.form.emailHint' => 'tu@email.com',
			'common.form.password' => 'Contraseña',
			'common.form.passwordPlaceholder' => '••••••••',
			'common.form.confirmPassword' => 'Confirmar contraseña',
			'common.form.firstName' => 'Nombre',
			'common.form.firstNameHint' => 'Tu nombre',
			'common.form.lastName' => 'Apellido',
			'common.form.lastNameHint' => 'Tu apellido',
			'common.form.city' => 'Ciudad',
			'common.form.phone' => 'Teléfono',
			'common.form.fullName' => 'Nombre completo',
			'nav.events' => 'Eventos',
			'nav.courses' => 'Cursos',
			'nav.saved' => 'Guardados',
			'nav.profile' => 'Perfil',
			'nav.home' => 'Inicio',
			'nav.search' => 'Buscar',
			'auth.tagline' => 'Descubre el mundo del baile',
			'auth.orContinueWith' => 'o continúa con',
			'auth.continueWithGoogle' => 'Continuar con Google',
			'auth.continueWithApple' => 'Continuar con Apple',
			'auth.termsPrefix' => 'Al continuar aceptas nuestros ',
			'auth.termsOfUse' => 'Términos de uso',
			'auth.and' => ' y ',
			'auth.privacyPolicy' => 'Política de privacidad',
			'auth.agreeWith' => 'Acepto ',
			'auth.orRegisterWith' => 'o regístrate con',
			'auth.login.title' => '¡Bienvenido de vuelta!',
			'auth.login.subtitle' => 'Inicia sesión y continúa explorando eventos de baile',
			'auth.login.stayLoggedIn' => 'Mantener sesión iniciada',
			'auth.login.forgotPassword' => '¿Olvidaste tu contraseña?',
			'auth.login.submit' => 'Iniciar sesión',
			'auth.login.noAccount' => '¿No tienes cuenta?',
			'auth.login.register' => 'Regístrate',
			'auth.register.title' => 'Crear una cuenta',
			'auth.register.subtitle' => 'Regístrate y empieza a explorar eventos de baile',
			'auth.register.passwordsMatch' => 'Las contraseñas coinciden',
			'auth.register.passwordsMismatch' => 'Las contraseñas no coinciden',
			'auth.register.newsletter' => 'Quiero recibir noticias sobre eventos de baile',
			'auth.register.submit' => 'Crear cuenta',
			'auth.register.hasAccount' => '¿Ya tienes cuenta?',
			'auth.register.login' => 'Iniciar sesión',
			'auth.forgotPassword.title' => '¿Olvidaste tu contraseña?',
			'auth.forgotPassword.subtitle' => 'Ingresa tu e-mail y te enviaremos un enlace para restablecer tu contraseña',
			'auth.forgotPassword.submit' => 'Enviar enlace',
			'auth.forgotPassword.checkInbox' => 'Revisa tu bandeja de entrada',
			'auth.forgotPassword.checkInboxDetail' => 'Después de enviar recibirás un e-mail con un enlace para restablecer tu contraseña. El enlace es válido por 24 horas.',
			'auth.forgotPassword.rememberPassword' => '¿Recordaste tu contraseña?',
			'auth.forgotPassword.login' => 'Iniciar sesión',
			'auth.forgotPassword.needHelp' => '¿Necesitas ayuda?',
			'auth.passwordStrength.weak' => 'Contraseña débil',
			'auth.passwordStrength.medium' => 'Media',
			'auth.passwordStrength.strong' => 'Contraseña fuerte',
			'auth.passwordStrength.veryStrong' => 'Muy fuerte',
			'auth.passwordStrength.hint' => 'Al menos 8 caracteres',
			'auth.errors.invalidCredential' => 'E-mail o contraseña inválidos',
			'auth.errors.userDisabled' => 'Esta cuenta ha sido desactivada',
			'auth.errors.emailAlreadyInUse' => 'Ya existe una cuenta con este e-mail',
			'auth.errors.weakPassword' => 'La contraseña es demasiado débil',
			'auth.errors.tooManyRequests' => 'Demasiados intentos. Por favor, inténtalo más tarde',
			'auth.errors.networkError' => 'Error de red. Por favor, verifica tu conexión',
			'auth.errors.generic' => 'Ocurrió un error. Por favor, inténtalo de nuevo',
			'auth.emailVerification.title' => 'Verifica tu e-mail',
			'auth.emailVerification.subtitle' => ({required Object email}) => 'Enviamos un e-mail de verificación a ${email}',
			'auth.emailVerification.resend' => 'Reenviar e-mail de verificación',
			'auth.emailVerification.resendConfirmed' => 'E-mail de verificación enviado. Por favor, revisa tu bandeja de entrada.',
			'auth.emailVerification.checkVerified' => 'He verificado mi e-mail',
			'auth.emailVerification.notVerifiedYet' => 'E-mail aún no verificado. Por favor, revisa tu bandeja de entrada.',
			'auth.emailVerification.signOut' => 'Cerrar sesión',
			'auth.deleteAccount.confirmTitle' => '¿Eliminar cuenta?',
			'auth.deleteAccount.confirmBody' => 'Esta acción elimina permanentemente todos tus datos. No se puede deshacer.',
			'auth.deleteAccount.reauthPrompt' => 'Por favor, confirma tu contraseña para continuar',
			'auth.deleteAccount.success' => 'Tu cuenta ha sido eliminada',
			'auth.deleteAccount.error' => 'No se pudo eliminar la cuenta. Por favor, inténtalo de nuevo.',
			'api.errors.connectionTimeout' => 'Se agotó el tiempo de conexión. Por favor, verifica tu red.',
			'api.errors.receiveTimeout' => 'El servidor tardó demasiado en responder. Por favor, inténtalo de nuevo.',
			'api.errors.sendTimeout' => 'Se agotó el tiempo de envío. Por favor, inténtalo de nuevo.',
			'api.errors.noConnection' => 'Sin conexión a internet. Por favor, verifica tu red.',
			'api.errors.requestCancelled' => 'La solicitud fue cancelada.',
			'api.errors.badRequest' => 'Solicitud incorrecta. Por favor, inténtalo de nuevo.',
			'api.errors.unauthorized' => 'Sesión expirada. Por favor, inicia sesión de nuevo.',
			'api.errors.forbidden' => 'Acceso denegado. Por favor, contacta con soporte.',
			'api.errors.notFound' => 'El recurso solicitado no fue encontrado.',
			'api.errors.conflict' => 'Ocurrió un conflicto. Por favor, inténtalo de nuevo.',
			'api.errors.internalServerError' => 'Error del servidor. Por favor, inténtalo más tarde.',
			'api.errors.badGateway' => 'El servidor no está disponible temporalmente. Por favor, inténtalo más tarde.',
			'api.errors.serviceUnavailable' => 'El servicio no está disponible. Por favor, inténtalo más tarde.',
			'api.errors.clientError' => 'Ocurrió un error. Por favor, inténtalo de nuevo.',
			'api.errors.serverError' => 'Error del servidor. Por favor, inténtalo más tarde.',
			'api.errors.generic' => 'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.',
			'validation.emailRequired' => 'Por favor, ingresa tu dirección de e-mail',
			'validation.invalidEmail' => 'Por favor, ingresa una dirección de e-mail válida',
			'validation.fieldRequired' => 'Este campo es obligatorio',
			'validation.passwordTooShort' => 'La contraseña debe tener al menos 8 caracteres',
			'validation.passwordsDoNotMatch' => 'Las contraseñas no coinciden',
			'onboarding.step1.title' => '¿Qué bailes te gustan?',
			'onboarding.step1.subtitle' => 'Elige tus estilos de baile favoritos para ofrecerte eventos relevantes',
			'onboarding.step2.title' => '¿Cuál es tu nivel?',
			'onboarding.step2.subtitle' => 'Nos ayudará a recomendarte eventos y cursos adecuados',
			'onboarding.step3.title' => '¿Dónde te encuentras?',
			'onboarding.step3.subtitle' => 'Encontraremos los eventos de baile más cercanos en tu zona',
			'onboarding.step3.radius10km' => '10 km',
			'onboarding.step3.radius25km' => '25 km',
			'onboarding.step3.radius50km' => '50 km',
			'onboarding.step3.radiusAll' => 'Todo el país',
			'onboarding.step3.cityHint' => 'Ej. Madrid, Barcelona...',
			'onboarding.step3.searchRadius' => 'Buscar eventos en un radio de',
			'onboarding.step3.useCurrentLocation' => 'Usar ubicación actual',
			'events.featuredEvents' => 'Eventos destacados',
			'events.upcomingEvents' => 'Próximos eventos',
			'events.noEventsFound' => 'No se encontraron eventos',
			'events.noEventsForFilter' => 'No hay eventos que coincidan con tus filtros. Intenta ajustar tu selección o borrar los filtros.',
			'events.danceStyles' => 'Estilos de baile',
			'events.danceStylesLabel' => 'ESTILOS DE BAILE',
			'events.location' => 'Ubicación',
			'events.detail.header' => 'Detalle del evento',
			'events.detail.description' => 'Descripción del evento',
			'events.detail.additionalInfo' => 'Información adicional',
			'events.detail.admission' => 'Entrada',
			'events.detail.dresscode' => 'Código de vestimenta',
			'events.detail.buyTickets' => 'Comprar entradas',
			'events.detail.originalSource' => 'Fuente original',
			'events.detail.program' => 'Programa del evento',
			'events.detail.notFound' => 'Evento no encontrado',
			'events.detail.lector' => ({required Object name}) => 'Instructor: ${name}',
			'events.detail.dj' => ({required Object name}) => 'DJ: ${name}',
			'events.filter.selectedCount' => ({required Object count}) => '${count} seleccionados',
			'events.filter.selectedStyles' => 'ESTILOS SELECCIONADOS',
			'events.filter.apply' => 'Aplicar filtro',
			'events.filter.applyCount' => ({required Object count}) => 'Aplicar filtro (${count})',
			'events.filter.selectLocation' => 'Seleccionar ubicación',
			'events.filter.searchCityHint' => 'Buscar ciudad o área...',
			'events.filter.useMyLocation' => 'Usar mi ubicación',
			'events.filter.useMyLocationSubtitle' => 'Encuentra automáticamente eventos cerca de ti',
			'events.filter.popularCities' => 'Ciudades populares',
			'events.filter.allCities' => 'Todas las ciudades',
			'events.filter.selectedRegions' => 'REGIONES SELECCIONADAS',
			'events.filter.noResults' => 'Sin resultados',
			'events.filter.abroad' => 'Extranjero',
			'events.filter.unknownRegion' => 'Ubicación desconocida',
			'events.filters.today' => 'Hoy',
			'events.filters.thisWeek' => 'Esta semana',
			'events.filters.thisMonth' => 'Este mes',
			'events.filters.thisWeekend' => 'Este fin de semana',
			'events.filters.all' => 'Todo',
			'events.filters.evening' => 'Nocturno',
			'events.filters.weekend' => 'Fin de semana',
			'events.filters.multiDay' => 'Varios días',
			'events.edit.header' => 'Editar evento',
			'events.edit.submit' => 'Guardar cambios',
			'events.edit.success' => 'Evento actualizado correctamente',
			'events.edit.error' => 'Error al actualizar el evento',
			'courses.title' => 'Cursos de baile',
			'courses.subtitle' => 'Encuentra tu curso',
			'courses.featuredCourses' => 'Cursos destacados',
			'courses.allCourses' => 'Todos los cursos',
			'courses.noCoursesFound' => 'No se encontraron cursos',
			'courses.noCoursesForFilter' => 'No hay cursos que coincidan con tus filtros. Intenta ajustar tu selección o borrar los filtros.',
			'courses.courseTypes.all' => 'Todo',
			'courses.courseTypes.workshop' => 'Taller',
			'courses.courseTypes.regular' => 'Curso regular',
			'courses.detail.header' => 'Detalle del curso',
			'courses.detail.notFound' => 'Curso no encontrado',
			'courses.detail.description' => 'Descripción del curso',
			'courses.detail.details' => 'Detalles del curso',
			'courses.detail.whatYouLearn' => 'Qué aprenderás',
			'courses.detail.aboutInstructor' => 'Sobre el instructor',
			'courses.detail.shareCourse' => 'Compartir curso',
			'courses.detail.coursePrice' => 'Precio del curso',
			'courses.detail.priceUnknown' => 'Precio no especificado',
			'courses.detail.availableSpots' => 'Plazas disponibles',
			'courses.detail.register' => 'Inscribirse al curso',
			'courses.detail.startDate' => 'Fecha de inicio',
			'courses.detail.endDate' => 'Fecha de fin',
			'courses.detail.day' => 'Día',
			'courses.detail.time' => 'Hora',
			'courses.detail.lessons' => 'Lecciones',
			'courses.detail.duration' => 'Duración',
			'courses.detail.level' => 'Nivel',
			'courses.detail.levels.beginner' => 'Principiante',
			'courses.detail.levels.intermediate' => 'Intermedio',
			'courses.detail.levels.advanced' => 'Avanzado',
			'courses.detail.levels.allLevels' => 'Todos los niveles',
			'courses.detail.days.monday' => 'Lunes',
			'courses.detail.days.tuesday' => 'Martes',
			'courses.detail.days.wednesday' => 'Miércoles',
			'courses.detail.days.thursday' => 'Jueves',
			'courses.detail.days.friday' => 'Viernes',
			'courses.detail.days.saturday' => 'Sábado',
			'courses.detail.days.sunday' => 'Domingo',
			'courses.detail.lessonsCount' => ({required Object count}) => '${count} lecciones',
			'courses.detail.durationMin' => ({required Object count}) => '${count} min',
			'courses.detail.participantsCount' => ({required Object current, required Object max}) => '${current} / ${max} participantes',
			'courses.detail.spotsAvailable' => ({required Object count}) => '${count} plazas disponibles',
			'courses.edit.header' => 'Editar curso',
			'courses.edit.submit' => 'Guardar cambios',
			'courses.edit.success' => 'Curso actualizado correctamente',
			'courses.edit.error' => 'Error al actualizar el curso',
			'profile.title' => 'Perfil',
			'profile.loading' => 'Cargando perfil...',
			'profile.error' => 'Error al cargar el perfil. Por favor, inténtalo de nuevo.',
			'profile.legalPage.loading' => 'Cargando contenido...',
			'profile.legalPage.error' => 'Error al cargar el contenido. Por favor, inténtalo de nuevo.',
			'profile.legalPage.retry' => 'Reintentar',
			'profile.sections.account' => 'Cuenta',
			'profile.sections.settings' => 'Ajustes',
			'profile.sections.support' => 'Soporte',
			'profile.sections.appInfo' => 'Sobre la app',
			'profile.sections.dangerZone' => 'Zona de peligro',
			'profile.account.editProfile' => 'Editar perfil',
			'profile.account.changePassword' => 'Cambiar contraseña',
			'profile.settings.language' => 'Idioma',
			'profile.settings.czech' => 'Checo',
			'profile.settings.notifications' => 'Notificaciones',
			'profile.settings.english' => 'Inglés',
			'profile.settings.spanish' => 'Español',
			'profile.support.contactAuthor' => 'Contactar al autor',
			'profile.support.rateApp' => 'Valorar app',
			'profile.appInfo.version' => 'Versión de la app',
			'profile.appInfo.termsOfUse' => 'Términos de uso',
			'profile.appInfo.privacy' => 'Privacidad',
			'profile.danger.logout' => 'Cerrar sesión',
			'profile.danger.logoutConfirmBody' => '¿Seguro que quieres cerrar sesión?',
			'profile.danger.deleteAccount' => 'Eliminar cuenta',
			'profile.changePassword.title' => 'Cambiar contraseña',
			'profile.changePassword.secureAccount' => 'Asegura tu cuenta',
			'profile.changePassword.secureAccountDetail' => 'Una contraseña segura debe contener al menos 8 caracteres, letras mayúsculas y minúsculas, números y caracteres especiales.',
			'profile.changePassword.currentPassword' => 'Contraseña actual',
			'profile.changePassword.currentPasswordHint' => 'Ingresa la contraseña actual',
			'profile.changePassword.newPassword' => 'Nueva contraseña',
			'profile.changePassword.newPasswordHint' => 'Ingresa la nueva contraseña',
			'profile.changePassword.confirmPassword' => 'Confirmar nueva contraseña',
			'profile.changePassword.confirmPasswordHint' => 'Ingresa la nueva contraseña de nuevo',
			'profile.changePassword.save' => 'Guardar nueva contraseña',
			'profile.changePassword.requirements' => 'REQUISITOS DE CONTRASEÑA',
			'profile.changePassword.req8chars' => 'Mínimo 8 caracteres',
			'profile.changePassword.reqUppercase' => 'Al menos una letra mayúscula (A-Z)',
			'profile.changePassword.reqLowercase' => 'Al menos una letra minúscula (a-z)',
			'profile.changePassword.reqNumber' => 'Al menos un número (0-9)',
			'profile.changePassword.reqSpecial' => 'Al menos un carácter especial (!@#\$%^&*)',
			'profile.changePassword.forgotPassword' => '¿Olvidaste tu contraseña?',
			'profile.changePassword.strengthVeryWeak' => 'Seguridad de contraseña: Muy débil',
			'profile.changePassword.strengthWeak' => 'Seguridad de contraseña: Débil',
			'profile.changePassword.strengthMedium' => 'Seguridad de contraseña: Media',
			'profile.changePassword.strengthStrong' => 'Seguridad de contraseña: Fuerte',
			'profile.changePassword.success' => 'Contraseña cambiada con éxito.',
			'profile.changePassword.error' => 'Error al cambiar la contraseña. Por favor, inténtalo de nuevo.',
			'profile.changePassword.incorrectPassword' => 'La contraseña actual es incorrecta.',
			'profile.editProfile.title' => 'Editar perfil',
			'profile.editProfile.sections.personalInfo' => 'Información personal',
			'profile.editProfile.sections.aboutMe' => 'Sobre mí',
			'profile.editProfile.sections.favoriteDances' => 'Bailes favoritos',
			'profile.editProfile.sections.level' => 'Nivel',
			'profile.editProfile.sections.socialNetworks' => 'Redes sociales',
			'profile.editProfile.sections.notifications' => 'Notificaciones',
			'profile.editProfile.changePhoto' => 'Cambiar foto',
			'profile.editProfile.bio' => 'Descripción',
			'profile.editProfile.bioHint' => 'Escribe algo sobre ti...',
			'profile.editProfile.selectDanceStyles' => 'Selecciona tus estilos de baile favoritos',
			'profile.editProfile.yourLevel' => 'Tu nivel de baile',
			'profile.editProfile.instagram' => 'Instagram',
			'profile.editProfile.instagramHint' => '@tu_usuario',
			'profile.editProfile.facebook' => 'Facebook',
			'profile.editProfile.facebookHint' => 'facebook.com/tu.nombre',
			'profile.editProfile.notifications.newEvents' => 'Nuevos eventos',
			'profile.editProfile.notifications.eventReminders' => 'Recordatorios de eventos',
			'profile.editProfile.notifications.marketing' => 'Mensajes de marketing',
			'profile.editProfile.notificationSubtitles.newEvents' => 'Recibe notificaciones sobre nuevos eventos en tu zona',
			'profile.editProfile.notificationSubtitles.eventReminders' => 'Recordatorios antes de tus eventos guardados',
			'profile.editProfile.notificationSubtitles.marketing' => 'Mensajes promocionales y ofertas',
			'profile.editProfile.save' => 'Guardar cambios',
			'profile.editProfile.updateSuccess' => 'Perfil actualizado con éxito.',
			'profile.editProfile.updateError' => 'Error al actualizar el perfil. Por favor, inténtalo de nuevo.',
			'profile.editProfile.experienceLevels.beginner' => 'Principiante',
			'profile.editProfile.experienceLevels.slightlyAdvanced' => 'Ligeramente avanzado',
			'profile.editProfile.experienceLevels.advanced' => 'Avanzado',
			'profile.editProfile.experienceLevels.expert' => 'Experto',
			'profile.editProfile.avatar.sourceTitle' => 'Cambiar foto de perfil',
			'profile.editProfile.avatar.takePhoto' => 'Tomar una foto',
			'profile.editProfile.avatar.chooseFromGallery' => 'Elegir de la galería',
			'profile.editProfile.avatar.uploadError' => 'Error al subir la foto. Por favor, inténtalo de nuevo.',
			'profile.editProfile.avatar.linkError' => 'Error al actualizar la foto de perfil. Por favor, inténtalo de nuevo.',
			'profile.editProfile.avatar.permissionRequired' => 'Se requiere permiso de cámara o galería para cambiar tu foto.',
			'profile.editProfile.avatar.permissionDeniedTitle' => 'Permiso requerido',
			'profile.editProfile.avatar.permissionDeniedMessage' => 'Has denegado el acceso permanentemente. Por favor, actívalo en la configuración de tu dispositivo para cambiar tu foto de perfil.',
			'profile.editProfile.avatar.openSettings' => 'Abrir configuración',
			'premium.title' => 'Dancee Premium',
			'premium.bannerSubtitle' => 'Desbloquea todas las funciones',
			'premium.heroTitle' => 'Desbloquea todo el potencial',
			'premium.heroSubtitle' => 'Obtén acceso a todas las funciones premium y mejora tus experiencias de baile',
			'premium.featuresTitle' => 'Qué obtienes con Premium',
			'premium.testimonialsTitle' => 'Qué dicen nuestros usuarios',
			'premium.faqTitle' => 'Preguntas frecuentes',
			'premium.ctaTitle' => '¿Listo para empezar?',
			'premium.ctaSubtitle' => 'Únete a miles de bailarines satisfechos',
			'premium.ctaButton' => 'Obtener Premium ahora',
			'premium.ctaNote' => '7 días gratis · Cancela cuando quieras',
			'saved.title' => 'Eventos guardados',
			'saved.subtitle' => 'Tus eventos favoritos',
			'saved.emptyTitle' => 'Sin eventos guardados',
			'saved.emptySubtitle' => 'Los eventos que guardes aparecerán aquí',
			'authGate.title' => 'Inicio de sesión requerido',
			'authGate.message' => 'Crea una cuenta o inicia sesión para acceder a tus eventos guardados y perfil.',
			'authGate.actionMessage' => 'Necesitas iniciar sesión para usar esta función.',
			'authGate.login' => 'Iniciar sesión',
			'authGate.register' => 'Crear cuenta',
			'authGate.logoutTitle' => 'Sesión cerrada correctamente',
			'authGate.logoutMessage' => 'Puedes iniciar sesión de nuevo en cualquier momento.',
			'contact.teamName' => 'Equipo Dancee',
			'contact.description' => 'Nos encantaría leer tus comentarios...',
			'contact.responseTime' => 'Tiempo de respuesta',
			'contact.responseTimeDetail' => 'Normalmente respondemos en 24 horas en días laborables. ¡Gracias por tu paciencia!',
			'contact.deviceInfo' => 'Información del dispositivo',
			'contact.autoAttached' => 'Adjuntado automáticamente',
			'contact.form.subject' => 'Asunto del mensaje',
			'contact.form.feedback' => 'Comentario',
			'contact.form.reportBug' => 'Reportar error',
			'contact.form.featureRequest' => 'Sugerencia de mejora',
			'contact.form.other' => 'Otro',
			'contact.form.title' => 'Título del mensaje',
			'contact.form.titleHint' => 'Describe brevemente tu problema o sugerencia',
			'contact.form.message' => 'Mensaje',
			'contact.form.messageHint' => 'Describe tu problema en detalle...',
			'contact.form.replyEmail' => 'Tu e-mail de respuesta',
			'contact.form.sending' => 'Enviando...',
			'contact.form.sent' => '¡Enviado!',
			'contact.form.submit' => 'Enviar mensaje',
			'contact.form.success' => 'Tu mensaje ha sido enviado. ¡Nos pondremos en contacto contigo pronto!',
			'contact.form.error' => 'Error al enviar el mensaje. Por favor, inténtalo de nuevo.',
			'contact.form.typeRequired' => 'Por favor, selecciona un tipo de mensaje',
			'contact.form.titleRequired' => 'Por favor, ingresa un título',
			'contact.form.messageRequired' => 'Por favor, ingresa un mensaje',
			'contact.form.emailRequired' => 'Por favor, ingresa tu e-mail de respuesta',
			'contact.deviceInfoLabels.app' => 'App:',
			'contact.deviceInfoLabels.device' => 'Dispositivo:',
			'contact.deviceInfoLabels.os' => 'Sistema:',
			_ => null,
		};
	}
}
