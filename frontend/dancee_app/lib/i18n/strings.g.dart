/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 3
/// Strings: 969 (323 per locale)
///
/// Built on 2026-04-24 at 03:23 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, Translations> {
	en(languageCode: 'en', build: Translations.build),
	cs(languageCode: 'cs', build: _StringsCs.build),
	es(languageCode: 'es', build: _StringsEs.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, Translations> build;

	/// Gets current instance managed by [LocaleSettings].
	Translations get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
Translations get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class TranslationProvider extends BaseTranslationProvider<AppLocale, Translations> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, Translations> of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	Translations get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, Translations> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, Translations> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	// Translations
	late final _StringsCommonEn common = _StringsCommonEn._(_root);
	late final _StringsNavEn nav = _StringsNavEn._(_root);
	late final _StringsAuthEn auth = _StringsAuthEn._(_root);
	late final _StringsApiEn api = _StringsApiEn._(_root);
	late final _StringsValidationEn validation = _StringsValidationEn._(_root);
	late final _StringsOnboardingEn onboarding = _StringsOnboardingEn._(_root);
	late final _StringsEventsEn events = _StringsEventsEn._(_root);
	late final _StringsCoursesEn courses = _StringsCoursesEn._(_root);
	late final _StringsProfileEn profile = _StringsProfileEn._(_root);
	late final _StringsPremiumEn premium = _StringsPremiumEn._(_root);
	late final _StringsSavedEn saved = _StringsSavedEn._(_root);
	late final _StringsContactEn contact = _StringsContactEn._(_root);
}

// Path: common
class _StringsCommonEn {
	_StringsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get appName => 'Dancee';
	String get showAll => 'Show all';
	late final _StringsCommonMonthsEn months = _StringsCommonMonthsEn._(_root);
	String get date => 'Date';
	String get save => 'Save';
	String get share => 'Share';
	String get map => 'Map';
	String get skip => 'Skip';
	String get continue_ => 'Continue';
	String get back => 'Back';
	String get finish => 'Finish';
	String get cancel => 'Cancel';
	String get support => 'Support';
	String get faq => 'FAQ';
	String get clear => 'Clear';
	String get clearFilters => 'Clear filters';
	String get current => 'Current';
	String get saveChanges => 'Save changes';
	String get loading => 'Loading...';
	String get retry => 'Retry';
	String from({required Object time}) => 'From ${time}';
	late final _StringsCommonFormEn form = _StringsCommonFormEn._(_root);
}

// Path: nav
class _StringsNavEn {
	_StringsNavEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get events => 'Events';
	String get courses => 'Courses';
	String get saved => 'Saved';
	String get profile => 'Profile';
}

// Path: auth
class _StringsAuthEn {
	_StringsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get tagline => 'Discover the dancing world';
	String get orContinueWith => 'or continue with';
	String get continueWithGoogle => 'Continue with Google';
	String get continueWithApple => 'Continue with Apple';
	String get termsPrefix => 'By continuing you agree to our ';
	String get termsOfUse => 'Terms of use';
	String get and => ' and ';
	String get privacyPolicy => 'Privacy policy';
	String get agreeWith => 'I agree with ';
	String get orRegisterWith => 'or register with';
	late final _StringsAuthLoginEn login = _StringsAuthLoginEn._(_root);
	late final _StringsAuthRegisterEn register = _StringsAuthRegisterEn._(_root);
	late final _StringsAuthForgotPasswordEn forgotPassword = _StringsAuthForgotPasswordEn._(_root);
	late final _StringsAuthPasswordStrengthEn passwordStrength = _StringsAuthPasswordStrengthEn._(_root);
	late final _StringsAuthErrorsEn errors = _StringsAuthErrorsEn._(_root);
	late final _StringsAuthEmailVerificationEn emailVerification = _StringsAuthEmailVerificationEn._(_root);
	late final _StringsAuthDeleteAccountEn deleteAccount = _StringsAuthDeleteAccountEn._(_root);
}

// Path: api
class _StringsApiEn {
	_StringsApiEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _StringsApiErrorsEn errors = _StringsApiErrorsEn._(_root);
}

// Path: validation
class _StringsValidationEn {
	_StringsValidationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get emailRequired => 'Please enter your email address';
	String get invalidEmail => 'Please enter a valid email address';
	String get fieldRequired => 'This field is required';
	String get passwordTooShort => 'Password must be at least 8 characters';
	String get passwordsDoNotMatch => 'Passwords do not match';
}

// Path: onboarding
class _StringsOnboardingEn {
	_StringsOnboardingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _StringsOnboardingStep1En step1 = _StringsOnboardingStep1En._(_root);
	late final _StringsOnboardingStep2En step2 = _StringsOnboardingStep2En._(_root);
	late final _StringsOnboardingStep3En step3 = _StringsOnboardingStep3En._(_root);
}

// Path: events
class _StringsEventsEn {
	_StringsEventsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get featuredEvents => 'Featured events';
	String get upcomingEvents => 'Upcoming events';
	String get noEventsFound => 'No events found';
	String get noEventsForFilter => 'No events match your current filters. Try adjusting your selection or clear all filters.';
	String get danceStyles => 'Dance styles';
	String get danceStylesLabel => 'DANCE STYLES';
	String get location => 'Location';
	late final _StringsEventsDetailEn detail = _StringsEventsDetailEn._(_root);
	late final _StringsEventsFilterEn filter = _StringsEventsFilterEn._(_root);
	late final _StringsEventsFiltersEn filters = _StringsEventsFiltersEn._(_root);
}

// Path: courses
class _StringsCoursesEn {
	_StringsCoursesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Dance courses';
	String get subtitle => 'Find your course';
	String get featuredCourses => 'Featured courses';
	String get allCourses => 'All courses';
	String get noCoursesFound => 'No courses found';
	String get noCoursesForFilter => 'No courses match your current filters. Try adjusting your selection or clear all filters.';
	late final _StringsCoursesCourseTypesEn courseTypes = _StringsCoursesCourseTypesEn._(_root);
	late final _StringsCoursesDetailEn detail = _StringsCoursesDetailEn._(_root);
}

// Path: profile
class _StringsProfileEn {
	_StringsProfileEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Profile';
	late final _StringsProfileSectionsEn sections = _StringsProfileSectionsEn._(_root);
	late final _StringsProfileAccountEn account = _StringsProfileAccountEn._(_root);
	late final _StringsProfileSettingsEn settings = _StringsProfileSettingsEn._(_root);
	late final _StringsProfileSupportEn support = _StringsProfileSupportEn._(_root);
	late final _StringsProfileAppInfoEn appInfo = _StringsProfileAppInfoEn._(_root);
	late final _StringsProfileDangerEn danger = _StringsProfileDangerEn._(_root);
	late final _StringsProfileChangePasswordEn changePassword = _StringsProfileChangePasswordEn._(_root);
	late final _StringsProfileEditProfileEn editProfile = _StringsProfileEditProfileEn._(_root);
}

// Path: premium
class _StringsPremiumEn {
	_StringsPremiumEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Dancee Premium';
	String get bannerSubtitle => 'Unlock all features';
	String get heroTitle => 'Unlock full potential';
	String get heroSubtitle => 'Get access to all premium features and improve your dance experiences';
	String get featuresTitle => 'What you get with Premium';
	String get testimonialsTitle => 'What our users say';
	String get faqTitle => 'Frequently asked questions';
	String get ctaTitle => 'Ready to start?';
	String get ctaSubtitle => 'Join thousands of satisfied dancers';
	String get ctaButton => 'Get Premium now';
	String get ctaNote => '7 days free · Cancel anytime';
}

// Path: saved
class _StringsSavedEn {
	_StringsSavedEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Saved events';
	String get subtitle => 'Your favorite events';
	String get emptyTitle => 'No saved events';
	String get emptySubtitle => 'Events you save will appear here';
}

// Path: contact
class _StringsContactEn {
	_StringsContactEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get teamName => 'Dancee Team';
	String get email => 'hello@dancee.app';
	String get description => 'We\'d love to read your feedback...';
	String get responseTime => 'Response time';
	String get responseTimeDetail => 'We usually respond within 24 hours on working days. Thank you for your patience!';
	String get deviceInfo => 'Device information';
	String get autoAttached => 'Automatically attached';
	late final _StringsContactFormEn form = _StringsContactFormEn._(_root);
	late final _StringsContactDeviceInfoLabelsEn deviceInfoLabels = _StringsContactDeviceInfoLabelsEn._(_root);
}

// Path: common.months
class _StringsCommonMonthsEn {
	_StringsCommonMonthsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get jan => 'Jan';
	String get feb => 'Feb';
	String get mar => 'Mar';
	String get apr => 'Apr';
	String get may => 'May';
	String get jun => 'Jun';
	String get jul => 'Jul';
	String get aug => 'Aug';
	String get sep => 'Sep';
	String get oct => 'Oct';
	String get nov => 'Nov';
	String get dec => 'Dec';
}

// Path: common.form
class _StringsCommonFormEn {
	_StringsCommonFormEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get email => 'E-mail';
	String get emailHint => 'your@email.com';
	String get password => 'Password';
	String get passwordPlaceholder => '••••••••';
	String get confirmPassword => 'Confirm password';
	String get firstName => 'First name';
	String get firstNameHint => 'Your first name';
	String get lastName => 'Last name';
	String get lastNameHint => 'Your last name';
	String get city => 'City';
	String get phone => 'Phone';
	String get fullName => 'Full name';
}

// Path: auth.login
class _StringsAuthLoginEn {
	_StringsAuthLoginEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Welcome back!';
	String get subtitle => 'Sign in and continue exploring dance events';
	String get stayLoggedIn => 'Stay logged in';
	String get forgotPassword => 'Forgot password?';
	String get submit => 'Sign in';
	String get noAccount => 'Don\'t have an account?';
	String get register => 'Register';
}

// Path: auth.register
class _StringsAuthRegisterEn {
	_StringsAuthRegisterEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Create an account';
	String get subtitle => 'Register and start exploring dance events';
	String get passwordsMatch => 'Passwords match';
	String get passwordsMismatch => 'Passwords don\'t match';
	String get newsletter => 'I want to receive news about dance events';
	String get submit => 'Create account';
	String get hasAccount => 'Already have an account?';
	String get login => 'Sign in';
}

// Path: auth.forgotPassword
class _StringsAuthForgotPasswordEn {
	_StringsAuthForgotPasswordEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Forgot password?';
	String get subtitle => 'Enter your email and we\'ll send you a link to reset your password';
	String get submit => 'Send link';
	String get checkInbox => 'Check your inbox';
	String get checkInboxDetail => 'After sending you\'ll receive an email with a link to reset your password. The link is valid for 24 hours.';
	String get rememberPassword => 'Remembered your password?';
	String get login => 'Sign in';
	String get needHelp => 'Need help?';
}

// Path: auth.passwordStrength
class _StringsAuthPasswordStrengthEn {
	_StringsAuthPasswordStrengthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get weak => 'Weak password';
	String get medium => 'Medium';
	String get strong => 'Strong password';
	String get veryStrong => 'Very strong';
	String get hint => 'At least 8 characters';
}

// Path: auth.errors
class _StringsAuthErrorsEn {
	_StringsAuthErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get invalidCredential => 'Invalid email or password';
	String get userDisabled => 'This account has been disabled';
	String get emailAlreadyInUse => 'An account with this email already exists';
	String get weakPassword => 'Password is too weak';
	String get tooManyRequests => 'Too many attempts. Please try again later';
	String get networkError => 'Network error. Please check your connection';
	String get generic => 'An error occurred. Please try again';
}

// Path: auth.emailVerification
class _StringsAuthEmailVerificationEn {
	_StringsAuthEmailVerificationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Verify your email';
	String subtitle({required Object email}) => 'We sent a verification email to ${email}';
	String get resend => 'Resend verification email';
	String get resendConfirmed => 'Verification email sent. Please check your inbox.';
	String get checkVerified => 'I\'ve verified my email';
	String get notVerifiedYet => 'Email not verified yet. Please check your inbox.';
	String get signOut => 'Sign out';
}

// Path: auth.deleteAccount
class _StringsAuthDeleteAccountEn {
	_StringsAuthDeleteAccountEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get confirmTitle => 'Delete account?';
	String get confirmBody => 'This action permanently removes all your data. This cannot be undone.';
	String get reauthPrompt => 'Please confirm your password to continue';
	String get success => 'Your account has been deleted';
	String get error => 'Failed to delete account. Please try again.';
}

// Path: api.errors
class _StringsApiErrorsEn {
	_StringsApiErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get connectionTimeout => 'Connection timed out. Please check your network.';
	String get receiveTimeout => 'Server took too long to respond. Please try again.';
	String get sendTimeout => 'Request timed out while sending. Please try again.';
	String get noConnection => 'No internet connection. Please check your network.';
	String get requestCancelled => 'Request was cancelled.';
	String get badRequest => 'Bad request. Please try again.';
	String get unauthorized => 'Session expired. Please sign in again.';
	String get forbidden => 'Access denied. Please contact support.';
	String get notFound => 'The requested resource was not found.';
	String get conflict => 'A conflict occurred. Please try again.';
	String get internalServerError => 'Server error. Please try again later.';
	String get badGateway => 'Server is temporarily unavailable. Please try again later.';
	String get serviceUnavailable => 'Service is unavailable. Please try again later.';
	String get clientError => 'An error occurred. Please try again.';
	String get serverError => 'Server error. Please try again later.';
	String get generic => 'An unexpected error occurred. Please try again.';
}

// Path: onboarding.step1
class _StringsOnboardingStep1En {
	_StringsOnboardingStep1En._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'What dances do you like?';
	String get subtitle => 'Choose your favorite dance styles so we can offer you relevant events';
}

// Path: onboarding.step2
class _StringsOnboardingStep2En {
	_StringsOnboardingStep2En._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'What is your level?';
	String get subtitle => 'It will help us recommend suitable events and courses';
}

// Path: onboarding.step3
class _StringsOnboardingStep3En {
	_StringsOnboardingStep3En._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Where are you located?';
	String get subtitle => 'We\'ll find the nearest dance events in your area';
	String get radius10km => '10 km';
	String get radius25km => '25 km';
	String get radius50km => '50 km';
	String get radiusAll => 'Whole country';
	String get cityHint => 'E.g. Prague, Brno...';
	String get searchRadius => 'Search events within radius';
	String get useCurrentLocation => 'Use current location';
}

// Path: events.detail
class _StringsEventsDetailEn {
	_StringsEventsDetailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get header => 'Event detail';
	String get description => 'Event description';
	String get additionalInfo => 'Additional information';
	String get admission => 'Admission';
	String get dresscode => 'Dresscode';
	String get buyTickets => 'Buy tickets';
	String get originalSource => 'Original source';
	String get program => 'Event program';
	String get notFound => 'Event not found';
	String lector({required Object name}) => 'Lector: ${name}';
	String dj({required Object name}) => 'DJ: ${name}';
}

// Path: events.filter
class _StringsEventsFilterEn {
	_StringsEventsFilterEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String selectedCount({required Object count}) => '${count} selected';
	String get selectedStyles => 'SELECTED STYLES';
	String get apply => 'Apply filter';
	String applyCount({required Object count}) => 'Apply filter (${count})';
	String get selectLocation => 'Select location';
	String get searchCityHint => 'Search city or area...';
	String get useMyLocation => 'Use my location';
	String get useMyLocationSubtitle => 'Automatically finds events near you';
	String get popularCities => 'Popular cities';
	String get allCities => 'All cities';
	String get selectedRegions => 'SELECTED REGIONS';
	String get noResults => 'No results found';
	String get abroad => 'Abroad';
	String get unknownRegion => 'Unknown location';
}

// Path: events.filters
class _StringsEventsFiltersEn {
	_StringsEventsFiltersEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get today => 'Today';
	String get thisWeek => 'This week';
	String get thisMonth => 'This month';
	String get thisWeekend => 'This weekend';
	String get all => 'All';
	String get evening => 'Evening';
	String get weekend => 'Weekend';
	String get multiDay => 'Multi-day';
}

// Path: courses.courseTypes
class _StringsCoursesCourseTypesEn {
	_StringsCoursesCourseTypesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get all => 'All';
	String get workshop => 'Workshop';
	String get regular => 'Regular course';
}

// Path: courses.detail
class _StringsCoursesDetailEn {
	_StringsCoursesDetailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get header => 'Course detail';
	String get notFound => 'Course not found';
	String get description => 'Course description';
	String get details => 'Course details';
	String get whatYouLearn => 'What you\'ll learn';
	String get aboutInstructor => 'About instructor';
	String get shareCourse => 'Share course';
	String get coursePrice => 'Course price';
	String get priceUnknown => 'Price not specified';
	String get availableSpots => 'Available spots';
	String get register => 'Register for course';
	String get startDate => 'Start date';
	String get endDate => 'End date';
	String get day => 'Day';
	String get time => 'Time';
	String get lessons => 'Lessons';
	String get duration => 'Duration';
	String get level => 'Level';
	late final _StringsCoursesDetailLevelsEn levels = _StringsCoursesDetailLevelsEn._(_root);
	late final _StringsCoursesDetailDaysEn days = _StringsCoursesDetailDaysEn._(_root);
	String lessonsCount({required Object count}) => '${count} lessons';
	String durationMin({required Object count}) => '${count} min';
	String participantsCount({required Object current, required Object max}) => '${current} / ${max} participants';
	String spotsAvailable({required Object count}) => '${count} spots available';
}

// Path: profile.sections
class _StringsProfileSectionsEn {
	_StringsProfileSectionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get account => 'Account';
	String get settings => 'Settings';
	String get support => 'Support';
	String get appInfo => 'About app';
	String get dangerZone => 'Danger zone';
}

// Path: profile.account
class _StringsProfileAccountEn {
	_StringsProfileAccountEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get editProfile => 'Edit profile';
	String get changePassword => 'Change password';
}

// Path: profile.settings
class _StringsProfileSettingsEn {
	_StringsProfileSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get language => 'Language';
	String get czech => 'Czech';
	String get notifications => 'Notifications';
	String get english => 'English';
	String get spanish => 'Spanish';
}

// Path: profile.support
class _StringsProfileSupportEn {
	_StringsProfileSupportEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get contactAuthor => 'Contact author';
	String get rateApp => 'Rate app';
}

// Path: profile.appInfo
class _StringsProfileAppInfoEn {
	_StringsProfileAppInfoEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get version => 'App version';
	String get termsOfUse => 'Terms of use';
	String get privacy => 'Privacy';
}

// Path: profile.danger
class _StringsProfileDangerEn {
	_StringsProfileDangerEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get logout => 'Log out';
	String get logoutConfirmBody => 'Are you sure you want to log out?';
	String get deleteAccount => 'Delete account';
}

// Path: profile.changePassword
class _StringsProfileChangePasswordEn {
	_StringsProfileChangePasswordEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Change password';
	String get secureAccount => 'Secure your account';
	String get secureAccountDetail => 'A strong password must contain at least 8 characters, uppercase and lowercase letters, numbers and special characters.';
	String get currentPassword => 'Current password';
	String get currentPasswordHint => 'Enter current password';
	String get newPassword => 'New password';
	String get newPasswordHint => 'Enter new password';
	String get confirmPassword => 'Confirm new password';
	String get confirmPasswordHint => 'Enter new password again';
	String get save => 'Save new password';
	String get requirements => 'PASSWORD REQUIREMENTS';
	String get req8chars => 'Minimum 8 characters';
	String get reqUppercase => 'At least one uppercase letter (A-Z)';
	String get reqLowercase => 'At least one lowercase letter (a-z)';
	String get reqNumber => 'At least one number (0-9)';
	String get reqSpecial => 'At least one special character (!@#\$%^&*)';
	String get forgotPassword => 'Forgot your password?';
	String get strengthVeryWeak => 'Password strength: Very weak';
	String get strengthWeak => 'Password strength: Weak';
	String get strengthMedium => 'Password strength: Medium';
	String get strengthStrong => 'Password strength: Strong';
}

// Path: profile.editProfile
class _StringsProfileEditProfileEn {
	_StringsProfileEditProfileEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Edit profile';
	late final _StringsProfileEditProfileSectionsEn sections = _StringsProfileEditProfileSectionsEn._(_root);
	String get changePhoto => 'Change photo';
	String get bio => 'Description';
	String get bioHint => 'Write something about yourself...';
	String get selectDanceStyles => 'Select your favorite dance styles';
	String get yourLevel => 'Your dance level';
	String get instagram => 'Instagram';
	String get instagramHint => '@your_username';
	String get facebook => 'Facebook';
	String get facebookHint => 'facebook.com/your.name';
	late final _StringsProfileEditProfileNotificationsEn notifications = _StringsProfileEditProfileNotificationsEn._(_root);
	late final _StringsProfileEditProfileNotificationSubtitlesEn notificationSubtitles = _StringsProfileEditProfileNotificationSubtitlesEn._(_root);
}

// Path: contact.form
class _StringsContactFormEn {
	_StringsContactFormEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get subject => 'Message subject';
	String get feedback => 'Feedback';
	String get reportBug => 'Report bug';
	String get featureRequest => 'Feature request';
	String get other => 'Other';
	String get title => 'Message title';
	String get titleHint => 'Briefly describe your issue or suggestion';
	String get message => 'Message';
	String get messageHint => 'Describe your issue in detail...';
	String get replyEmail => 'Your reply email';
	String get sending => 'Sending...';
	String get sent => 'Sent!';
	String get submit => 'Send message';
}

// Path: contact.deviceInfoLabels
class _StringsContactDeviceInfoLabelsEn {
	_StringsContactDeviceInfoLabelsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get app => 'App:';
	String get device => 'Device:';
	String get os => 'System:';
}

// Path: courses.detail.levels
class _StringsCoursesDetailLevelsEn {
	_StringsCoursesDetailLevelsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get beginner => 'Beginner';
	String get intermediate => 'Intermediate';
	String get advanced => 'Advanced';
	String get allLevels => 'All levels';
}

// Path: courses.detail.days
class _StringsCoursesDetailDaysEn {
	_StringsCoursesDetailDaysEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get monday => 'Monday';
	String get tuesday => 'Tuesday';
	String get wednesday => 'Wednesday';
	String get thursday => 'Thursday';
	String get friday => 'Friday';
	String get saturday => 'Saturday';
	String get sunday => 'Sunday';
}

// Path: profile.editProfile.sections
class _StringsProfileEditProfileSectionsEn {
	_StringsProfileEditProfileSectionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get personalInfo => 'Personal information';
	String get aboutMe => 'About me';
	String get favoriteDances => 'Favorite dances';
	String get level => 'Level';
	String get socialNetworks => 'Social networks';
	String get notifications => 'Notifications';
}

// Path: profile.editProfile.notifications
class _StringsProfileEditProfileNotificationsEn {
	_StringsProfileEditProfileNotificationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get newEvents => 'New events';
	String get eventReminders => 'Event reminders';
	String get marketing => 'Marketing messages';
}

// Path: profile.editProfile.notificationSubtitles
class _StringsProfileEditProfileNotificationSubtitlesEn {
	_StringsProfileEditProfileNotificationSubtitlesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get newEvents => 'Get notified about new events in your area';
	String get eventReminders => 'Reminders before your saved events';
	String get marketing => 'Promotional messages and offers';
}

// Path: <root>
class _StringsCs extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsCs.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.cs,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <cs>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	@override late final _StringsCs _root = this; // ignore: unused_field

	// Translations
	@override late final _StringsCommonCs common = _StringsCommonCs._(_root);
	@override late final _StringsNavCs nav = _StringsNavCs._(_root);
	@override late final _StringsAuthCs auth = _StringsAuthCs._(_root);
	@override late final _StringsApiCs api = _StringsApiCs._(_root);
	@override late final _StringsValidationCs validation = _StringsValidationCs._(_root);
	@override late final _StringsOnboardingCs onboarding = _StringsOnboardingCs._(_root);
	@override late final _StringsEventsCs events = _StringsEventsCs._(_root);
	@override late final _StringsCoursesCs courses = _StringsCoursesCs._(_root);
	@override late final _StringsProfileCs profile = _StringsProfileCs._(_root);
	@override late final _StringsPremiumCs premium = _StringsPremiumCs._(_root);
	@override late final _StringsSavedCs saved = _StringsSavedCs._(_root);
	@override late final _StringsContactCs contact = _StringsContactCs._(_root);
}

// Path: common
class _StringsCommonCs extends _StringsCommonEn {
	_StringsCommonCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Dancee';
	@override String get showAll => 'Zobrazit vše';
	@override late final _StringsCommonMonthsCs months = _StringsCommonMonthsCs._(_root);
	@override String get date => 'Datum';
	@override String get save => 'Uložit';
	@override String get share => 'Sdílet';
	@override String get map => 'Mapa';
	@override String get skip => 'Přeskočit';
	@override String get continue_ => 'Pokračovat';
	@override String get back => 'Zpět';
	@override String get finish => 'Dokončit';
	@override String get cancel => 'Zrušit';
	@override String get support => 'Podpora';
	@override String get faq => 'FAQ';
	@override String get clear => 'Vymazat';
	@override String get clearFilters => 'Vymazat filtry';
	@override String get current => 'Aktuální';
	@override String get saveChanges => 'Uložit změny';
	@override String get loading => 'Načítání...';
	@override String get retry => 'Zkusit znovu';
	@override String from({required Object time}) => 'Od ${time}';
	@override late final _StringsCommonFormCs form = _StringsCommonFormCs._(_root);
}

// Path: nav
class _StringsNavCs extends _StringsNavEn {
	_StringsNavCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get events => 'Události';
	@override String get courses => 'Kurzy';
	@override String get saved => 'Uložené';
	@override String get profile => 'Profil';
}

// Path: auth
class _StringsAuthCs extends _StringsAuthEn {
	_StringsAuthCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'Objevuj taneční svět';
	@override String get orContinueWith => 'nebo pokračuj s';
	@override String get continueWithGoogle => 'Pokračovat s Google';
	@override String get continueWithApple => 'Pokračovat s Apple';
	@override String get termsPrefix => 'Pokračováním souhlasíš s našimi ';
	@override String get termsOfUse => 'Podmínkami používání';
	@override String get and => ' a ';
	@override String get privacyPolicy => 'Zásadami ochrany osobních údajů';
	@override String get agreeWith => 'Souhlasím s ';
	@override String get orRegisterWith => 'nebo se zaregistruj s';
	@override late final _StringsAuthLoginCs login = _StringsAuthLoginCs._(_root);
	@override late final _StringsAuthRegisterCs register = _StringsAuthRegisterCs._(_root);
	@override late final _StringsAuthForgotPasswordCs forgotPassword = _StringsAuthForgotPasswordCs._(_root);
	@override late final _StringsAuthPasswordStrengthCs passwordStrength = _StringsAuthPasswordStrengthCs._(_root);
	@override late final _StringsAuthErrorsCs errors = _StringsAuthErrorsCs._(_root);
	@override late final _StringsAuthEmailVerificationCs emailVerification = _StringsAuthEmailVerificationCs._(_root);
	@override late final _StringsAuthDeleteAccountCs deleteAccount = _StringsAuthDeleteAccountCs._(_root);
}

// Path: api
class _StringsApiCs extends _StringsApiEn {
	_StringsApiCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override late final _StringsApiErrorsCs errors = _StringsApiErrorsCs._(_root);
}

// Path: validation
class _StringsValidationCs extends _StringsValidationEn {
	_StringsValidationCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get emailRequired => 'Zadejte prosím svou e-mailovou adresu';
	@override String get invalidEmail => 'Zadejte prosím platnou e-mailovou adresu';
	@override String get fieldRequired => 'Toto pole je povinné';
	@override String get passwordTooShort => 'Heslo musí mít alespoň 8 znaků';
	@override String get passwordsDoNotMatch => 'Hesla se neshodují';
}

// Path: onboarding
class _StringsOnboardingCs extends _StringsOnboardingEn {
	_StringsOnboardingCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override late final _StringsOnboardingStep1Cs step1 = _StringsOnboardingStep1Cs._(_root);
	@override late final _StringsOnboardingStep2Cs step2 = _StringsOnboardingStep2Cs._(_root);
	@override late final _StringsOnboardingStep3Cs step3 = _StringsOnboardingStep3Cs._(_root);
}

// Path: events
class _StringsEventsCs extends _StringsEventsEn {
	_StringsEventsCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get featuredEvents => 'Doporučené akce';
	@override String get upcomingEvents => 'Nadcházející akce';
	@override String get noEventsFound => 'Žádné akce nenalezeny';
	@override String get noEventsForFilter => 'Pro zvolené filtry nebyly nalezeny žádné akce. Zkuste upravit výběr nebo vymazat filtry.';
	@override String get danceStyles => 'Taneční styly';
	@override String get danceStylesLabel => 'TANEČNÍ STYLY';
	@override String get location => 'Lokalita';
	@override late final _StringsEventsDetailCs detail = _StringsEventsDetailCs._(_root);
	@override late final _StringsEventsFilterCs filter = _StringsEventsFilterCs._(_root);
	@override late final _StringsEventsFiltersCs filters = _StringsEventsFiltersCs._(_root);
}

// Path: courses
class _StringsCoursesCs extends _StringsCoursesEn {
	_StringsCoursesCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Taneční kurzy';
	@override String get subtitle => 'Najdi svůj kurz';
	@override String get featuredCourses => 'Doporučené kurzy';
	@override String get allCourses => 'Všechny kurzy';
	@override String get noCoursesFound => 'Žádné kurzy nenalezeny';
	@override String get noCoursesForFilter => 'Pro zvolené filtry nebyly nalezeny žádné kurzy. Zkuste upravit výběr nebo vymazat filtry.';
	@override late final _StringsCoursesCourseTypesCs courseTypes = _StringsCoursesCourseTypesCs._(_root);
	@override late final _StringsCoursesDetailCs detail = _StringsCoursesDetailCs._(_root);
}

// Path: profile
class _StringsProfileCs extends _StringsProfileEn {
	_StringsProfileCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Profil';
	@override late final _StringsProfileSectionsCs sections = _StringsProfileSectionsCs._(_root);
	@override late final _StringsProfileAccountCs account = _StringsProfileAccountCs._(_root);
	@override late final _StringsProfileSettingsCs settings = _StringsProfileSettingsCs._(_root);
	@override late final _StringsProfileSupportCs support = _StringsProfileSupportCs._(_root);
	@override late final _StringsProfileAppInfoCs appInfo = _StringsProfileAppInfoCs._(_root);
	@override late final _StringsProfileDangerCs danger = _StringsProfileDangerCs._(_root);
	@override late final _StringsProfileChangePasswordCs changePassword = _StringsProfileChangePasswordCs._(_root);
	@override late final _StringsProfileEditProfileCs editProfile = _StringsProfileEditProfileCs._(_root);
}

// Path: premium
class _StringsPremiumCs extends _StringsPremiumEn {
	_StringsPremiumCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dancee Premium';
	@override String get bannerSubtitle => 'Odemkněte všechny funkce';
	@override String get heroTitle => 'Odemkněte plný potenciál';
	@override String get heroSubtitle => 'Získejte přístup ke všem prémiové funkcím a zlepšete své taneční zážitky';
	@override String get featuresTitle => 'Co získáte s Premium';
	@override String get testimonialsTitle => 'Co říkají naši uživatelé';
	@override String get faqTitle => 'Časté otázky';
	@override String get ctaTitle => 'Připraveni začít?';
	@override String get ctaSubtitle => 'Připojte se k tisícům spokojených tanečníků';
	@override String get ctaButton => 'Získat Premium nyní';
	@override String get ctaNote => '7 dní zdarma · Zrušte kdykoliv';
}

// Path: saved
class _StringsSavedCs extends _StringsSavedEn {
	_StringsSavedCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Uložené akce';
	@override String get subtitle => 'Tvoje oblíbené akce';
	@override String get emptyTitle => 'Žádné uložené akce';
	@override String get emptySubtitle => 'Akce, které si uložíš, se zobrazí zde';
}

// Path: contact
class _StringsContactCs extends _StringsContactEn {
	_StringsContactCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get teamName => 'Tým Dancee';
	@override String get email => 'hello@dancee.app';
	@override String get description => 'Rádi si přečteme vaše zpětné vazby...';
	@override String get responseTime => 'Doba odezvy';
	@override String get responseTimeDetail => 'Obvykle odpovídáme do 24 hodin v pracovní dny. Děkujeme za trpělivost!';
	@override String get deviceInfo => 'Informace o zařízení';
	@override String get autoAttached => 'Automaticky přiloženo';
	@override late final _StringsContactFormCs form = _StringsContactFormCs._(_root);
	@override late final _StringsContactDeviceInfoLabelsCs deviceInfoLabels = _StringsContactDeviceInfoLabelsCs._(_root);
}

// Path: common.months
class _StringsCommonMonthsCs extends _StringsCommonMonthsEn {
	_StringsCommonMonthsCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get jan => 'Led';
	@override String get feb => 'Úno';
	@override String get mar => 'Bře';
	@override String get apr => 'Dub';
	@override String get may => 'Kvě';
	@override String get jun => 'Čvn';
	@override String get jul => 'Čvc';
	@override String get aug => 'Srp';
	@override String get sep => 'Zář';
	@override String get oct => 'Říj';
	@override String get nov => 'Lis';
	@override String get dec => 'Pro';
}

// Path: common.form
class _StringsCommonFormCs extends _StringsCommonFormEn {
	_StringsCommonFormCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get email => 'E-mail';
	@override String get emailHint => 'tvuj@email.cz';
	@override String get password => 'Heslo';
	@override String get passwordPlaceholder => '••••••••';
	@override String get confirmPassword => 'Potvrzení hesla';
	@override String get firstName => 'Jméno';
	@override String get firstNameHint => 'Tvoje jméno';
	@override String get lastName => 'Příjmení';
	@override String get lastNameHint => 'Tvoje příjmení';
	@override String get city => 'Město';
	@override String get phone => 'Telefon';
	@override String get fullName => 'Jméno a příjmení';
}

// Path: auth.login
class _StringsAuthLoginCs extends _StringsAuthLoginEn {
	_StringsAuthLoginCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vítej zpět!';
	@override String get subtitle => 'Přihlaš se a pokračuj v objevování tanečních akcí';
	@override String get stayLoggedIn => 'Zůstat přihlášen';
	@override String get forgotPassword => 'Zapomenuté heslo?';
	@override String get submit => 'Přihlásit se';
	@override String get noAccount => 'Nemáš ještě účet?';
	@override String get register => 'Zaregistruj se';
}

// Path: auth.register
class _StringsAuthRegisterCs extends _StringsAuthRegisterEn {
	_StringsAuthRegisterCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vytvoř si účet';
	@override String get subtitle => 'Zaregistruj se a začni objevovat taneční akce';
	@override String get passwordsMatch => 'Hesla se shodují';
	@override String get passwordsMismatch => 'Hesla se neshodují';
	@override String get newsletter => 'Chci dostávat novinky o tanečních akcích';
	@override String get submit => 'Vytvořit účet';
	@override String get hasAccount => 'Už máš účet?';
	@override String get login => 'Přihlaš se';
}

// Path: auth.forgotPassword
class _StringsAuthForgotPasswordCs extends _StringsAuthForgotPasswordEn {
	_StringsAuthForgotPasswordCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zapomenuté heslo?';
	@override String get subtitle => 'Zadej svůj e-mail a pošleme ti odkaz pro obnovení hesla';
	@override String get submit => 'Odeslat odkaz';
	@override String get checkInbox => 'Zkontroluj svou e-mailovou schránku';
	@override String get checkInboxDetail => 'Po odeslání obdržíš e-mail s odkazem pro obnovení hesla. Odkaz je platný 24 hodin.';
	@override String get rememberPassword => 'Vzpomněl sis na heslo?';
	@override String get login => 'Přihlásit se';
	@override String get needHelp => 'Potřebuješ pomoc?';
}

// Path: auth.passwordStrength
class _StringsAuthPasswordStrengthCs extends _StringsAuthPasswordStrengthEn {
	_StringsAuthPasswordStrengthCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get weak => 'Slabé heslo';
	@override String get medium => 'Středně silné';
	@override String get strong => 'Silné heslo';
	@override String get veryStrong => 'Velmi silné';
	@override String get hint => 'Alespoň 8 znaků';
}

// Path: auth.errors
class _StringsAuthErrorsCs extends _StringsAuthErrorsEn {
	_StringsAuthErrorsCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get invalidCredential => 'Neplatný e-mail nebo heslo';
	@override String get userDisabled => 'Tento účet byl deaktivován';
	@override String get emailAlreadyInUse => 'Účet s tímto e-mailem již existuje';
	@override String get weakPassword => 'Heslo je příliš slabé';
	@override String get tooManyRequests => 'Příliš mnoho pokusů. Zkuste to prosím později';
	@override String get networkError => 'Chyba sítě. Zkontrolujte své připojení';
	@override String get generic => 'Došlo k chybě. Zkuste to prosím znovu';
}

// Path: auth.emailVerification
class _StringsAuthEmailVerificationCs extends _StringsAuthEmailVerificationEn {
	_StringsAuthEmailVerificationCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ověřte svůj e-mail';
	@override String subtitle({required Object email}) => 'Zaslali jsme ověřovací e-mail na adresu ${email}';
	@override String get resend => 'Znovu odeslat ověřovací e-mail';
	@override String get resendConfirmed => 'Ověřovací e-mail odeslán. Zkontrolujte prosím svou doručenou poštu.';
	@override String get checkVerified => 'Ověřil jsem svůj e-mail';
	@override String get notVerifiedYet => 'E-mail ještě nebyl ověřen. Zkontrolujte prosím svou doručenou poštu.';
	@override String get signOut => 'Odhlásit se';
}

// Path: auth.deleteAccount
class _StringsAuthDeleteAccountCs extends _StringsAuthDeleteAccountEn {
	_StringsAuthDeleteAccountCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get confirmTitle => 'Smazat účet?';
	@override String get confirmBody => 'Tato akce trvale odstraní všechna vaše data. Tuto akci nelze vrátit zpět.';
	@override String get reauthPrompt => 'Pro pokračování potvrďte své heslo';
	@override String get success => 'Váš účet byl smazán';
	@override String get error => 'Nepodařilo se smazat účet. Zkuste to prosím znovu.';
}

// Path: api.errors
class _StringsApiErrorsCs extends _StringsApiErrorsEn {
	_StringsApiErrorsCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get connectionTimeout => 'Vypršel časový limit připojení. Zkontrolujte síťové připojení.';
	@override String get receiveTimeout => 'Server reagoval příliš pomalu. Zkuste to prosím znovu.';
	@override String get sendTimeout => 'Vypršel časový limit odesílání. Zkuste to prosím znovu.';
	@override String get noConnection => 'Žádné internetové připojení. Zkontrolujte své připojení.';
	@override String get requestCancelled => 'Požadavek byl zrušen.';
	@override String get badRequest => 'Chybný požadavek. Zkuste to prosím znovu.';
	@override String get unauthorized => 'Relace vypršela. Přihlaste se prosím znovu.';
	@override String get forbidden => 'Přístup odepřen. Kontaktujte prosím podporu.';
	@override String get notFound => 'Požadovaný zdroj nebyl nalezen.';
	@override String get conflict => 'Došlo ke konfliktu. Zkuste to prosím znovu.';
	@override String get internalServerError => 'Chyba serveru. Zkuste to prosím později.';
	@override String get badGateway => 'Server je dočasně nedostupný. Zkuste to prosím později.';
	@override String get serviceUnavailable => 'Služba není dostupná. Zkuste to prosím později.';
	@override String get clientError => 'Došlo k chybě. Zkuste to prosím znovu.';
	@override String get serverError => 'Chyba serveru. Zkuste to prosím později.';
	@override String get generic => 'Došlo k neočekávané chybě. Zkuste to prosím znovu.';
}

// Path: onboarding.step1
class _StringsOnboardingStep1Cs extends _StringsOnboardingStep1En {
	_StringsOnboardingStep1Cs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Jaké tance tě baví?';
	@override String get subtitle => 'Vyber své oblíbené taneční styly, abychom ti mohli nabídnout relevantní akce';
}

// Path: onboarding.step2
class _StringsOnboardingStep2Cs extends _StringsOnboardingStep2En {
	_StringsOnboardingStep2Cs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Jaká je tvoje úroveň?';
	@override String get subtitle => 'Pomůže nám to doporučit ti vhodné akce a kurzy';
}

// Path: onboarding.step3
class _StringsOnboardingStep3Cs extends _StringsOnboardingStep3En {
	_StringsOnboardingStep3Cs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kde se nacházíš?';
	@override String get subtitle => 'Najdeme pro tebe nejbližší taneční akce ve tvém okolí';
	@override String get radius10km => '10 km';
	@override String get radius25km => '25 km';
	@override String get radius50km => '50 km';
	@override String get radiusAll => 'Celá republika';
	@override String get cityHint => 'Např. Praha, Brno...';
	@override String get searchRadius => 'Vyhledat akce v okruhu';
	@override String get useCurrentLocation => 'Použít aktuální polohu';
}

// Path: events.detail
class _StringsEventsDetailCs extends _StringsEventsDetailEn {
	_StringsEventsDetailCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get header => 'Detail akce';
	@override String get description => 'Popis akce';
	@override String get additionalInfo => 'Dodatečné informace';
	@override String get admission => 'Vstupné';
	@override String get dresscode => 'Dresscode';
	@override String get buyTickets => 'Koupit vstupenky';
	@override String get originalSource => 'Původní zdroj';
	@override String get program => 'Program akce';
	@override String get notFound => 'Akce nenalezena';
	@override String lector({required Object name}) => 'Lektor: ${name}';
	@override String dj({required Object name}) => 'DJ: ${name}';
}

// Path: events.filter
class _StringsEventsFilterCs extends _StringsEventsFilterEn {
	_StringsEventsFilterCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String selectedCount({required Object count}) => '${count} vybraných';
	@override String get selectedStyles => 'VYBRANÉ STYLY';
	@override String get apply => 'Použít filtr';
	@override String applyCount({required Object count}) => 'Použít filtr (${count})';
	@override String get selectLocation => 'Vybrat lokalitu';
	@override String get searchCityHint => 'Hledat město nebo oblast...';
	@override String get useMyLocation => 'Použít moji polohu';
	@override String get useMyLocationSubtitle => 'Automaticky najde akce ve vašem okolí';
	@override String get popularCities => 'Oblíbená města';
	@override String get allCities => 'Všechna města';
	@override String get selectedRegions => 'VYBRANÉ OBLASTI';
	@override String get noResults => 'Žádné výsledky';
	@override String get abroad => 'Zahraničí';
	@override String get unknownRegion => 'Neznámá lokalita';
}

// Path: events.filters
class _StringsEventsFiltersCs extends _StringsEventsFiltersEn {
	_StringsEventsFiltersCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get today => 'Dnes';
	@override String get thisWeek => 'Tento týden';
	@override String get thisMonth => 'Tento měsíc';
	@override String get thisWeekend => 'Tento víkend';
	@override String get all => 'Vše';
	@override String get evening => 'Večerní';
	@override String get weekend => 'Víkendové';
	@override String get multiDay => 'Několikadenní';
}

// Path: courses.courseTypes
class _StringsCoursesCourseTypesCs extends _StringsCoursesCourseTypesEn {
	_StringsCoursesCourseTypesCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get all => 'Vše';
	@override String get workshop => 'Workshop';
	@override String get regular => 'Pravidelný kurz';
}

// Path: courses.detail
class _StringsCoursesDetailCs extends _StringsCoursesDetailEn {
	_StringsCoursesDetailCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get header => 'Detail kurzu';
	@override String get notFound => 'Kurz nenalezen';
	@override String get description => 'Popis kurzu';
	@override String get details => 'Podrobnosti kurzu';
	@override String get whatYouLearn => 'Co se naučíte';
	@override String get aboutInstructor => 'O lektorovi';
	@override String get shareCourse => 'Sdílet kurz';
	@override String get coursePrice => 'Cena kurzu';
	@override String get priceUnknown => 'Cena neuvedena';
	@override String get availableSpots => 'Volná místa';
	@override String get register => 'Registrovat se na kurz';
	@override String get startDate => 'Datum začátku';
	@override String get endDate => 'Datum konce';
	@override String get day => 'Den';
	@override String get time => 'Čas';
	@override String get lessons => 'Lekce';
	@override String get duration => 'Délka';
	@override String get level => 'Úroveň';
	@override late final _StringsCoursesDetailLevelsCs levels = _StringsCoursesDetailLevelsCs._(_root);
	@override late final _StringsCoursesDetailDaysCs days = _StringsCoursesDetailDaysCs._(_root);
	@override String lessonsCount({required Object count}) => '${count} lekcí';
	@override String durationMin({required Object count}) => '${count} min';
	@override String participantsCount({required Object current, required Object max}) => '${current} / ${max} účastníků';
	@override String spotsAvailable({required Object count}) => '${count} volných míst';
}

// Path: profile.sections
class _StringsProfileSectionsCs extends _StringsProfileSectionsEn {
	_StringsProfileSectionsCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get account => 'Účet';
	@override String get settings => 'Nastavení';
	@override String get support => 'Podpora';
	@override String get appInfo => 'O aplikaci';
	@override String get dangerZone => 'Nebezpečná zóna';
}

// Path: profile.account
class _StringsProfileAccountCs extends _StringsProfileAccountEn {
	_StringsProfileAccountCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get editProfile => 'Upravit profil';
	@override String get changePassword => 'Změnit heslo';
}

// Path: profile.settings
class _StringsProfileSettingsCs extends _StringsProfileSettingsEn {
	_StringsProfileSettingsCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get language => 'Jazyk';
	@override String get czech => 'Čeština';
	@override String get notifications => 'Oznámení';
	@override String get english => 'Angličtina';
	@override String get spanish => 'Španělština';
}

// Path: profile.support
class _StringsProfileSupportCs extends _StringsProfileSupportEn {
	_StringsProfileSupportCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get contactAuthor => 'Napsat autorovi';
	@override String get rateApp => 'Ohodnotit aplikaci';
}

// Path: profile.appInfo
class _StringsProfileAppInfoCs extends _StringsProfileAppInfoEn {
	_StringsProfileAppInfoCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get version => 'Verze aplikace';
	@override String get termsOfUse => 'Podmínky použití';
	@override String get privacy => 'Ochrana soukromí';
}

// Path: profile.danger
class _StringsProfileDangerCs extends _StringsProfileDangerEn {
	_StringsProfileDangerCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get logout => 'Odhlásit se';
	@override String get logoutConfirmBody => 'Opravdu se chcete odhlásit?';
	@override String get deleteAccount => 'Smazat účet';
}

// Path: profile.changePassword
class _StringsProfileChangePasswordCs extends _StringsProfileChangePasswordEn {
	_StringsProfileChangePasswordCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Změnit heslo';
	@override String get secureAccount => 'Zabezpečte svůj účet';
	@override String get secureAccountDetail => 'Silné heslo musí obsahovat alespoň 8 znaků, velká a malá písmena, čísla a speciální znaky.';
	@override String get currentPassword => 'Současné heslo';
	@override String get currentPasswordHint => 'Zadejte současné heslo';
	@override String get newPassword => 'Nové heslo';
	@override String get newPasswordHint => 'Zadejte nové heslo';
	@override String get confirmPassword => 'Potvrdit nové heslo';
	@override String get confirmPasswordHint => 'Zadejte nové heslo znovu';
	@override String get save => 'Uložit nové heslo';
	@override String get requirements => 'POŽADAVKY NA HESLO';
	@override String get req8chars => 'Minimálně 8 znaků';
	@override String get reqUppercase => 'Alespoň jedno velké písmeno (A-Z)';
	@override String get reqLowercase => 'Alespoň jedno malé písmeno (a-z)';
	@override String get reqNumber => 'Alespoň jedno číslo (0-9)';
	@override String get reqSpecial => 'Alespoň jeden speciální znak (!@#\$%^&*)';
	@override String get forgotPassword => 'Zapomněli jste heslo?';
	@override String get strengthVeryWeak => 'Síla hesla: Velmi slabé';
	@override String get strengthWeak => 'Síla hesla: Slabé';
	@override String get strengthMedium => 'Síla hesla: Střední';
	@override String get strengthStrong => 'Síla hesla: Silné';
}

// Path: profile.editProfile
class _StringsProfileEditProfileCs extends _StringsProfileEditProfileEn {
	_StringsProfileEditProfileCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Upravit profil';
	@override late final _StringsProfileEditProfileSectionsCs sections = _StringsProfileEditProfileSectionsCs._(_root);
	@override String get changePhoto => 'Změnit fotku';
	@override String get bio => 'Popis';
	@override String get bioHint => 'Napište něco o sobě...';
	@override String get selectDanceStyles => 'Vyberte své oblíbené tanční styly';
	@override String get yourLevel => 'Vaše taneční úroveň';
	@override String get instagram => 'Instagram';
	@override String get instagramHint => '@vase_uzivatelske_jmeno';
	@override String get facebook => 'Facebook';
	@override String get facebookHint => 'facebook.com/vase.jmeno';
	@override late final _StringsProfileEditProfileNotificationsCs notifications = _StringsProfileEditProfileNotificationsCs._(_root);
	@override late final _StringsProfileEditProfileNotificationSubtitlesCs notificationSubtitles = _StringsProfileEditProfileNotificationSubtitlesCs._(_root);
}

// Path: contact.form
class _StringsContactFormCs extends _StringsContactFormEn {
	_StringsContactFormCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get subject => 'Předmět zprávy';
	@override String get feedback => 'Zpětná vazba';
	@override String get reportBug => 'Nahlásit problém';
	@override String get featureRequest => 'Návrh na vylepšení';
	@override String get other => 'Ostatní';
	@override String get title => 'Název zprávy';
	@override String get titleHint => 'Stručně popište váš problém nebo návrh';
	@override String get message => 'Zpráva';
	@override String get messageHint => 'Podrobně popište váš problém...';
	@override String get replyEmail => 'Váš e-mail pro odpověď';
	@override String get sending => 'Odesílání...';
	@override String get sent => 'Odesláno!';
	@override String get submit => 'Odeslat zprávu';
}

// Path: contact.deviceInfoLabels
class _StringsContactDeviceInfoLabelsCs extends _StringsContactDeviceInfoLabelsEn {
	_StringsContactDeviceInfoLabelsCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get app => 'Aplikace:';
	@override String get device => 'Zařízení:';
	@override String get os => 'Systém:';
}

// Path: courses.detail.levels
class _StringsCoursesDetailLevelsCs extends _StringsCoursesDetailLevelsEn {
	_StringsCoursesDetailLevelsCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get beginner => 'Začátečník';
	@override String get intermediate => 'Mírně pokročilý';
	@override String get advanced => 'Pokročilý';
	@override String get allLevels => 'Všechny úrovně';
}

// Path: courses.detail.days
class _StringsCoursesDetailDaysCs extends _StringsCoursesDetailDaysEn {
	_StringsCoursesDetailDaysCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get monday => 'Pondělí';
	@override String get tuesday => 'Úterý';
	@override String get wednesday => 'Středa';
	@override String get thursday => 'Čtvrtek';
	@override String get friday => 'Pátek';
	@override String get saturday => 'Sobota';
	@override String get sunday => 'Neděle';
}

// Path: profile.editProfile.sections
class _StringsProfileEditProfileSectionsCs extends _StringsProfileEditProfileSectionsEn {
	_StringsProfileEditProfileSectionsCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get personalInfo => 'Osobní údaje';
	@override String get aboutMe => 'O mně';
	@override String get favoriteDances => 'Oblíbené tance';
	@override String get level => 'Úroveň';
	@override String get socialNetworks => 'Sociální sítě';
	@override String get notifications => 'Oznámení';
}

// Path: profile.editProfile.notifications
class _StringsProfileEditProfileNotificationsCs extends _StringsProfileEditProfileNotificationsEn {
	_StringsProfileEditProfileNotificationsCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get newEvents => 'Nové akce';
	@override String get eventReminders => 'Připomínky akcí';
	@override String get marketing => 'Marketingové zprávy';
}

// Path: profile.editProfile.notificationSubtitles
class _StringsProfileEditProfileNotificationSubtitlesCs extends _StringsProfileEditProfileNotificationSubtitlesEn {
	_StringsProfileEditProfileNotificationSubtitlesCs._(_StringsCs root) : this._root = root, super._(root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get newEvents => 'Dostávejte upozornění o nových akcích ve vašem okolí';
	@override String get eventReminders => 'Připomínky před vašimi uloženými akcemi';
	@override String get marketing => 'Propagační zprávy a nabídky';
}

// Path: <root>
class _StringsEs extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsEs.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	@override late final _StringsEs _root = this; // ignore: unused_field

	// Translations
	@override late final _StringsCommonEs common = _StringsCommonEs._(_root);
	@override late final _StringsNavEs nav = _StringsNavEs._(_root);
	@override late final _StringsAuthEs auth = _StringsAuthEs._(_root);
	@override late final _StringsApiEs api = _StringsApiEs._(_root);
	@override late final _StringsValidationEs validation = _StringsValidationEs._(_root);
	@override late final _StringsOnboardingEs onboarding = _StringsOnboardingEs._(_root);
	@override late final _StringsEventsEs events = _StringsEventsEs._(_root);
	@override late final _StringsCoursesEs courses = _StringsCoursesEs._(_root);
	@override late final _StringsProfileEs profile = _StringsProfileEs._(_root);
	@override late final _StringsPremiumEs premium = _StringsPremiumEs._(_root);
	@override late final _StringsSavedEs saved = _StringsSavedEs._(_root);
	@override late final _StringsContactEs contact = _StringsContactEs._(_root);
}

// Path: common
class _StringsCommonEs extends _StringsCommonEn {
	_StringsCommonEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Dancee';
	@override String get showAll => 'Ver todo';
	@override late final _StringsCommonMonthsEs months = _StringsCommonMonthsEs._(_root);
	@override String get date => 'Fecha';
	@override String get save => 'Guardar';
	@override String get share => 'Compartir';
	@override String get map => 'Mapa';
	@override String get skip => 'Omitir';
	@override String get continue_ => 'Continuar';
	@override String get back => 'Volver';
	@override String get finish => 'Finalizar';
	@override String get cancel => 'Cancelar';
	@override String get support => 'Soporte';
	@override String get faq => 'FAQ';
	@override String get clear => 'Limpiar';
	@override String get clearFilters => 'Borrar filtros';
	@override String get current => 'Actual';
	@override String get saveChanges => 'Guardar cambios';
	@override String get loading => 'Cargando...';
	@override String get retry => 'Reintentar';
	@override String from({required Object time}) => 'Desde ${time}';
	@override late final _StringsCommonFormEs form = _StringsCommonFormEs._(_root);
}

// Path: nav
class _StringsNavEs extends _StringsNavEn {
	_StringsNavEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get events => 'Eventos';
	@override String get courses => 'Cursos';
	@override String get saved => 'Guardados';
	@override String get profile => 'Perfil';
}

// Path: auth
class _StringsAuthEs extends _StringsAuthEn {
	_StringsAuthEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
	@override late final _StringsAuthLoginEs login = _StringsAuthLoginEs._(_root);
	@override late final _StringsAuthRegisterEs register = _StringsAuthRegisterEs._(_root);
	@override late final _StringsAuthForgotPasswordEs forgotPassword = _StringsAuthForgotPasswordEs._(_root);
	@override late final _StringsAuthPasswordStrengthEs passwordStrength = _StringsAuthPasswordStrengthEs._(_root);
	@override late final _StringsAuthErrorsEs errors = _StringsAuthErrorsEs._(_root);
	@override late final _StringsAuthEmailVerificationEs emailVerification = _StringsAuthEmailVerificationEs._(_root);
	@override late final _StringsAuthDeleteAccountEs deleteAccount = _StringsAuthDeleteAccountEs._(_root);
}

// Path: api
class _StringsApiEs extends _StringsApiEn {
	_StringsApiEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override late final _StringsApiErrorsEs errors = _StringsApiErrorsEs._(_root);
}

// Path: validation
class _StringsValidationEs extends _StringsValidationEn {
	_StringsValidationEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get emailRequired => 'Por favor, ingresa tu dirección de e-mail';
	@override String get invalidEmail => 'Por favor, ingresa una dirección de e-mail válida';
	@override String get fieldRequired => 'Este campo es obligatorio';
	@override String get passwordTooShort => 'La contraseña debe tener al menos 8 caracteres';
	@override String get passwordsDoNotMatch => 'Las contraseñas no coinciden';
}

// Path: onboarding
class _StringsOnboardingEs extends _StringsOnboardingEn {
	_StringsOnboardingEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override late final _StringsOnboardingStep1Es step1 = _StringsOnboardingStep1Es._(_root);
	@override late final _StringsOnboardingStep2Es step2 = _StringsOnboardingStep2Es._(_root);
	@override late final _StringsOnboardingStep3Es step3 = _StringsOnboardingStep3Es._(_root);
}

// Path: events
class _StringsEventsEs extends _StringsEventsEn {
	_StringsEventsEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get featuredEvents => 'Eventos destacados';
	@override String get upcomingEvents => 'Próximos eventos';
	@override String get noEventsFound => 'No se encontraron eventos';
	@override String get noEventsForFilter => 'No hay eventos que coincidan con tus filtros. Intenta ajustar tu selección o borrar los filtros.';
	@override String get danceStyles => 'Estilos de baile';
	@override String get danceStylesLabel => 'ESTILOS DE BAILE';
	@override String get location => 'Ubicación';
	@override late final _StringsEventsDetailEs detail = _StringsEventsDetailEs._(_root);
	@override late final _StringsEventsFilterEs filter = _StringsEventsFilterEs._(_root);
	@override late final _StringsEventsFiltersEs filters = _StringsEventsFiltersEs._(_root);
}

// Path: courses
class _StringsCoursesEs extends _StringsCoursesEn {
	_StringsCoursesEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cursos de baile';
	@override String get subtitle => 'Encuentra tu curso';
	@override String get featuredCourses => 'Cursos destacados';
	@override String get allCourses => 'Todos los cursos';
	@override String get noCoursesFound => 'No se encontraron cursos';
	@override String get noCoursesForFilter => 'No hay cursos que coincidan con tus filtros. Intenta ajustar tu selección o borrar los filtros.';
	@override late final _StringsCoursesCourseTypesEs courseTypes = _StringsCoursesCourseTypesEs._(_root);
	@override late final _StringsCoursesDetailEs detail = _StringsCoursesDetailEs._(_root);
}

// Path: profile
class _StringsProfileEs extends _StringsProfileEn {
	_StringsProfileEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Perfil';
	@override late final _StringsProfileSectionsEs sections = _StringsProfileSectionsEs._(_root);
	@override late final _StringsProfileAccountEs account = _StringsProfileAccountEs._(_root);
	@override late final _StringsProfileSettingsEs settings = _StringsProfileSettingsEs._(_root);
	@override late final _StringsProfileSupportEs support = _StringsProfileSupportEs._(_root);
	@override late final _StringsProfileAppInfoEs appInfo = _StringsProfileAppInfoEs._(_root);
	@override late final _StringsProfileDangerEs danger = _StringsProfileDangerEs._(_root);
	@override late final _StringsProfileChangePasswordEs changePassword = _StringsProfileChangePasswordEs._(_root);
	@override late final _StringsProfileEditProfileEs editProfile = _StringsProfileEditProfileEs._(_root);
}

// Path: premium
class _StringsPremiumEs extends _StringsPremiumEn {
	_StringsPremiumEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsSavedEs extends _StringsSavedEn {
	_StringsSavedEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Eventos guardados';
	@override String get subtitle => 'Tus eventos favoritos';
	@override String get emptyTitle => 'Sin eventos guardados';
	@override String get emptySubtitle => 'Los eventos que guardes aparecerán aquí';
}

// Path: contact
class _StringsContactEs extends _StringsContactEn {
	_StringsContactEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get teamName => 'Equipo Dancee';
	@override String get email => 'hello@dancee.app';
	@override String get description => 'Nos encantaría leer tus comentarios...';
	@override String get responseTime => 'Tiempo de respuesta';
	@override String get responseTimeDetail => 'Normalmente respondemos en 24 horas en días laborables. ¡Gracias por tu paciencia!';
	@override String get deviceInfo => 'Información del dispositivo';
	@override String get autoAttached => 'Adjuntado automáticamente';
	@override late final _StringsContactFormEs form = _StringsContactFormEs._(_root);
	@override late final _StringsContactDeviceInfoLabelsEs deviceInfoLabels = _StringsContactDeviceInfoLabelsEs._(_root);
}

// Path: common.months
class _StringsCommonMonthsEs extends _StringsCommonMonthsEn {
	_StringsCommonMonthsEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsCommonFormEs extends _StringsCommonFormEn {
	_StringsCommonFormEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsAuthLoginEs extends _StringsAuthLoginEn {
	_StringsAuthLoginEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsAuthRegisterEs extends _StringsAuthRegisterEn {
	_StringsAuthRegisterEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsAuthForgotPasswordEs extends _StringsAuthForgotPasswordEn {
	_StringsAuthForgotPasswordEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsAuthPasswordStrengthEs extends _StringsAuthPasswordStrengthEn {
	_StringsAuthPasswordStrengthEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get weak => 'Contraseña débil';
	@override String get medium => 'Media';
	@override String get strong => 'Contraseña fuerte';
	@override String get veryStrong => 'Muy fuerte';
	@override String get hint => 'Al menos 8 caracteres';
}

// Path: auth.errors
class _StringsAuthErrorsEs extends _StringsAuthErrorsEn {
	_StringsAuthErrorsEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsAuthEmailVerificationEs extends _StringsAuthEmailVerificationEn {
	_StringsAuthEmailVerificationEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsAuthDeleteAccountEs extends _StringsAuthDeleteAccountEn {
	_StringsAuthDeleteAccountEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get confirmTitle => '¿Eliminar cuenta?';
	@override String get confirmBody => 'Esta acción elimina permanentemente todos tus datos. No se puede deshacer.';
	@override String get reauthPrompt => 'Por favor, confirma tu contraseña para continuar';
	@override String get success => 'Tu cuenta ha sido eliminada';
	@override String get error => 'No se pudo eliminar la cuenta. Por favor, inténtalo de nuevo.';
}

// Path: api.errors
class _StringsApiErrorsEs extends _StringsApiErrorsEn {
	_StringsApiErrorsEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsOnboardingStep1Es extends _StringsOnboardingStep1En {
	_StringsOnboardingStep1Es._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¿Qué bailes te gustan?';
	@override String get subtitle => 'Elige tus estilos de baile favoritos para ofrecerte eventos relevantes';
}

// Path: onboarding.step2
class _StringsOnboardingStep2Es extends _StringsOnboardingStep2En {
	_StringsOnboardingStep2Es._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¿Cuál es tu nivel?';
	@override String get subtitle => 'Nos ayudará a recomendarte eventos y cursos adecuados';
}

// Path: onboarding.step3
class _StringsOnboardingStep3Es extends _StringsOnboardingStep3En {
	_StringsOnboardingStep3Es._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsEventsDetailEs extends _StringsEventsDetailEn {
	_StringsEventsDetailEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsEventsFilterEs extends _StringsEventsFilterEn {
	_StringsEventsFilterEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsEventsFiltersEs extends _StringsEventsFiltersEn {
	_StringsEventsFiltersEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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

// Path: courses.courseTypes
class _StringsCoursesCourseTypesEs extends _StringsCoursesCourseTypesEn {
	_StringsCoursesCourseTypesEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get all => 'Todo';
	@override String get workshop => 'Taller';
	@override String get regular => 'Curso regular';
}

// Path: courses.detail
class _StringsCoursesDetailEs extends _StringsCoursesDetailEn {
	_StringsCoursesDetailEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
	@override late final _StringsCoursesDetailLevelsEs levels = _StringsCoursesDetailLevelsEs._(_root);
	@override late final _StringsCoursesDetailDaysEs days = _StringsCoursesDetailDaysEs._(_root);
	@override String lessonsCount({required Object count}) => '${count} lecciones';
	@override String durationMin({required Object count}) => '${count} min';
	@override String participantsCount({required Object current, required Object max}) => '${current} / ${max} participantes';
	@override String spotsAvailable({required Object count}) => '${count} plazas disponibles';
}

// Path: profile.sections
class _StringsProfileSectionsEs extends _StringsProfileSectionsEn {
	_StringsProfileSectionsEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get account => 'Cuenta';
	@override String get settings => 'Ajustes';
	@override String get support => 'Soporte';
	@override String get appInfo => 'Sobre la app';
	@override String get dangerZone => 'Zona de peligro';
}

// Path: profile.account
class _StringsProfileAccountEs extends _StringsProfileAccountEn {
	_StringsProfileAccountEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get editProfile => 'Editar perfil';
	@override String get changePassword => 'Cambiar contraseña';
}

// Path: profile.settings
class _StringsProfileSettingsEs extends _StringsProfileSettingsEn {
	_StringsProfileSettingsEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get language => 'Idioma';
	@override String get czech => 'Checo';
	@override String get notifications => 'Notificaciones';
	@override String get english => 'Inglés';
	@override String get spanish => 'Español';
}

// Path: profile.support
class _StringsProfileSupportEs extends _StringsProfileSupportEn {
	_StringsProfileSupportEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get contactAuthor => 'Contactar al autor';
	@override String get rateApp => 'Valorar app';
}

// Path: profile.appInfo
class _StringsProfileAppInfoEs extends _StringsProfileAppInfoEn {
	_StringsProfileAppInfoEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get version => 'Versión de la app';
	@override String get termsOfUse => 'Términos de uso';
	@override String get privacy => 'Privacidad';
}

// Path: profile.danger
class _StringsProfileDangerEs extends _StringsProfileDangerEn {
	_StringsProfileDangerEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get logout => 'Cerrar sesión';
	@override String get logoutConfirmBody => '¿Seguro que quieres cerrar sesión?';
	@override String get deleteAccount => 'Eliminar cuenta';
}

// Path: profile.changePassword
class _StringsProfileChangePasswordEs extends _StringsProfileChangePasswordEn {
	_StringsProfileChangePasswordEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
}

// Path: profile.editProfile
class _StringsProfileEditProfileEs extends _StringsProfileEditProfileEn {
	_StringsProfileEditProfileEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Editar perfil';
	@override late final _StringsProfileEditProfileSectionsEs sections = _StringsProfileEditProfileSectionsEs._(_root);
	@override String get changePhoto => 'Cambiar foto';
	@override String get bio => 'Descripción';
	@override String get bioHint => 'Escribe algo sobre ti...';
	@override String get selectDanceStyles => 'Selecciona tus estilos de baile favoritos';
	@override String get yourLevel => 'Tu nivel de baile';
	@override String get instagram => 'Instagram';
	@override String get instagramHint => '@tu_usuario';
	@override String get facebook => 'Facebook';
	@override String get facebookHint => 'facebook.com/tu.nombre';
	@override late final _StringsProfileEditProfileNotificationsEs notifications = _StringsProfileEditProfileNotificationsEs._(_root);
	@override late final _StringsProfileEditProfileNotificationSubtitlesEs notificationSubtitles = _StringsProfileEditProfileNotificationSubtitlesEs._(_root);
}

// Path: contact.form
class _StringsContactFormEs extends _StringsContactFormEn {
	_StringsContactFormEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
}

// Path: contact.deviceInfoLabels
class _StringsContactDeviceInfoLabelsEs extends _StringsContactDeviceInfoLabelsEn {
	_StringsContactDeviceInfoLabelsEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get app => 'App:';
	@override String get device => 'Dispositivo:';
	@override String get os => 'Sistema:';
}

// Path: courses.detail.levels
class _StringsCoursesDetailLevelsEs extends _StringsCoursesDetailLevelsEn {
	_StringsCoursesDetailLevelsEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get beginner => 'Principiante';
	@override String get intermediate => 'Intermedio';
	@override String get advanced => 'Avanzado';
	@override String get allLevels => 'Todos los niveles';
}

// Path: courses.detail.days
class _StringsCoursesDetailDaysEs extends _StringsCoursesDetailDaysEn {
	_StringsCoursesDetailDaysEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsProfileEditProfileSectionsEs extends _StringsProfileEditProfileSectionsEn {
	_StringsProfileEditProfileSectionsEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get personalInfo => 'Información personal';
	@override String get aboutMe => 'Sobre mí';
	@override String get favoriteDances => 'Bailes favoritos';
	@override String get level => 'Nivel';
	@override String get socialNetworks => 'Redes sociales';
	@override String get notifications => 'Notificaciones';
}

// Path: profile.editProfile.notifications
class _StringsProfileEditProfileNotificationsEs extends _StringsProfileEditProfileNotificationsEn {
	_StringsProfileEditProfileNotificationsEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get newEvents => 'Nuevos eventos';
	@override String get eventReminders => 'Recordatorios de eventos';
	@override String get marketing => 'Mensajes de marketing';
}

// Path: profile.editProfile.notificationSubtitles
class _StringsProfileEditProfileNotificationSubtitlesEs extends _StringsProfileEditProfileNotificationSubtitlesEn {
	_StringsProfileEditProfileNotificationSubtitlesEs._(_StringsEs root) : this._root = root, super._(root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get newEvents => 'Recibe notificaciones sobre nuevos eventos en tu zona';
	@override String get eventReminders => 'Recordatorios antes de tus eventos guardados';
	@override String get marketing => 'Mensajes promocionales y ofertas';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'common.appName': return 'Dancee';
			case 'common.showAll': return 'Show all';
			case 'common.months.jan': return 'Jan';
			case 'common.months.feb': return 'Feb';
			case 'common.months.mar': return 'Mar';
			case 'common.months.apr': return 'Apr';
			case 'common.months.may': return 'May';
			case 'common.months.jun': return 'Jun';
			case 'common.months.jul': return 'Jul';
			case 'common.months.aug': return 'Aug';
			case 'common.months.sep': return 'Sep';
			case 'common.months.oct': return 'Oct';
			case 'common.months.nov': return 'Nov';
			case 'common.months.dec': return 'Dec';
			case 'common.date': return 'Date';
			case 'common.save': return 'Save';
			case 'common.share': return 'Share';
			case 'common.map': return 'Map';
			case 'common.skip': return 'Skip';
			case 'common.continue_': return 'Continue';
			case 'common.back': return 'Back';
			case 'common.finish': return 'Finish';
			case 'common.cancel': return 'Cancel';
			case 'common.support': return 'Support';
			case 'common.faq': return 'FAQ';
			case 'common.clear': return 'Clear';
			case 'common.clearFilters': return 'Clear filters';
			case 'common.current': return 'Current';
			case 'common.saveChanges': return 'Save changes';
			case 'common.loading': return 'Loading...';
			case 'common.retry': return 'Retry';
			case 'common.from': return ({required Object time}) => 'From ${time}';
			case 'common.form.email': return 'E-mail';
			case 'common.form.emailHint': return 'your@email.com';
			case 'common.form.password': return 'Password';
			case 'common.form.passwordPlaceholder': return '••••••••';
			case 'common.form.confirmPassword': return 'Confirm password';
			case 'common.form.firstName': return 'First name';
			case 'common.form.firstNameHint': return 'Your first name';
			case 'common.form.lastName': return 'Last name';
			case 'common.form.lastNameHint': return 'Your last name';
			case 'common.form.city': return 'City';
			case 'common.form.phone': return 'Phone';
			case 'common.form.fullName': return 'Full name';
			case 'nav.events': return 'Events';
			case 'nav.courses': return 'Courses';
			case 'nav.saved': return 'Saved';
			case 'nav.profile': return 'Profile';
			case 'auth.tagline': return 'Discover the dancing world';
			case 'auth.orContinueWith': return 'or continue with';
			case 'auth.continueWithGoogle': return 'Continue with Google';
			case 'auth.continueWithApple': return 'Continue with Apple';
			case 'auth.termsPrefix': return 'By continuing you agree to our ';
			case 'auth.termsOfUse': return 'Terms of use';
			case 'auth.and': return ' and ';
			case 'auth.privacyPolicy': return 'Privacy policy';
			case 'auth.agreeWith': return 'I agree with ';
			case 'auth.orRegisterWith': return 'or register with';
			case 'auth.login.title': return 'Welcome back!';
			case 'auth.login.subtitle': return 'Sign in and continue exploring dance events';
			case 'auth.login.stayLoggedIn': return 'Stay logged in';
			case 'auth.login.forgotPassword': return 'Forgot password?';
			case 'auth.login.submit': return 'Sign in';
			case 'auth.login.noAccount': return 'Don\'t have an account?';
			case 'auth.login.register': return 'Register';
			case 'auth.register.title': return 'Create an account';
			case 'auth.register.subtitle': return 'Register and start exploring dance events';
			case 'auth.register.passwordsMatch': return 'Passwords match';
			case 'auth.register.passwordsMismatch': return 'Passwords don\'t match';
			case 'auth.register.newsletter': return 'I want to receive news about dance events';
			case 'auth.register.submit': return 'Create account';
			case 'auth.register.hasAccount': return 'Already have an account?';
			case 'auth.register.login': return 'Sign in';
			case 'auth.forgotPassword.title': return 'Forgot password?';
			case 'auth.forgotPassword.subtitle': return 'Enter your email and we\'ll send you a link to reset your password';
			case 'auth.forgotPassword.submit': return 'Send link';
			case 'auth.forgotPassword.checkInbox': return 'Check your inbox';
			case 'auth.forgotPassword.checkInboxDetail': return 'After sending you\'ll receive an email with a link to reset your password. The link is valid for 24 hours.';
			case 'auth.forgotPassword.rememberPassword': return 'Remembered your password?';
			case 'auth.forgotPassword.login': return 'Sign in';
			case 'auth.forgotPassword.needHelp': return 'Need help?';
			case 'auth.passwordStrength.weak': return 'Weak password';
			case 'auth.passwordStrength.medium': return 'Medium';
			case 'auth.passwordStrength.strong': return 'Strong password';
			case 'auth.passwordStrength.veryStrong': return 'Very strong';
			case 'auth.passwordStrength.hint': return 'At least 8 characters';
			case 'auth.errors.invalidCredential': return 'Invalid email or password';
			case 'auth.errors.userDisabled': return 'This account has been disabled';
			case 'auth.errors.emailAlreadyInUse': return 'An account with this email already exists';
			case 'auth.errors.weakPassword': return 'Password is too weak';
			case 'auth.errors.tooManyRequests': return 'Too many attempts. Please try again later';
			case 'auth.errors.networkError': return 'Network error. Please check your connection';
			case 'auth.errors.generic': return 'An error occurred. Please try again';
			case 'auth.emailVerification.title': return 'Verify your email';
			case 'auth.emailVerification.subtitle': return ({required Object email}) => 'We sent a verification email to ${email}';
			case 'auth.emailVerification.resend': return 'Resend verification email';
			case 'auth.emailVerification.resendConfirmed': return 'Verification email sent. Please check your inbox.';
			case 'auth.emailVerification.checkVerified': return 'I\'ve verified my email';
			case 'auth.emailVerification.notVerifiedYet': return 'Email not verified yet. Please check your inbox.';
			case 'auth.emailVerification.signOut': return 'Sign out';
			case 'auth.deleteAccount.confirmTitle': return 'Delete account?';
			case 'auth.deleteAccount.confirmBody': return 'This action permanently removes all your data. This cannot be undone.';
			case 'auth.deleteAccount.reauthPrompt': return 'Please confirm your password to continue';
			case 'auth.deleteAccount.success': return 'Your account has been deleted';
			case 'auth.deleteAccount.error': return 'Failed to delete account. Please try again.';
			case 'api.errors.connectionTimeout': return 'Connection timed out. Please check your network.';
			case 'api.errors.receiveTimeout': return 'Server took too long to respond. Please try again.';
			case 'api.errors.sendTimeout': return 'Request timed out while sending. Please try again.';
			case 'api.errors.noConnection': return 'No internet connection. Please check your network.';
			case 'api.errors.requestCancelled': return 'Request was cancelled.';
			case 'api.errors.badRequest': return 'Bad request. Please try again.';
			case 'api.errors.unauthorized': return 'Session expired. Please sign in again.';
			case 'api.errors.forbidden': return 'Access denied. Please contact support.';
			case 'api.errors.notFound': return 'The requested resource was not found.';
			case 'api.errors.conflict': return 'A conflict occurred. Please try again.';
			case 'api.errors.internalServerError': return 'Server error. Please try again later.';
			case 'api.errors.badGateway': return 'Server is temporarily unavailable. Please try again later.';
			case 'api.errors.serviceUnavailable': return 'Service is unavailable. Please try again later.';
			case 'api.errors.clientError': return 'An error occurred. Please try again.';
			case 'api.errors.serverError': return 'Server error. Please try again later.';
			case 'api.errors.generic': return 'An unexpected error occurred. Please try again.';
			case 'validation.emailRequired': return 'Please enter your email address';
			case 'validation.invalidEmail': return 'Please enter a valid email address';
			case 'validation.fieldRequired': return 'This field is required';
			case 'validation.passwordTooShort': return 'Password must be at least 8 characters';
			case 'validation.passwordsDoNotMatch': return 'Passwords do not match';
			case 'onboarding.step1.title': return 'What dances do you like?';
			case 'onboarding.step1.subtitle': return 'Choose your favorite dance styles so we can offer you relevant events';
			case 'onboarding.step2.title': return 'What is your level?';
			case 'onboarding.step2.subtitle': return 'It will help us recommend suitable events and courses';
			case 'onboarding.step3.title': return 'Where are you located?';
			case 'onboarding.step3.subtitle': return 'We\'ll find the nearest dance events in your area';
			case 'onboarding.step3.radius10km': return '10 km';
			case 'onboarding.step3.radius25km': return '25 km';
			case 'onboarding.step3.radius50km': return '50 km';
			case 'onboarding.step3.radiusAll': return 'Whole country';
			case 'onboarding.step3.cityHint': return 'E.g. Prague, Brno...';
			case 'onboarding.step3.searchRadius': return 'Search events within radius';
			case 'onboarding.step3.useCurrentLocation': return 'Use current location';
			case 'events.featuredEvents': return 'Featured events';
			case 'events.upcomingEvents': return 'Upcoming events';
			case 'events.noEventsFound': return 'No events found';
			case 'events.noEventsForFilter': return 'No events match your current filters. Try adjusting your selection or clear all filters.';
			case 'events.danceStyles': return 'Dance styles';
			case 'events.danceStylesLabel': return 'DANCE STYLES';
			case 'events.location': return 'Location';
			case 'events.detail.header': return 'Event detail';
			case 'events.detail.description': return 'Event description';
			case 'events.detail.additionalInfo': return 'Additional information';
			case 'events.detail.admission': return 'Admission';
			case 'events.detail.dresscode': return 'Dresscode';
			case 'events.detail.buyTickets': return 'Buy tickets';
			case 'events.detail.originalSource': return 'Original source';
			case 'events.detail.program': return 'Event program';
			case 'events.detail.notFound': return 'Event not found';
			case 'events.detail.lector': return ({required Object name}) => 'Lector: ${name}';
			case 'events.detail.dj': return ({required Object name}) => 'DJ: ${name}';
			case 'events.filter.selectedCount': return ({required Object count}) => '${count} selected';
			case 'events.filter.selectedStyles': return 'SELECTED STYLES';
			case 'events.filter.apply': return 'Apply filter';
			case 'events.filter.applyCount': return ({required Object count}) => 'Apply filter (${count})';
			case 'events.filter.selectLocation': return 'Select location';
			case 'events.filter.searchCityHint': return 'Search city or area...';
			case 'events.filter.useMyLocation': return 'Use my location';
			case 'events.filter.useMyLocationSubtitle': return 'Automatically finds events near you';
			case 'events.filter.popularCities': return 'Popular cities';
			case 'events.filter.allCities': return 'All cities';
			case 'events.filter.selectedRegions': return 'SELECTED REGIONS';
			case 'events.filter.noResults': return 'No results found';
			case 'events.filter.abroad': return 'Abroad';
			case 'events.filter.unknownRegion': return 'Unknown location';
			case 'events.filters.today': return 'Today';
			case 'events.filters.thisWeek': return 'This week';
			case 'events.filters.thisMonth': return 'This month';
			case 'events.filters.thisWeekend': return 'This weekend';
			case 'events.filters.all': return 'All';
			case 'events.filters.evening': return 'Evening';
			case 'events.filters.weekend': return 'Weekend';
			case 'events.filters.multiDay': return 'Multi-day';
			case 'courses.title': return 'Dance courses';
			case 'courses.subtitle': return 'Find your course';
			case 'courses.featuredCourses': return 'Featured courses';
			case 'courses.allCourses': return 'All courses';
			case 'courses.noCoursesFound': return 'No courses found';
			case 'courses.noCoursesForFilter': return 'No courses match your current filters. Try adjusting your selection or clear all filters.';
			case 'courses.courseTypes.all': return 'All';
			case 'courses.courseTypes.workshop': return 'Workshop';
			case 'courses.courseTypes.regular': return 'Regular course';
			case 'courses.detail.header': return 'Course detail';
			case 'courses.detail.notFound': return 'Course not found';
			case 'courses.detail.description': return 'Course description';
			case 'courses.detail.details': return 'Course details';
			case 'courses.detail.whatYouLearn': return 'What you\'ll learn';
			case 'courses.detail.aboutInstructor': return 'About instructor';
			case 'courses.detail.shareCourse': return 'Share course';
			case 'courses.detail.coursePrice': return 'Course price';
			case 'courses.detail.priceUnknown': return 'Price not specified';
			case 'courses.detail.availableSpots': return 'Available spots';
			case 'courses.detail.register': return 'Register for course';
			case 'courses.detail.startDate': return 'Start date';
			case 'courses.detail.endDate': return 'End date';
			case 'courses.detail.day': return 'Day';
			case 'courses.detail.time': return 'Time';
			case 'courses.detail.lessons': return 'Lessons';
			case 'courses.detail.duration': return 'Duration';
			case 'courses.detail.level': return 'Level';
			case 'courses.detail.levels.beginner': return 'Beginner';
			case 'courses.detail.levels.intermediate': return 'Intermediate';
			case 'courses.detail.levels.advanced': return 'Advanced';
			case 'courses.detail.levels.allLevels': return 'All levels';
			case 'courses.detail.days.monday': return 'Monday';
			case 'courses.detail.days.tuesday': return 'Tuesday';
			case 'courses.detail.days.wednesday': return 'Wednesday';
			case 'courses.detail.days.thursday': return 'Thursday';
			case 'courses.detail.days.friday': return 'Friday';
			case 'courses.detail.days.saturday': return 'Saturday';
			case 'courses.detail.days.sunday': return 'Sunday';
			case 'courses.detail.lessonsCount': return ({required Object count}) => '${count} lessons';
			case 'courses.detail.durationMin': return ({required Object count}) => '${count} min';
			case 'courses.detail.participantsCount': return ({required Object current, required Object max}) => '${current} / ${max} participants';
			case 'courses.detail.spotsAvailable': return ({required Object count}) => '${count} spots available';
			case 'profile.title': return 'Profile';
			case 'profile.sections.account': return 'Account';
			case 'profile.sections.settings': return 'Settings';
			case 'profile.sections.support': return 'Support';
			case 'profile.sections.appInfo': return 'About app';
			case 'profile.sections.dangerZone': return 'Danger zone';
			case 'profile.account.editProfile': return 'Edit profile';
			case 'profile.account.changePassword': return 'Change password';
			case 'profile.settings.language': return 'Language';
			case 'profile.settings.czech': return 'Czech';
			case 'profile.settings.notifications': return 'Notifications';
			case 'profile.settings.english': return 'English';
			case 'profile.settings.spanish': return 'Spanish';
			case 'profile.support.contactAuthor': return 'Contact author';
			case 'profile.support.rateApp': return 'Rate app';
			case 'profile.appInfo.version': return 'App version';
			case 'profile.appInfo.termsOfUse': return 'Terms of use';
			case 'profile.appInfo.privacy': return 'Privacy';
			case 'profile.danger.logout': return 'Log out';
			case 'profile.danger.logoutConfirmBody': return 'Are you sure you want to log out?';
			case 'profile.danger.deleteAccount': return 'Delete account';
			case 'profile.changePassword.title': return 'Change password';
			case 'profile.changePassword.secureAccount': return 'Secure your account';
			case 'profile.changePassword.secureAccountDetail': return 'A strong password must contain at least 8 characters, uppercase and lowercase letters, numbers and special characters.';
			case 'profile.changePassword.currentPassword': return 'Current password';
			case 'profile.changePassword.currentPasswordHint': return 'Enter current password';
			case 'profile.changePassword.newPassword': return 'New password';
			case 'profile.changePassword.newPasswordHint': return 'Enter new password';
			case 'profile.changePassword.confirmPassword': return 'Confirm new password';
			case 'profile.changePassword.confirmPasswordHint': return 'Enter new password again';
			case 'profile.changePassword.save': return 'Save new password';
			case 'profile.changePassword.requirements': return 'PASSWORD REQUIREMENTS';
			case 'profile.changePassword.req8chars': return 'Minimum 8 characters';
			case 'profile.changePassword.reqUppercase': return 'At least one uppercase letter (A-Z)';
			case 'profile.changePassword.reqLowercase': return 'At least one lowercase letter (a-z)';
			case 'profile.changePassword.reqNumber': return 'At least one number (0-9)';
			case 'profile.changePassword.reqSpecial': return 'At least one special character (!@#\$%^&*)';
			case 'profile.changePassword.forgotPassword': return 'Forgot your password?';
			case 'profile.changePassword.strengthVeryWeak': return 'Password strength: Very weak';
			case 'profile.changePassword.strengthWeak': return 'Password strength: Weak';
			case 'profile.changePassword.strengthMedium': return 'Password strength: Medium';
			case 'profile.changePassword.strengthStrong': return 'Password strength: Strong';
			case 'profile.editProfile.title': return 'Edit profile';
			case 'profile.editProfile.sections.personalInfo': return 'Personal information';
			case 'profile.editProfile.sections.aboutMe': return 'About me';
			case 'profile.editProfile.sections.favoriteDances': return 'Favorite dances';
			case 'profile.editProfile.sections.level': return 'Level';
			case 'profile.editProfile.sections.socialNetworks': return 'Social networks';
			case 'profile.editProfile.sections.notifications': return 'Notifications';
			case 'profile.editProfile.changePhoto': return 'Change photo';
			case 'profile.editProfile.bio': return 'Description';
			case 'profile.editProfile.bioHint': return 'Write something about yourself...';
			case 'profile.editProfile.selectDanceStyles': return 'Select your favorite dance styles';
			case 'profile.editProfile.yourLevel': return 'Your dance level';
			case 'profile.editProfile.instagram': return 'Instagram';
			case 'profile.editProfile.instagramHint': return '@your_username';
			case 'profile.editProfile.facebook': return 'Facebook';
			case 'profile.editProfile.facebookHint': return 'facebook.com/your.name';
			case 'profile.editProfile.notifications.newEvents': return 'New events';
			case 'profile.editProfile.notifications.eventReminders': return 'Event reminders';
			case 'profile.editProfile.notifications.marketing': return 'Marketing messages';
			case 'profile.editProfile.notificationSubtitles.newEvents': return 'Get notified about new events in your area';
			case 'profile.editProfile.notificationSubtitles.eventReminders': return 'Reminders before your saved events';
			case 'profile.editProfile.notificationSubtitles.marketing': return 'Promotional messages and offers';
			case 'premium.title': return 'Dancee Premium';
			case 'premium.bannerSubtitle': return 'Unlock all features';
			case 'premium.heroTitle': return 'Unlock full potential';
			case 'premium.heroSubtitle': return 'Get access to all premium features and improve your dance experiences';
			case 'premium.featuresTitle': return 'What you get with Premium';
			case 'premium.testimonialsTitle': return 'What our users say';
			case 'premium.faqTitle': return 'Frequently asked questions';
			case 'premium.ctaTitle': return 'Ready to start?';
			case 'premium.ctaSubtitle': return 'Join thousands of satisfied dancers';
			case 'premium.ctaButton': return 'Get Premium now';
			case 'premium.ctaNote': return '7 days free · Cancel anytime';
			case 'saved.title': return 'Saved events';
			case 'saved.subtitle': return 'Your favorite events';
			case 'saved.emptyTitle': return 'No saved events';
			case 'saved.emptySubtitle': return 'Events you save will appear here';
			case 'contact.teamName': return 'Dancee Team';
			case 'contact.email': return 'hello@dancee.app';
			case 'contact.description': return 'We\'d love to read your feedback...';
			case 'contact.responseTime': return 'Response time';
			case 'contact.responseTimeDetail': return 'We usually respond within 24 hours on working days. Thank you for your patience!';
			case 'contact.deviceInfo': return 'Device information';
			case 'contact.autoAttached': return 'Automatically attached';
			case 'contact.form.subject': return 'Message subject';
			case 'contact.form.feedback': return 'Feedback';
			case 'contact.form.reportBug': return 'Report bug';
			case 'contact.form.featureRequest': return 'Feature request';
			case 'contact.form.other': return 'Other';
			case 'contact.form.title': return 'Message title';
			case 'contact.form.titleHint': return 'Briefly describe your issue or suggestion';
			case 'contact.form.message': return 'Message';
			case 'contact.form.messageHint': return 'Describe your issue in detail...';
			case 'contact.form.replyEmail': return 'Your reply email';
			case 'contact.form.sending': return 'Sending...';
			case 'contact.form.sent': return 'Sent!';
			case 'contact.form.submit': return 'Send message';
			case 'contact.deviceInfoLabels.app': return 'App:';
			case 'contact.deviceInfoLabels.device': return 'Device:';
			case 'contact.deviceInfoLabels.os': return 'System:';
			default: return null;
		}
	}
}

extension on _StringsCs {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'common.appName': return 'Dancee';
			case 'common.showAll': return 'Zobrazit vše';
			case 'common.months.jan': return 'Led';
			case 'common.months.feb': return 'Úno';
			case 'common.months.mar': return 'Bře';
			case 'common.months.apr': return 'Dub';
			case 'common.months.may': return 'Kvě';
			case 'common.months.jun': return 'Čvn';
			case 'common.months.jul': return 'Čvc';
			case 'common.months.aug': return 'Srp';
			case 'common.months.sep': return 'Zář';
			case 'common.months.oct': return 'Říj';
			case 'common.months.nov': return 'Lis';
			case 'common.months.dec': return 'Pro';
			case 'common.date': return 'Datum';
			case 'common.save': return 'Uložit';
			case 'common.share': return 'Sdílet';
			case 'common.map': return 'Mapa';
			case 'common.skip': return 'Přeskočit';
			case 'common.continue_': return 'Pokračovat';
			case 'common.back': return 'Zpět';
			case 'common.finish': return 'Dokončit';
			case 'common.cancel': return 'Zrušit';
			case 'common.support': return 'Podpora';
			case 'common.faq': return 'FAQ';
			case 'common.clear': return 'Vymazat';
			case 'common.clearFilters': return 'Vymazat filtry';
			case 'common.current': return 'Aktuální';
			case 'common.saveChanges': return 'Uložit změny';
			case 'common.loading': return 'Načítání...';
			case 'common.retry': return 'Zkusit znovu';
			case 'common.from': return ({required Object time}) => 'Od ${time}';
			case 'common.form.email': return 'E-mail';
			case 'common.form.emailHint': return 'tvuj@email.cz';
			case 'common.form.password': return 'Heslo';
			case 'common.form.passwordPlaceholder': return '••••••••';
			case 'common.form.confirmPassword': return 'Potvrzení hesla';
			case 'common.form.firstName': return 'Jméno';
			case 'common.form.firstNameHint': return 'Tvoje jméno';
			case 'common.form.lastName': return 'Příjmení';
			case 'common.form.lastNameHint': return 'Tvoje příjmení';
			case 'common.form.city': return 'Město';
			case 'common.form.phone': return 'Telefon';
			case 'common.form.fullName': return 'Jméno a příjmení';
			case 'nav.events': return 'Události';
			case 'nav.courses': return 'Kurzy';
			case 'nav.saved': return 'Uložené';
			case 'nav.profile': return 'Profil';
			case 'auth.tagline': return 'Objevuj taneční svět';
			case 'auth.orContinueWith': return 'nebo pokračuj s';
			case 'auth.continueWithGoogle': return 'Pokračovat s Google';
			case 'auth.continueWithApple': return 'Pokračovat s Apple';
			case 'auth.termsPrefix': return 'Pokračováním souhlasíš s našimi ';
			case 'auth.termsOfUse': return 'Podmínkami používání';
			case 'auth.and': return ' a ';
			case 'auth.privacyPolicy': return 'Zásadami ochrany osobních údajů';
			case 'auth.agreeWith': return 'Souhlasím s ';
			case 'auth.orRegisterWith': return 'nebo se zaregistruj s';
			case 'auth.login.title': return 'Vítej zpět!';
			case 'auth.login.subtitle': return 'Přihlaš se a pokračuj v objevování tanečních akcí';
			case 'auth.login.stayLoggedIn': return 'Zůstat přihlášen';
			case 'auth.login.forgotPassword': return 'Zapomenuté heslo?';
			case 'auth.login.submit': return 'Přihlásit se';
			case 'auth.login.noAccount': return 'Nemáš ještě účet?';
			case 'auth.login.register': return 'Zaregistruj se';
			case 'auth.register.title': return 'Vytvoř si účet';
			case 'auth.register.subtitle': return 'Zaregistruj se a začni objevovat taneční akce';
			case 'auth.register.passwordsMatch': return 'Hesla se shodují';
			case 'auth.register.passwordsMismatch': return 'Hesla se neshodují';
			case 'auth.register.newsletter': return 'Chci dostávat novinky o tanečních akcích';
			case 'auth.register.submit': return 'Vytvořit účet';
			case 'auth.register.hasAccount': return 'Už máš účet?';
			case 'auth.register.login': return 'Přihlaš se';
			case 'auth.forgotPassword.title': return 'Zapomenuté heslo?';
			case 'auth.forgotPassword.subtitle': return 'Zadej svůj e-mail a pošleme ti odkaz pro obnovení hesla';
			case 'auth.forgotPassword.submit': return 'Odeslat odkaz';
			case 'auth.forgotPassword.checkInbox': return 'Zkontroluj svou e-mailovou schránku';
			case 'auth.forgotPassword.checkInboxDetail': return 'Po odeslání obdržíš e-mail s odkazem pro obnovení hesla. Odkaz je platný 24 hodin.';
			case 'auth.forgotPassword.rememberPassword': return 'Vzpomněl sis na heslo?';
			case 'auth.forgotPassword.login': return 'Přihlásit se';
			case 'auth.forgotPassword.needHelp': return 'Potřebuješ pomoc?';
			case 'auth.passwordStrength.weak': return 'Slabé heslo';
			case 'auth.passwordStrength.medium': return 'Středně silné';
			case 'auth.passwordStrength.strong': return 'Silné heslo';
			case 'auth.passwordStrength.veryStrong': return 'Velmi silné';
			case 'auth.passwordStrength.hint': return 'Alespoň 8 znaků';
			case 'auth.errors.invalidCredential': return 'Neplatný e-mail nebo heslo';
			case 'auth.errors.userDisabled': return 'Tento účet byl deaktivován';
			case 'auth.errors.emailAlreadyInUse': return 'Účet s tímto e-mailem již existuje';
			case 'auth.errors.weakPassword': return 'Heslo je příliš slabé';
			case 'auth.errors.tooManyRequests': return 'Příliš mnoho pokusů. Zkuste to prosím později';
			case 'auth.errors.networkError': return 'Chyba sítě. Zkontrolujte své připojení';
			case 'auth.errors.generic': return 'Došlo k chybě. Zkuste to prosím znovu';
			case 'auth.emailVerification.title': return 'Ověřte svůj e-mail';
			case 'auth.emailVerification.subtitle': return ({required Object email}) => 'Zaslali jsme ověřovací e-mail na adresu ${email}';
			case 'auth.emailVerification.resend': return 'Znovu odeslat ověřovací e-mail';
			case 'auth.emailVerification.resendConfirmed': return 'Ověřovací e-mail odeslán. Zkontrolujte prosím svou doručenou poštu.';
			case 'auth.emailVerification.checkVerified': return 'Ověřil jsem svůj e-mail';
			case 'auth.emailVerification.notVerifiedYet': return 'E-mail ještě nebyl ověřen. Zkontrolujte prosím svou doručenou poštu.';
			case 'auth.emailVerification.signOut': return 'Odhlásit se';
			case 'auth.deleteAccount.confirmTitle': return 'Smazat účet?';
			case 'auth.deleteAccount.confirmBody': return 'Tato akce trvale odstraní všechna vaše data. Tuto akci nelze vrátit zpět.';
			case 'auth.deleteAccount.reauthPrompt': return 'Pro pokračování potvrďte své heslo';
			case 'auth.deleteAccount.success': return 'Váš účet byl smazán';
			case 'auth.deleteAccount.error': return 'Nepodařilo se smazat účet. Zkuste to prosím znovu.';
			case 'api.errors.connectionTimeout': return 'Vypršel časový limit připojení. Zkontrolujte síťové připojení.';
			case 'api.errors.receiveTimeout': return 'Server reagoval příliš pomalu. Zkuste to prosím znovu.';
			case 'api.errors.sendTimeout': return 'Vypršel časový limit odesílání. Zkuste to prosím znovu.';
			case 'api.errors.noConnection': return 'Žádné internetové připojení. Zkontrolujte své připojení.';
			case 'api.errors.requestCancelled': return 'Požadavek byl zrušen.';
			case 'api.errors.badRequest': return 'Chybný požadavek. Zkuste to prosím znovu.';
			case 'api.errors.unauthorized': return 'Relace vypršela. Přihlaste se prosím znovu.';
			case 'api.errors.forbidden': return 'Přístup odepřen. Kontaktujte prosím podporu.';
			case 'api.errors.notFound': return 'Požadovaný zdroj nebyl nalezen.';
			case 'api.errors.conflict': return 'Došlo ke konfliktu. Zkuste to prosím znovu.';
			case 'api.errors.internalServerError': return 'Chyba serveru. Zkuste to prosím později.';
			case 'api.errors.badGateway': return 'Server je dočasně nedostupný. Zkuste to prosím později.';
			case 'api.errors.serviceUnavailable': return 'Služba není dostupná. Zkuste to prosím později.';
			case 'api.errors.clientError': return 'Došlo k chybě. Zkuste to prosím znovu.';
			case 'api.errors.serverError': return 'Chyba serveru. Zkuste to prosím později.';
			case 'api.errors.generic': return 'Došlo k neočekávané chybě. Zkuste to prosím znovu.';
			case 'validation.emailRequired': return 'Zadejte prosím svou e-mailovou adresu';
			case 'validation.invalidEmail': return 'Zadejte prosím platnou e-mailovou adresu';
			case 'validation.fieldRequired': return 'Toto pole je povinné';
			case 'validation.passwordTooShort': return 'Heslo musí mít alespoň 8 znaků';
			case 'validation.passwordsDoNotMatch': return 'Hesla se neshodují';
			case 'onboarding.step1.title': return 'Jaké tance tě baví?';
			case 'onboarding.step1.subtitle': return 'Vyber své oblíbené taneční styly, abychom ti mohli nabídnout relevantní akce';
			case 'onboarding.step2.title': return 'Jaká je tvoje úroveň?';
			case 'onboarding.step2.subtitle': return 'Pomůže nám to doporučit ti vhodné akce a kurzy';
			case 'onboarding.step3.title': return 'Kde se nacházíš?';
			case 'onboarding.step3.subtitle': return 'Najdeme pro tebe nejbližší taneční akce ve tvém okolí';
			case 'onboarding.step3.radius10km': return '10 km';
			case 'onboarding.step3.radius25km': return '25 km';
			case 'onboarding.step3.radius50km': return '50 km';
			case 'onboarding.step3.radiusAll': return 'Celá republika';
			case 'onboarding.step3.cityHint': return 'Např. Praha, Brno...';
			case 'onboarding.step3.searchRadius': return 'Vyhledat akce v okruhu';
			case 'onboarding.step3.useCurrentLocation': return 'Použít aktuální polohu';
			case 'events.featuredEvents': return 'Doporučené akce';
			case 'events.upcomingEvents': return 'Nadcházející akce';
			case 'events.noEventsFound': return 'Žádné akce nenalezeny';
			case 'events.noEventsForFilter': return 'Pro zvolené filtry nebyly nalezeny žádné akce. Zkuste upravit výběr nebo vymazat filtry.';
			case 'events.danceStyles': return 'Taneční styly';
			case 'events.danceStylesLabel': return 'TANEČNÍ STYLY';
			case 'events.location': return 'Lokalita';
			case 'events.detail.header': return 'Detail akce';
			case 'events.detail.description': return 'Popis akce';
			case 'events.detail.additionalInfo': return 'Dodatečné informace';
			case 'events.detail.admission': return 'Vstupné';
			case 'events.detail.dresscode': return 'Dresscode';
			case 'events.detail.buyTickets': return 'Koupit vstupenky';
			case 'events.detail.originalSource': return 'Původní zdroj';
			case 'events.detail.program': return 'Program akce';
			case 'events.detail.notFound': return 'Akce nenalezena';
			case 'events.detail.lector': return ({required Object name}) => 'Lektor: ${name}';
			case 'events.detail.dj': return ({required Object name}) => 'DJ: ${name}';
			case 'events.filter.selectedCount': return ({required Object count}) => '${count} vybraných';
			case 'events.filter.selectedStyles': return 'VYBRANÉ STYLY';
			case 'events.filter.apply': return 'Použít filtr';
			case 'events.filter.applyCount': return ({required Object count}) => 'Použít filtr (${count})';
			case 'events.filter.selectLocation': return 'Vybrat lokalitu';
			case 'events.filter.searchCityHint': return 'Hledat město nebo oblast...';
			case 'events.filter.useMyLocation': return 'Použít moji polohu';
			case 'events.filter.useMyLocationSubtitle': return 'Automaticky najde akce ve vašem okolí';
			case 'events.filter.popularCities': return 'Oblíbená města';
			case 'events.filter.allCities': return 'Všechna města';
			case 'events.filter.selectedRegions': return 'VYBRANÉ OBLASTI';
			case 'events.filter.noResults': return 'Žádné výsledky';
			case 'events.filter.abroad': return 'Zahraničí';
			case 'events.filter.unknownRegion': return 'Neznámá lokalita';
			case 'events.filters.today': return 'Dnes';
			case 'events.filters.thisWeek': return 'Tento týden';
			case 'events.filters.thisMonth': return 'Tento měsíc';
			case 'events.filters.thisWeekend': return 'Tento víkend';
			case 'events.filters.all': return 'Vše';
			case 'events.filters.evening': return 'Večerní';
			case 'events.filters.weekend': return 'Víkendové';
			case 'events.filters.multiDay': return 'Několikadenní';
			case 'courses.title': return 'Taneční kurzy';
			case 'courses.subtitle': return 'Najdi svůj kurz';
			case 'courses.featuredCourses': return 'Doporučené kurzy';
			case 'courses.allCourses': return 'Všechny kurzy';
			case 'courses.noCoursesFound': return 'Žádné kurzy nenalezeny';
			case 'courses.noCoursesForFilter': return 'Pro zvolené filtry nebyly nalezeny žádné kurzy. Zkuste upravit výběr nebo vymazat filtry.';
			case 'courses.courseTypes.all': return 'Vše';
			case 'courses.courseTypes.workshop': return 'Workshop';
			case 'courses.courseTypes.regular': return 'Pravidelný kurz';
			case 'courses.detail.header': return 'Detail kurzu';
			case 'courses.detail.notFound': return 'Kurz nenalezen';
			case 'courses.detail.description': return 'Popis kurzu';
			case 'courses.detail.details': return 'Podrobnosti kurzu';
			case 'courses.detail.whatYouLearn': return 'Co se naučíte';
			case 'courses.detail.aboutInstructor': return 'O lektorovi';
			case 'courses.detail.shareCourse': return 'Sdílet kurz';
			case 'courses.detail.coursePrice': return 'Cena kurzu';
			case 'courses.detail.priceUnknown': return 'Cena neuvedena';
			case 'courses.detail.availableSpots': return 'Volná místa';
			case 'courses.detail.register': return 'Registrovat se na kurz';
			case 'courses.detail.startDate': return 'Datum začátku';
			case 'courses.detail.endDate': return 'Datum konce';
			case 'courses.detail.day': return 'Den';
			case 'courses.detail.time': return 'Čas';
			case 'courses.detail.lessons': return 'Lekce';
			case 'courses.detail.duration': return 'Délka';
			case 'courses.detail.level': return 'Úroveň';
			case 'courses.detail.levels.beginner': return 'Začátečník';
			case 'courses.detail.levels.intermediate': return 'Mírně pokročilý';
			case 'courses.detail.levels.advanced': return 'Pokročilý';
			case 'courses.detail.levels.allLevels': return 'Všechny úrovně';
			case 'courses.detail.days.monday': return 'Pondělí';
			case 'courses.detail.days.tuesday': return 'Úterý';
			case 'courses.detail.days.wednesday': return 'Středa';
			case 'courses.detail.days.thursday': return 'Čtvrtek';
			case 'courses.detail.days.friday': return 'Pátek';
			case 'courses.detail.days.saturday': return 'Sobota';
			case 'courses.detail.days.sunday': return 'Neděle';
			case 'courses.detail.lessonsCount': return ({required Object count}) => '${count} lekcí';
			case 'courses.detail.durationMin': return ({required Object count}) => '${count} min';
			case 'courses.detail.participantsCount': return ({required Object current, required Object max}) => '${current} / ${max} účastníků';
			case 'courses.detail.spotsAvailable': return ({required Object count}) => '${count} volných míst';
			case 'profile.title': return 'Profil';
			case 'profile.sections.account': return 'Účet';
			case 'profile.sections.settings': return 'Nastavení';
			case 'profile.sections.support': return 'Podpora';
			case 'profile.sections.appInfo': return 'O aplikaci';
			case 'profile.sections.dangerZone': return 'Nebezpečná zóna';
			case 'profile.account.editProfile': return 'Upravit profil';
			case 'profile.account.changePassword': return 'Změnit heslo';
			case 'profile.settings.language': return 'Jazyk';
			case 'profile.settings.czech': return 'Čeština';
			case 'profile.settings.notifications': return 'Oznámení';
			case 'profile.settings.english': return 'Angličtina';
			case 'profile.settings.spanish': return 'Španělština';
			case 'profile.support.contactAuthor': return 'Napsat autorovi';
			case 'profile.support.rateApp': return 'Ohodnotit aplikaci';
			case 'profile.appInfo.version': return 'Verze aplikace';
			case 'profile.appInfo.termsOfUse': return 'Podmínky použití';
			case 'profile.appInfo.privacy': return 'Ochrana soukromí';
			case 'profile.danger.logout': return 'Odhlásit se';
			case 'profile.danger.logoutConfirmBody': return 'Opravdu se chcete odhlásit?';
			case 'profile.danger.deleteAccount': return 'Smazat účet';
			case 'profile.changePassword.title': return 'Změnit heslo';
			case 'profile.changePassword.secureAccount': return 'Zabezpečte svůj účet';
			case 'profile.changePassword.secureAccountDetail': return 'Silné heslo musí obsahovat alespoň 8 znaků, velká a malá písmena, čísla a speciální znaky.';
			case 'profile.changePassword.currentPassword': return 'Současné heslo';
			case 'profile.changePassword.currentPasswordHint': return 'Zadejte současné heslo';
			case 'profile.changePassword.newPassword': return 'Nové heslo';
			case 'profile.changePassword.newPasswordHint': return 'Zadejte nové heslo';
			case 'profile.changePassword.confirmPassword': return 'Potvrdit nové heslo';
			case 'profile.changePassword.confirmPasswordHint': return 'Zadejte nové heslo znovu';
			case 'profile.changePassword.save': return 'Uložit nové heslo';
			case 'profile.changePassword.requirements': return 'POŽADAVKY NA HESLO';
			case 'profile.changePassword.req8chars': return 'Minimálně 8 znaků';
			case 'profile.changePassword.reqUppercase': return 'Alespoň jedno velké písmeno (A-Z)';
			case 'profile.changePassword.reqLowercase': return 'Alespoň jedno malé písmeno (a-z)';
			case 'profile.changePassword.reqNumber': return 'Alespoň jedno číslo (0-9)';
			case 'profile.changePassword.reqSpecial': return 'Alespoň jeden speciální znak (!@#\$%^&*)';
			case 'profile.changePassword.forgotPassword': return 'Zapomněli jste heslo?';
			case 'profile.changePassword.strengthVeryWeak': return 'Síla hesla: Velmi slabé';
			case 'profile.changePassword.strengthWeak': return 'Síla hesla: Slabé';
			case 'profile.changePassword.strengthMedium': return 'Síla hesla: Střední';
			case 'profile.changePassword.strengthStrong': return 'Síla hesla: Silné';
			case 'profile.editProfile.title': return 'Upravit profil';
			case 'profile.editProfile.sections.personalInfo': return 'Osobní údaje';
			case 'profile.editProfile.sections.aboutMe': return 'O mně';
			case 'profile.editProfile.sections.favoriteDances': return 'Oblíbené tance';
			case 'profile.editProfile.sections.level': return 'Úroveň';
			case 'profile.editProfile.sections.socialNetworks': return 'Sociální sítě';
			case 'profile.editProfile.sections.notifications': return 'Oznámení';
			case 'profile.editProfile.changePhoto': return 'Změnit fotku';
			case 'profile.editProfile.bio': return 'Popis';
			case 'profile.editProfile.bioHint': return 'Napište něco o sobě...';
			case 'profile.editProfile.selectDanceStyles': return 'Vyberte své oblíbené tanční styly';
			case 'profile.editProfile.yourLevel': return 'Vaše taneční úroveň';
			case 'profile.editProfile.instagram': return 'Instagram';
			case 'profile.editProfile.instagramHint': return '@vase_uzivatelske_jmeno';
			case 'profile.editProfile.facebook': return 'Facebook';
			case 'profile.editProfile.facebookHint': return 'facebook.com/vase.jmeno';
			case 'profile.editProfile.notifications.newEvents': return 'Nové akce';
			case 'profile.editProfile.notifications.eventReminders': return 'Připomínky akcí';
			case 'profile.editProfile.notifications.marketing': return 'Marketingové zprávy';
			case 'profile.editProfile.notificationSubtitles.newEvents': return 'Dostávejte upozornění o nových akcích ve vašem okolí';
			case 'profile.editProfile.notificationSubtitles.eventReminders': return 'Připomínky před vašimi uloženými akcemi';
			case 'profile.editProfile.notificationSubtitles.marketing': return 'Propagační zprávy a nabídky';
			case 'premium.title': return 'Dancee Premium';
			case 'premium.bannerSubtitle': return 'Odemkněte všechny funkce';
			case 'premium.heroTitle': return 'Odemkněte plný potenciál';
			case 'premium.heroSubtitle': return 'Získejte přístup ke všem prémiové funkcím a zlepšete své taneční zážitky';
			case 'premium.featuresTitle': return 'Co získáte s Premium';
			case 'premium.testimonialsTitle': return 'Co říkají naši uživatelé';
			case 'premium.faqTitle': return 'Časté otázky';
			case 'premium.ctaTitle': return 'Připraveni začít?';
			case 'premium.ctaSubtitle': return 'Připojte se k tisícům spokojených tanečníků';
			case 'premium.ctaButton': return 'Získat Premium nyní';
			case 'premium.ctaNote': return '7 dní zdarma · Zrušte kdykoliv';
			case 'saved.title': return 'Uložené akce';
			case 'saved.subtitle': return 'Tvoje oblíbené akce';
			case 'saved.emptyTitle': return 'Žádné uložené akce';
			case 'saved.emptySubtitle': return 'Akce, které si uložíš, se zobrazí zde';
			case 'contact.teamName': return 'Tým Dancee';
			case 'contact.email': return 'hello@dancee.app';
			case 'contact.description': return 'Rádi si přečteme vaše zpětné vazby...';
			case 'contact.responseTime': return 'Doba odezvy';
			case 'contact.responseTimeDetail': return 'Obvykle odpovídáme do 24 hodin v pracovní dny. Děkujeme za trpělivost!';
			case 'contact.deviceInfo': return 'Informace o zařízení';
			case 'contact.autoAttached': return 'Automaticky přiloženo';
			case 'contact.form.subject': return 'Předmět zprávy';
			case 'contact.form.feedback': return 'Zpětná vazba';
			case 'contact.form.reportBug': return 'Nahlásit problém';
			case 'contact.form.featureRequest': return 'Návrh na vylepšení';
			case 'contact.form.other': return 'Ostatní';
			case 'contact.form.title': return 'Název zprávy';
			case 'contact.form.titleHint': return 'Stručně popište váš problém nebo návrh';
			case 'contact.form.message': return 'Zpráva';
			case 'contact.form.messageHint': return 'Podrobně popište váš problém...';
			case 'contact.form.replyEmail': return 'Váš e-mail pro odpověď';
			case 'contact.form.sending': return 'Odesílání...';
			case 'contact.form.sent': return 'Odesláno!';
			case 'contact.form.submit': return 'Odeslat zprávu';
			case 'contact.deviceInfoLabels.app': return 'Aplikace:';
			case 'contact.deviceInfoLabels.device': return 'Zařízení:';
			case 'contact.deviceInfoLabels.os': return 'Systém:';
			default: return null;
		}
	}
}

extension on _StringsEs {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'common.appName': return 'Dancee';
			case 'common.showAll': return 'Ver todo';
			case 'common.months.jan': return 'Ene';
			case 'common.months.feb': return 'Feb';
			case 'common.months.mar': return 'Mar';
			case 'common.months.apr': return 'Abr';
			case 'common.months.may': return 'May';
			case 'common.months.jun': return 'Jun';
			case 'common.months.jul': return 'Jul';
			case 'common.months.aug': return 'Ago';
			case 'common.months.sep': return 'Sep';
			case 'common.months.oct': return 'Oct';
			case 'common.months.nov': return 'Nov';
			case 'common.months.dec': return 'Dic';
			case 'common.date': return 'Fecha';
			case 'common.save': return 'Guardar';
			case 'common.share': return 'Compartir';
			case 'common.map': return 'Mapa';
			case 'common.skip': return 'Omitir';
			case 'common.continue_': return 'Continuar';
			case 'common.back': return 'Volver';
			case 'common.finish': return 'Finalizar';
			case 'common.cancel': return 'Cancelar';
			case 'common.support': return 'Soporte';
			case 'common.faq': return 'FAQ';
			case 'common.clear': return 'Limpiar';
			case 'common.clearFilters': return 'Borrar filtros';
			case 'common.current': return 'Actual';
			case 'common.saveChanges': return 'Guardar cambios';
			case 'common.loading': return 'Cargando...';
			case 'common.retry': return 'Reintentar';
			case 'common.from': return ({required Object time}) => 'Desde ${time}';
			case 'common.form.email': return 'E-mail';
			case 'common.form.emailHint': return 'tu@email.com';
			case 'common.form.password': return 'Contraseña';
			case 'common.form.passwordPlaceholder': return '••••••••';
			case 'common.form.confirmPassword': return 'Confirmar contraseña';
			case 'common.form.firstName': return 'Nombre';
			case 'common.form.firstNameHint': return 'Tu nombre';
			case 'common.form.lastName': return 'Apellido';
			case 'common.form.lastNameHint': return 'Tu apellido';
			case 'common.form.city': return 'Ciudad';
			case 'common.form.phone': return 'Teléfono';
			case 'common.form.fullName': return 'Nombre completo';
			case 'nav.events': return 'Eventos';
			case 'nav.courses': return 'Cursos';
			case 'nav.saved': return 'Guardados';
			case 'nav.profile': return 'Perfil';
			case 'auth.tagline': return 'Descubre el mundo del baile';
			case 'auth.orContinueWith': return 'o continúa con';
			case 'auth.continueWithGoogle': return 'Continuar con Google';
			case 'auth.continueWithApple': return 'Continuar con Apple';
			case 'auth.termsPrefix': return 'Al continuar aceptas nuestros ';
			case 'auth.termsOfUse': return 'Términos de uso';
			case 'auth.and': return ' y ';
			case 'auth.privacyPolicy': return 'Política de privacidad';
			case 'auth.agreeWith': return 'Acepto ';
			case 'auth.orRegisterWith': return 'o regístrate con';
			case 'auth.login.title': return '¡Bienvenido de vuelta!';
			case 'auth.login.subtitle': return 'Inicia sesión y continúa explorando eventos de baile';
			case 'auth.login.stayLoggedIn': return 'Mantener sesión iniciada';
			case 'auth.login.forgotPassword': return '¿Olvidaste tu contraseña?';
			case 'auth.login.submit': return 'Iniciar sesión';
			case 'auth.login.noAccount': return '¿No tienes cuenta?';
			case 'auth.login.register': return 'Regístrate';
			case 'auth.register.title': return 'Crear una cuenta';
			case 'auth.register.subtitle': return 'Regístrate y empieza a explorar eventos de baile';
			case 'auth.register.passwordsMatch': return 'Las contraseñas coinciden';
			case 'auth.register.passwordsMismatch': return 'Las contraseñas no coinciden';
			case 'auth.register.newsletter': return 'Quiero recibir noticias sobre eventos de baile';
			case 'auth.register.submit': return 'Crear cuenta';
			case 'auth.register.hasAccount': return '¿Ya tienes cuenta?';
			case 'auth.register.login': return 'Iniciar sesión';
			case 'auth.forgotPassword.title': return '¿Olvidaste tu contraseña?';
			case 'auth.forgotPassword.subtitle': return 'Ingresa tu e-mail y te enviaremos un enlace para restablecer tu contraseña';
			case 'auth.forgotPassword.submit': return 'Enviar enlace';
			case 'auth.forgotPassword.checkInbox': return 'Revisa tu bandeja de entrada';
			case 'auth.forgotPassword.checkInboxDetail': return 'Después de enviar recibirás un e-mail con un enlace para restablecer tu contraseña. El enlace es válido por 24 horas.';
			case 'auth.forgotPassword.rememberPassword': return '¿Recordaste tu contraseña?';
			case 'auth.forgotPassword.login': return 'Iniciar sesión';
			case 'auth.forgotPassword.needHelp': return '¿Necesitas ayuda?';
			case 'auth.passwordStrength.weak': return 'Contraseña débil';
			case 'auth.passwordStrength.medium': return 'Media';
			case 'auth.passwordStrength.strong': return 'Contraseña fuerte';
			case 'auth.passwordStrength.veryStrong': return 'Muy fuerte';
			case 'auth.passwordStrength.hint': return 'Al menos 8 caracteres';
			case 'auth.errors.invalidCredential': return 'E-mail o contraseña inválidos';
			case 'auth.errors.userDisabled': return 'Esta cuenta ha sido desactivada';
			case 'auth.errors.emailAlreadyInUse': return 'Ya existe una cuenta con este e-mail';
			case 'auth.errors.weakPassword': return 'La contraseña es demasiado débil';
			case 'auth.errors.tooManyRequests': return 'Demasiados intentos. Por favor, inténtalo más tarde';
			case 'auth.errors.networkError': return 'Error de red. Por favor, verifica tu conexión';
			case 'auth.errors.generic': return 'Ocurrió un error. Por favor, inténtalo de nuevo';
			case 'auth.emailVerification.title': return 'Verifica tu e-mail';
			case 'auth.emailVerification.subtitle': return ({required Object email}) => 'Enviamos un e-mail de verificación a ${email}';
			case 'auth.emailVerification.resend': return 'Reenviar e-mail de verificación';
			case 'auth.emailVerification.resendConfirmed': return 'E-mail de verificación enviado. Por favor, revisa tu bandeja de entrada.';
			case 'auth.emailVerification.checkVerified': return 'He verificado mi e-mail';
			case 'auth.emailVerification.notVerifiedYet': return 'E-mail aún no verificado. Por favor, revisa tu bandeja de entrada.';
			case 'auth.emailVerification.signOut': return 'Cerrar sesión';
			case 'auth.deleteAccount.confirmTitle': return '¿Eliminar cuenta?';
			case 'auth.deleteAccount.confirmBody': return 'Esta acción elimina permanentemente todos tus datos. No se puede deshacer.';
			case 'auth.deleteAccount.reauthPrompt': return 'Por favor, confirma tu contraseña para continuar';
			case 'auth.deleteAccount.success': return 'Tu cuenta ha sido eliminada';
			case 'auth.deleteAccount.error': return 'No se pudo eliminar la cuenta. Por favor, inténtalo de nuevo.';
			case 'api.errors.connectionTimeout': return 'Se agotó el tiempo de conexión. Por favor, verifica tu red.';
			case 'api.errors.receiveTimeout': return 'El servidor tardó demasiado en responder. Por favor, inténtalo de nuevo.';
			case 'api.errors.sendTimeout': return 'Se agotó el tiempo de envío. Por favor, inténtalo de nuevo.';
			case 'api.errors.noConnection': return 'Sin conexión a internet. Por favor, verifica tu red.';
			case 'api.errors.requestCancelled': return 'La solicitud fue cancelada.';
			case 'api.errors.badRequest': return 'Solicitud incorrecta. Por favor, inténtalo de nuevo.';
			case 'api.errors.unauthorized': return 'Sesión expirada. Por favor, inicia sesión de nuevo.';
			case 'api.errors.forbidden': return 'Acceso denegado. Por favor, contacta con soporte.';
			case 'api.errors.notFound': return 'El recurso solicitado no fue encontrado.';
			case 'api.errors.conflict': return 'Ocurrió un conflicto. Por favor, inténtalo de nuevo.';
			case 'api.errors.internalServerError': return 'Error del servidor. Por favor, inténtalo más tarde.';
			case 'api.errors.badGateway': return 'El servidor no está disponible temporalmente. Por favor, inténtalo más tarde.';
			case 'api.errors.serviceUnavailable': return 'El servicio no está disponible. Por favor, inténtalo más tarde.';
			case 'api.errors.clientError': return 'Ocurrió un error. Por favor, inténtalo de nuevo.';
			case 'api.errors.serverError': return 'Error del servidor. Por favor, inténtalo más tarde.';
			case 'api.errors.generic': return 'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';
			case 'validation.emailRequired': return 'Por favor, ingresa tu dirección de e-mail';
			case 'validation.invalidEmail': return 'Por favor, ingresa una dirección de e-mail válida';
			case 'validation.fieldRequired': return 'Este campo es obligatorio';
			case 'validation.passwordTooShort': return 'La contraseña debe tener al menos 8 caracteres';
			case 'validation.passwordsDoNotMatch': return 'Las contraseñas no coinciden';
			case 'onboarding.step1.title': return '¿Qué bailes te gustan?';
			case 'onboarding.step1.subtitle': return 'Elige tus estilos de baile favoritos para ofrecerte eventos relevantes';
			case 'onboarding.step2.title': return '¿Cuál es tu nivel?';
			case 'onboarding.step2.subtitle': return 'Nos ayudará a recomendarte eventos y cursos adecuados';
			case 'onboarding.step3.title': return '¿Dónde te encuentras?';
			case 'onboarding.step3.subtitle': return 'Encontraremos los eventos de baile más cercanos en tu zona';
			case 'onboarding.step3.radius10km': return '10 km';
			case 'onboarding.step3.radius25km': return '25 km';
			case 'onboarding.step3.radius50km': return '50 km';
			case 'onboarding.step3.radiusAll': return 'Todo el país';
			case 'onboarding.step3.cityHint': return 'Ej. Madrid, Barcelona...';
			case 'onboarding.step3.searchRadius': return 'Buscar eventos en un radio de';
			case 'onboarding.step3.useCurrentLocation': return 'Usar ubicación actual';
			case 'events.featuredEvents': return 'Eventos destacados';
			case 'events.upcomingEvents': return 'Próximos eventos';
			case 'events.noEventsFound': return 'No se encontraron eventos';
			case 'events.noEventsForFilter': return 'No hay eventos que coincidan con tus filtros. Intenta ajustar tu selección o borrar los filtros.';
			case 'events.danceStyles': return 'Estilos de baile';
			case 'events.danceStylesLabel': return 'ESTILOS DE BAILE';
			case 'events.location': return 'Ubicación';
			case 'events.detail.header': return 'Detalle del evento';
			case 'events.detail.description': return 'Descripción del evento';
			case 'events.detail.additionalInfo': return 'Información adicional';
			case 'events.detail.admission': return 'Entrada';
			case 'events.detail.dresscode': return 'Código de vestimenta';
			case 'events.detail.buyTickets': return 'Comprar entradas';
			case 'events.detail.originalSource': return 'Fuente original';
			case 'events.detail.program': return 'Programa del evento';
			case 'events.detail.notFound': return 'Evento no encontrado';
			case 'events.detail.lector': return ({required Object name}) => 'Instructor: ${name}';
			case 'events.detail.dj': return ({required Object name}) => 'DJ: ${name}';
			case 'events.filter.selectedCount': return ({required Object count}) => '${count} seleccionados';
			case 'events.filter.selectedStyles': return 'ESTILOS SELECCIONADOS';
			case 'events.filter.apply': return 'Aplicar filtro';
			case 'events.filter.applyCount': return ({required Object count}) => 'Aplicar filtro (${count})';
			case 'events.filter.selectLocation': return 'Seleccionar ubicación';
			case 'events.filter.searchCityHint': return 'Buscar ciudad o área...';
			case 'events.filter.useMyLocation': return 'Usar mi ubicación';
			case 'events.filter.useMyLocationSubtitle': return 'Encuentra automáticamente eventos cerca de ti';
			case 'events.filter.popularCities': return 'Ciudades populares';
			case 'events.filter.allCities': return 'Todas las ciudades';
			case 'events.filter.selectedRegions': return 'REGIONES SELECCIONADAS';
			case 'events.filter.noResults': return 'Sin resultados';
			case 'events.filter.abroad': return 'Extranjero';
			case 'events.filter.unknownRegion': return 'Ubicación desconocida';
			case 'events.filters.today': return 'Hoy';
			case 'events.filters.thisWeek': return 'Esta semana';
			case 'events.filters.thisMonth': return 'Este mes';
			case 'events.filters.thisWeekend': return 'Este fin de semana';
			case 'events.filters.all': return 'Todo';
			case 'events.filters.evening': return 'Nocturno';
			case 'events.filters.weekend': return 'Fin de semana';
			case 'events.filters.multiDay': return 'Varios días';
			case 'courses.title': return 'Cursos de baile';
			case 'courses.subtitle': return 'Encuentra tu curso';
			case 'courses.featuredCourses': return 'Cursos destacados';
			case 'courses.allCourses': return 'Todos los cursos';
			case 'courses.noCoursesFound': return 'No se encontraron cursos';
			case 'courses.noCoursesForFilter': return 'No hay cursos que coincidan con tus filtros. Intenta ajustar tu selección o borrar los filtros.';
			case 'courses.courseTypes.all': return 'Todo';
			case 'courses.courseTypes.workshop': return 'Taller';
			case 'courses.courseTypes.regular': return 'Curso regular';
			case 'courses.detail.header': return 'Detalle del curso';
			case 'courses.detail.notFound': return 'Curso no encontrado';
			case 'courses.detail.description': return 'Descripción del curso';
			case 'courses.detail.details': return 'Detalles del curso';
			case 'courses.detail.whatYouLearn': return 'Qué aprenderás';
			case 'courses.detail.aboutInstructor': return 'Sobre el instructor';
			case 'courses.detail.shareCourse': return 'Compartir curso';
			case 'courses.detail.coursePrice': return 'Precio del curso';
			case 'courses.detail.priceUnknown': return 'Precio no especificado';
			case 'courses.detail.availableSpots': return 'Plazas disponibles';
			case 'courses.detail.register': return 'Inscribirse al curso';
			case 'courses.detail.startDate': return 'Fecha de inicio';
			case 'courses.detail.endDate': return 'Fecha de fin';
			case 'courses.detail.day': return 'Día';
			case 'courses.detail.time': return 'Hora';
			case 'courses.detail.lessons': return 'Lecciones';
			case 'courses.detail.duration': return 'Duración';
			case 'courses.detail.level': return 'Nivel';
			case 'courses.detail.levels.beginner': return 'Principiante';
			case 'courses.detail.levels.intermediate': return 'Intermedio';
			case 'courses.detail.levels.advanced': return 'Avanzado';
			case 'courses.detail.levels.allLevels': return 'Todos los niveles';
			case 'courses.detail.days.monday': return 'Lunes';
			case 'courses.detail.days.tuesday': return 'Martes';
			case 'courses.detail.days.wednesday': return 'Miércoles';
			case 'courses.detail.days.thursday': return 'Jueves';
			case 'courses.detail.days.friday': return 'Viernes';
			case 'courses.detail.days.saturday': return 'Sábado';
			case 'courses.detail.days.sunday': return 'Domingo';
			case 'courses.detail.lessonsCount': return ({required Object count}) => '${count} lecciones';
			case 'courses.detail.durationMin': return ({required Object count}) => '${count} min';
			case 'courses.detail.participantsCount': return ({required Object current, required Object max}) => '${current} / ${max} participantes';
			case 'courses.detail.spotsAvailable': return ({required Object count}) => '${count} plazas disponibles';
			case 'profile.title': return 'Perfil';
			case 'profile.sections.account': return 'Cuenta';
			case 'profile.sections.settings': return 'Ajustes';
			case 'profile.sections.support': return 'Soporte';
			case 'profile.sections.appInfo': return 'Sobre la app';
			case 'profile.sections.dangerZone': return 'Zona de peligro';
			case 'profile.account.editProfile': return 'Editar perfil';
			case 'profile.account.changePassword': return 'Cambiar contraseña';
			case 'profile.settings.language': return 'Idioma';
			case 'profile.settings.czech': return 'Checo';
			case 'profile.settings.notifications': return 'Notificaciones';
			case 'profile.settings.english': return 'Inglés';
			case 'profile.settings.spanish': return 'Español';
			case 'profile.support.contactAuthor': return 'Contactar al autor';
			case 'profile.support.rateApp': return 'Valorar app';
			case 'profile.appInfo.version': return 'Versión de la app';
			case 'profile.appInfo.termsOfUse': return 'Términos de uso';
			case 'profile.appInfo.privacy': return 'Privacidad';
			case 'profile.danger.logout': return 'Cerrar sesión';
			case 'profile.danger.logoutConfirmBody': return '¿Seguro que quieres cerrar sesión?';
			case 'profile.danger.deleteAccount': return 'Eliminar cuenta';
			case 'profile.changePassword.title': return 'Cambiar contraseña';
			case 'profile.changePassword.secureAccount': return 'Asegura tu cuenta';
			case 'profile.changePassword.secureAccountDetail': return 'Una contraseña segura debe contener al menos 8 caracteres, letras mayúsculas y minúsculas, números y caracteres especiales.';
			case 'profile.changePassword.currentPassword': return 'Contraseña actual';
			case 'profile.changePassword.currentPasswordHint': return 'Ingresa la contraseña actual';
			case 'profile.changePassword.newPassword': return 'Nueva contraseña';
			case 'profile.changePassword.newPasswordHint': return 'Ingresa la nueva contraseña';
			case 'profile.changePassword.confirmPassword': return 'Confirmar nueva contraseña';
			case 'profile.changePassword.confirmPasswordHint': return 'Ingresa la nueva contraseña de nuevo';
			case 'profile.changePassword.save': return 'Guardar nueva contraseña';
			case 'profile.changePassword.requirements': return 'REQUISITOS DE CONTRASEÑA';
			case 'profile.changePassword.req8chars': return 'Mínimo 8 caracteres';
			case 'profile.changePassword.reqUppercase': return 'Al menos una letra mayúscula (A-Z)';
			case 'profile.changePassword.reqLowercase': return 'Al menos una letra minúscula (a-z)';
			case 'profile.changePassword.reqNumber': return 'Al menos un número (0-9)';
			case 'profile.changePassword.reqSpecial': return 'Al menos un carácter especial (!@#\$%^&*)';
			case 'profile.changePassword.forgotPassword': return '¿Olvidaste tu contraseña?';
			case 'profile.changePassword.strengthVeryWeak': return 'Seguridad de contraseña: Muy débil';
			case 'profile.changePassword.strengthWeak': return 'Seguridad de contraseña: Débil';
			case 'profile.changePassword.strengthMedium': return 'Seguridad de contraseña: Media';
			case 'profile.changePassword.strengthStrong': return 'Seguridad de contraseña: Fuerte';
			case 'profile.editProfile.title': return 'Editar perfil';
			case 'profile.editProfile.sections.personalInfo': return 'Información personal';
			case 'profile.editProfile.sections.aboutMe': return 'Sobre mí';
			case 'profile.editProfile.sections.favoriteDances': return 'Bailes favoritos';
			case 'profile.editProfile.sections.level': return 'Nivel';
			case 'profile.editProfile.sections.socialNetworks': return 'Redes sociales';
			case 'profile.editProfile.sections.notifications': return 'Notificaciones';
			case 'profile.editProfile.changePhoto': return 'Cambiar foto';
			case 'profile.editProfile.bio': return 'Descripción';
			case 'profile.editProfile.bioHint': return 'Escribe algo sobre ti...';
			case 'profile.editProfile.selectDanceStyles': return 'Selecciona tus estilos de baile favoritos';
			case 'profile.editProfile.yourLevel': return 'Tu nivel de baile';
			case 'profile.editProfile.instagram': return 'Instagram';
			case 'profile.editProfile.instagramHint': return '@tu_usuario';
			case 'profile.editProfile.facebook': return 'Facebook';
			case 'profile.editProfile.facebookHint': return 'facebook.com/tu.nombre';
			case 'profile.editProfile.notifications.newEvents': return 'Nuevos eventos';
			case 'profile.editProfile.notifications.eventReminders': return 'Recordatorios de eventos';
			case 'profile.editProfile.notifications.marketing': return 'Mensajes de marketing';
			case 'profile.editProfile.notificationSubtitles.newEvents': return 'Recibe notificaciones sobre nuevos eventos en tu zona';
			case 'profile.editProfile.notificationSubtitles.eventReminders': return 'Recordatorios antes de tus eventos guardados';
			case 'profile.editProfile.notificationSubtitles.marketing': return 'Mensajes promocionales y ofertas';
			case 'premium.title': return 'Dancee Premium';
			case 'premium.bannerSubtitle': return 'Desbloquea todas las funciones';
			case 'premium.heroTitle': return 'Desbloquea todo el potencial';
			case 'premium.heroSubtitle': return 'Obtén acceso a todas las funciones premium y mejora tus experiencias de baile';
			case 'premium.featuresTitle': return 'Qué obtienes con Premium';
			case 'premium.testimonialsTitle': return 'Qué dicen nuestros usuarios';
			case 'premium.faqTitle': return 'Preguntas frecuentes';
			case 'premium.ctaTitle': return '¿Listo para empezar?';
			case 'premium.ctaSubtitle': return 'Únete a miles de bailarines satisfechos';
			case 'premium.ctaButton': return 'Obtener Premium ahora';
			case 'premium.ctaNote': return '7 días gratis · Cancela cuando quieras';
			case 'saved.title': return 'Eventos guardados';
			case 'saved.subtitle': return 'Tus eventos favoritos';
			case 'saved.emptyTitle': return 'Sin eventos guardados';
			case 'saved.emptySubtitle': return 'Los eventos que guardes aparecerán aquí';
			case 'contact.teamName': return 'Equipo Dancee';
			case 'contact.email': return 'hello@dancee.app';
			case 'contact.description': return 'Nos encantaría leer tus comentarios...';
			case 'contact.responseTime': return 'Tiempo de respuesta';
			case 'contact.responseTimeDetail': return 'Normalmente respondemos en 24 horas en días laborables. ¡Gracias por tu paciencia!';
			case 'contact.deviceInfo': return 'Información del dispositivo';
			case 'contact.autoAttached': return 'Adjuntado automáticamente';
			case 'contact.form.subject': return 'Asunto del mensaje';
			case 'contact.form.feedback': return 'Comentario';
			case 'contact.form.reportBug': return 'Reportar error';
			case 'contact.form.featureRequest': return 'Sugerencia de mejora';
			case 'contact.form.other': return 'Otro';
			case 'contact.form.title': return 'Título del mensaje';
			case 'contact.form.titleHint': return 'Describe brevemente tu problema o sugerencia';
			case 'contact.form.message': return 'Mensaje';
			case 'contact.form.messageHint': return 'Describe tu problema en detalle...';
			case 'contact.form.replyEmail': return 'Tu e-mail de respuesta';
			case 'contact.form.sending': return 'Enviando...';
			case 'contact.form.sent': return '¡Enviado!';
			case 'contact.form.submit': return 'Enviar mensaje';
			case 'contact.deviceInfoLabels.app': return 'App:';
			case 'contact.deviceInfoLabels.device': return 'Dispositivo:';
			case 'contact.deviceInfoLabels.os': return 'Sistema:';
			default: return null;
		}
	}
}
