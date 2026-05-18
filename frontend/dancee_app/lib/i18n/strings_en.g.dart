///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
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

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsCommonEn common = TranslationsCommonEn.internal(_root);
	late final TranslationsNavEn nav = TranslationsNavEn.internal(_root);
	late final TranslationsAuthEn auth = TranslationsAuthEn.internal(_root);
	late final TranslationsApiEn api = TranslationsApiEn.internal(_root);
	late final TranslationsValidationEn validation = TranslationsValidationEn.internal(_root);
	late final TranslationsOnboardingEn onboarding = TranslationsOnboardingEn.internal(_root);
	late final TranslationsEventsEn events = TranslationsEventsEn.internal(_root);
	late final TranslationsCoursesEn courses = TranslationsCoursesEn.internal(_root);
	late final TranslationsProfileEn profile = TranslationsProfileEn.internal(_root);
	late final TranslationsPremiumEn premium = TranslationsPremiumEn.internal(_root);
	late final TranslationsSavedEn saved = TranslationsSavedEn.internal(_root);
	late final TranslationsAuthGateEn authGate = TranslationsAuthGateEn.internal(_root);
	late final TranslationsContactEn contact = TranslationsContactEn.internal(_root);
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dancee'
	String get appName => 'Dancee';

	/// en: 'Show all'
	String get showAll => 'Show all';

	late final TranslationsCommonMonthsEn months = TranslationsCommonMonthsEn.internal(_root);

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Share'
	String get share => 'Share';

	/// en: 'Map'
	String get map => 'Map';

	/// en: 'Skip'
	String get skip => 'Skip';

	/// en: 'Continue'
	String get continue_ => 'Continue';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Finish'
	String get finish => 'Finish';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Allow'
	String get allow => 'Allow';

	/// en: 'Support'
	String get support => 'Support';

	/// en: 'FAQ'
	String get faq => 'FAQ';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Clear filters'
	String get clearFilters => 'Clear filters';

	/// en: 'Current'
	String get current => 'Current';

	/// en: 'Save changes'
	String get saveChanges => 'Save changes';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'You have been successfully signed out.'
	String get logoutSuccess => 'You have been successfully signed out.';

	/// en: 'From ${time}'
	String from({required Object time}) => 'From ${time}';

	late final TranslationsCommonFormEn form = TranslationsCommonFormEn.internal(_root);
}

// Path: nav
class TranslationsNavEn {
	TranslationsNavEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Events'
	String get events => 'Events';

	/// en: 'Courses'
	String get courses => 'Courses';

	/// en: 'Saved'
	String get saved => 'Saved';

	/// en: 'Profile'
	String get profile => 'Profile';

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'Search'
	String get search => 'Search';
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Discover the dancing world'
	String get tagline => 'Discover the dancing world';

	/// en: 'or continue with'
	String get orContinueWith => 'or continue with';

	/// en: 'Continue with Google'
	String get continueWithGoogle => 'Continue with Google';

	/// en: 'Continue with Apple'
	String get continueWithApple => 'Continue with Apple';

	/// en: 'By continuing you agree to our '
	String get termsPrefix => 'By continuing you agree to our ';

	/// en: 'Terms of use'
	String get termsOfUse => 'Terms of use';

	/// en: ' and '
	String get and => ' and ';

	/// en: 'Privacy policy'
	String get privacyPolicy => 'Privacy policy';

	/// en: 'I agree with '
	String get agreeWith => 'I agree with ';

	/// en: 'or register with'
	String get orRegisterWith => 'or register with';

	late final TranslationsAuthLoginEn login = TranslationsAuthLoginEn.internal(_root);
	late final TranslationsAuthRegisterEn register = TranslationsAuthRegisterEn.internal(_root);
	late final TranslationsAuthForgotPasswordEn forgotPassword = TranslationsAuthForgotPasswordEn.internal(_root);
	late final TranslationsAuthPasswordStrengthEn passwordStrength = TranslationsAuthPasswordStrengthEn.internal(_root);
	late final TranslationsAuthErrorsEn errors = TranslationsAuthErrorsEn.internal(_root);
	late final TranslationsAuthEmailVerificationEn emailVerification = TranslationsAuthEmailVerificationEn.internal(_root);
	late final TranslationsAuthDeleteAccountEn deleteAccount = TranslationsAuthDeleteAccountEn.internal(_root);
}

// Path: api
class TranslationsApiEn {
	TranslationsApiEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsApiErrorsEn errors = TranslationsApiErrorsEn.internal(_root);
}

// Path: validation
class TranslationsValidationEn {
	TranslationsValidationEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Please enter your email address'
	String get emailRequired => 'Please enter your email address';

	/// en: 'Please enter a valid email address'
	String get invalidEmail => 'Please enter a valid email address';

	/// en: 'This field is required'
	String get fieldRequired => 'This field is required';

	/// en: 'Password must be at least 8 characters'
	String get passwordTooShort => 'Password must be at least 8 characters';

	/// en: 'Passwords do not match'
	String get passwordsDoNotMatch => 'Passwords do not match';
}

// Path: onboarding
class TranslationsOnboardingEn {
	TranslationsOnboardingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsOnboardingStep1En step1 = TranslationsOnboardingStep1En.internal(_root);
	late final TranslationsOnboardingStep2En step2 = TranslationsOnboardingStep2En.internal(_root);
	late final TranslationsOnboardingStep3En step3 = TranslationsOnboardingStep3En.internal(_root);
}

// Path: events
class TranslationsEventsEn {
	TranslationsEventsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Featured events'
	String get featuredEvents => 'Featured events';

	/// en: 'Upcoming events'
	String get upcomingEvents => 'Upcoming events';

	/// en: 'No events found'
	String get noEventsFound => 'No events found';

	/// en: 'No events match your current filters. Try adjusting your selection or clear all filters.'
	String get noEventsForFilter => 'No events match your current filters. Try adjusting your selection or clear all filters.';

	/// en: 'Dance styles'
	String get danceStyles => 'Dance styles';

	/// en: 'DANCE STYLES'
	String get danceStylesLabel => 'DANCE STYLES';

	/// en: 'Location'
	String get location => 'Location';

	late final TranslationsEventsDetailEn detail = TranslationsEventsDetailEn.internal(_root);
	late final TranslationsEventsFilterEn filter = TranslationsEventsFilterEn.internal(_root);
	late final TranslationsEventsFiltersEn filters = TranslationsEventsFiltersEn.internal(_root);
	late final TranslationsEventsEditEn edit = TranslationsEventsEditEn.internal(_root);
}

// Path: courses
class TranslationsCoursesEn {
	TranslationsCoursesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dance courses'
	String get title => 'Dance courses';

	/// en: 'Find your course'
	String get subtitle => 'Find your course';

	/// en: 'Featured courses'
	String get featuredCourses => 'Featured courses';

	/// en: 'All courses'
	String get allCourses => 'All courses';

	/// en: 'No courses found'
	String get noCoursesFound => 'No courses found';

	/// en: 'No courses match your current filters. Try adjusting your selection or clear all filters.'
	String get noCoursesForFilter => 'No courses match your current filters. Try adjusting your selection or clear all filters.';

	late final TranslationsCoursesCourseTypesEn courseTypes = TranslationsCoursesCourseTypesEn.internal(_root);
	late final TranslationsCoursesDetailEn detail = TranslationsCoursesDetailEn.internal(_root);
	late final TranslationsCoursesEditEn edit = TranslationsCoursesEditEn.internal(_root);
}

// Path: profile
class TranslationsProfileEn {
	TranslationsProfileEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile'
	String get title => 'Profile';

	/// en: 'Loading profile...'
	String get loading => 'Loading profile...';

	/// en: 'Failed to load profile. Please try again.'
	String get error => 'Failed to load profile. Please try again.';

	late final TranslationsProfileLegalPageEn legalPage = TranslationsProfileLegalPageEn.internal(_root);
	late final TranslationsProfileSectionsEn sections = TranslationsProfileSectionsEn.internal(_root);
	late final TranslationsProfileAccountEn account = TranslationsProfileAccountEn.internal(_root);
	late final TranslationsProfileSettingsEn settings = TranslationsProfileSettingsEn.internal(_root);
	late final TranslationsProfileSupportEn support = TranslationsProfileSupportEn.internal(_root);
	late final TranslationsProfileAppInfoEn appInfo = TranslationsProfileAppInfoEn.internal(_root);
	late final TranslationsProfileDangerEn danger = TranslationsProfileDangerEn.internal(_root);
	late final TranslationsProfileChangePasswordEn changePassword = TranslationsProfileChangePasswordEn.internal(_root);
	late final TranslationsProfileEditProfileEn editProfile = TranslationsProfileEditProfileEn.internal(_root);
}

// Path: premium
class TranslationsPremiumEn {
	TranslationsPremiumEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dancee Premium'
	String get title => 'Dancee Premium';

	/// en: 'Unlock all features'
	String get bannerSubtitle => 'Unlock all features';

	/// en: 'Unlock full potential'
	String get heroTitle => 'Unlock full potential';

	/// en: 'Get access to all premium features and improve your dance experiences'
	String get heroSubtitle => 'Get access to all premium features and improve your dance experiences';

	/// en: 'What you get with Premium'
	String get featuresTitle => 'What you get with Premium';

	/// en: 'What our users say'
	String get testimonialsTitle => 'What our users say';

	/// en: 'Frequently asked questions'
	String get faqTitle => 'Frequently asked questions';

	/// en: 'Ready to start?'
	String get ctaTitle => 'Ready to start?';

	/// en: 'Join thousands of satisfied dancers'
	String get ctaSubtitle => 'Join thousands of satisfied dancers';

	/// en: 'Get Premium now'
	String get ctaButton => 'Get Premium now';

	/// en: '7 days free · Cancel anytime'
	String get ctaNote => '7 days free · Cancel anytime';
}

// Path: saved
class TranslationsSavedEn {
	TranslationsSavedEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Saved events'
	String get title => 'Saved events';

	/// en: 'Your favorite events'
	String get subtitle => 'Your favorite events';

	/// en: 'No saved events'
	String get emptyTitle => 'No saved events';

	/// en: 'Events you save will appear here'
	String get emptySubtitle => 'Events you save will appear here';
}

// Path: authGate
class TranslationsAuthGateEn {
	TranslationsAuthGateEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign in required'
	String get title => 'Sign in required';

	/// en: 'Create an account or sign in to access your saved events and profile.'
	String get message => 'Create an account or sign in to access your saved events and profile.';

	/// en: 'You need to sign in to use this feature.'
	String get actionMessage => 'You need to sign in to use this feature.';

	/// en: 'Log in'
	String get login => 'Log in';

	/// en: 'Create account'
	String get register => 'Create account';

	/// en: 'Signed out successfully'
	String get logoutTitle => 'Signed out successfully';

	/// en: 'You can sign in again anytime.'
	String get logoutMessage => 'You can sign in again anytime.';
}

// Path: contact
class TranslationsContactEn {
	TranslationsContactEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dancee Team'
	String get teamName => 'Dancee Team';

	/// en: 'We'd love to read your feedback...'
	String get description => 'We\'d love to read your feedback...';

	/// en: 'Response time'
	String get responseTime => 'Response time';

	/// en: 'We usually respond within 24 hours on working days. Thank you for your patience!'
	String get responseTimeDetail => 'We usually respond within 24 hours on working days. Thank you for your patience!';

	/// en: 'Device information'
	String get deviceInfo => 'Device information';

	/// en: 'Automatically attached'
	String get autoAttached => 'Automatically attached';

	late final TranslationsContactFormEn form = TranslationsContactFormEn.internal(_root);
	late final TranslationsContactDeviceInfoLabelsEn deviceInfoLabels = TranslationsContactDeviceInfoLabelsEn.internal(_root);
}

// Path: common.months
class TranslationsCommonMonthsEn {
	TranslationsCommonMonthsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Jan'
	String get jan => 'Jan';

	/// en: 'Feb'
	String get feb => 'Feb';

	/// en: 'Mar'
	String get mar => 'Mar';

	/// en: 'Apr'
	String get apr => 'Apr';

	/// en: 'May'
	String get may => 'May';

	/// en: 'Jun'
	String get jun => 'Jun';

	/// en: 'Jul'
	String get jul => 'Jul';

	/// en: 'Aug'
	String get aug => 'Aug';

	/// en: 'Sep'
	String get sep => 'Sep';

	/// en: 'Oct'
	String get oct => 'Oct';

	/// en: 'Nov'
	String get nov => 'Nov';

	/// en: 'Dec'
	String get dec => 'Dec';
}

// Path: common.form
class TranslationsCommonFormEn {
	TranslationsCommonFormEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'E-mail'
	String get email => 'E-mail';

	/// en: 'your@email.com'
	String get emailHint => 'your@email.com';

	/// en: 'Password'
	String get password => 'Password';

	/// en: '••••••••'
	String get passwordPlaceholder => '••••••••';

	/// en: 'Confirm password'
	String get confirmPassword => 'Confirm password';

	/// en: 'First name'
	String get firstName => 'First name';

	/// en: 'Your first name'
	String get firstNameHint => 'Your first name';

	/// en: 'Last name'
	String get lastName => 'Last name';

	/// en: 'Your last name'
	String get lastNameHint => 'Your last name';

	/// en: 'City'
	String get city => 'City';

	/// en: 'Phone'
	String get phone => 'Phone';

	/// en: 'Full name'
	String get fullName => 'Full name';
}

// Path: auth.login
class TranslationsAuthLoginEn {
	TranslationsAuthLoginEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome back!'
	String get title => 'Welcome back!';

	/// en: 'Sign in and continue exploring dance events'
	String get subtitle => 'Sign in and continue exploring dance events';

	/// en: 'Stay logged in'
	String get stayLoggedIn => 'Stay logged in';

	/// en: 'Forgot password?'
	String get forgotPassword => 'Forgot password?';

	/// en: 'Sign in'
	String get submit => 'Sign in';

	/// en: 'Don't have an account?'
	String get noAccount => 'Don\'t have an account?';

	/// en: 'Register'
	String get register => 'Register';
}

// Path: auth.register
class TranslationsAuthRegisterEn {
	TranslationsAuthRegisterEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create an account'
	String get title => 'Create an account';

	/// en: 'Register and start exploring dance events'
	String get subtitle => 'Register and start exploring dance events';

	/// en: 'Passwords match'
	String get passwordsMatch => 'Passwords match';

	/// en: 'Passwords don't match'
	String get passwordsMismatch => 'Passwords don\'t match';

	/// en: 'I want to receive news about dance events'
	String get newsletter => 'I want to receive news about dance events';

	/// en: 'Create account'
	String get submit => 'Create account';

	/// en: 'Already have an account?'
	String get hasAccount => 'Already have an account?';

	/// en: 'Sign in'
	String get login => 'Sign in';
}

// Path: auth.forgotPassword
class TranslationsAuthForgotPasswordEn {
	TranslationsAuthForgotPasswordEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Forgot password?'
	String get title => 'Forgot password?';

	/// en: 'Enter your email and we'll send you a link to reset your password'
	String get subtitle => 'Enter your email and we\'ll send you a link to reset your password';

	/// en: 'Send link'
	String get submit => 'Send link';

	/// en: 'Check your inbox'
	String get checkInbox => 'Check your inbox';

	/// en: 'After sending you'll receive an email with a link to reset your password. The link is valid for 24 hours.'
	String get checkInboxDetail => 'After sending you\'ll receive an email with a link to reset your password. The link is valid for 24 hours.';

	/// en: 'Remembered your password?'
	String get rememberPassword => 'Remembered your password?';

	/// en: 'Sign in'
	String get login => 'Sign in';

	/// en: 'Need help?'
	String get needHelp => 'Need help?';
}

// Path: auth.passwordStrength
class TranslationsAuthPasswordStrengthEn {
	TranslationsAuthPasswordStrengthEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Weak password'
	String get weak => 'Weak password';

	/// en: 'Medium'
	String get medium => 'Medium';

	/// en: 'Strong password'
	String get strong => 'Strong password';

	/// en: 'Very strong'
	String get veryStrong => 'Very strong';

	/// en: 'At least 8 characters'
	String get hint => 'At least 8 characters';
}

// Path: auth.errors
class TranslationsAuthErrorsEn {
	TranslationsAuthErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Invalid email or password'
	String get invalidCredential => 'Invalid email or password';

	/// en: 'This account has been disabled'
	String get userDisabled => 'This account has been disabled';

	/// en: 'An account with this email already exists'
	String get emailAlreadyInUse => 'An account with this email already exists';

	/// en: 'Password is too weak'
	String get weakPassword => 'Password is too weak';

	/// en: 'Too many attempts. Please try again later'
	String get tooManyRequests => 'Too many attempts. Please try again later';

	/// en: 'Network error. Please check your connection'
	String get networkError => 'Network error. Please check your connection';

	/// en: 'An error occurred. Please try again'
	String get generic => 'An error occurred. Please try again';
}

// Path: auth.emailVerification
class TranslationsAuthEmailVerificationEn {
	TranslationsAuthEmailVerificationEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Verify your email'
	String get title => 'Verify your email';

	/// en: 'We sent a verification email to ${email}'
	String subtitle({required Object email}) => 'We sent a verification email to ${email}';

	/// en: 'Resend verification email'
	String get resend => 'Resend verification email';

	/// en: 'Verification email sent. Please check your inbox.'
	String get resendConfirmed => 'Verification email sent. Please check your inbox.';

	/// en: 'I've verified my email'
	String get checkVerified => 'I\'ve verified my email';

	/// en: 'Email not verified yet. Please check your inbox.'
	String get notVerifiedYet => 'Email not verified yet. Please check your inbox.';

	/// en: 'Sign out'
	String get signOut => 'Sign out';
}

// Path: auth.deleteAccount
class TranslationsAuthDeleteAccountEn {
	TranslationsAuthDeleteAccountEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete account?'
	String get confirmTitle => 'Delete account?';

	/// en: 'This action permanently removes all your data. This cannot be undone.'
	String get confirmBody => 'This action permanently removes all your data. This cannot be undone.';

	/// en: 'Please confirm your password to continue'
	String get reauthPrompt => 'Please confirm your password to continue';

	/// en: 'Your account has been deleted'
	String get success => 'Your account has been deleted';

	/// en: 'Failed to delete account. Please try again.'
	String get error => 'Failed to delete account. Please try again.';
}

// Path: api.errors
class TranslationsApiErrorsEn {
	TranslationsApiErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Connection timed out. Please check your network.'
	String get connectionTimeout => 'Connection timed out. Please check your network.';

	/// en: 'Server took too long to respond. Please try again.'
	String get receiveTimeout => 'Server took too long to respond. Please try again.';

	/// en: 'Request timed out while sending. Please try again.'
	String get sendTimeout => 'Request timed out while sending. Please try again.';

	/// en: 'No internet connection. Please check your network.'
	String get noConnection => 'No internet connection. Please check your network.';

	/// en: 'Request was cancelled.'
	String get requestCancelled => 'Request was cancelled.';

	/// en: 'Bad request. Please try again.'
	String get badRequest => 'Bad request. Please try again.';

	/// en: 'Session expired. Please sign in again.'
	String get unauthorized => 'Session expired. Please sign in again.';

	/// en: 'Access denied. Please contact support.'
	String get forbidden => 'Access denied. Please contact support.';

	/// en: 'The requested resource was not found.'
	String get notFound => 'The requested resource was not found.';

	/// en: 'A conflict occurred. Please try again.'
	String get conflict => 'A conflict occurred. Please try again.';

	/// en: 'Server error. Please try again later.'
	String get internalServerError => 'Server error. Please try again later.';

	/// en: 'Server is temporarily unavailable. Please try again later.'
	String get badGateway => 'Server is temporarily unavailable. Please try again later.';

	/// en: 'Service is unavailable. Please try again later.'
	String get serviceUnavailable => 'Service is unavailable. Please try again later.';

	/// en: 'An error occurred. Please try again.'
	String get clientError => 'An error occurred. Please try again.';

	/// en: 'Server error. Please try again later.'
	String get serverError => 'Server error. Please try again later.';

	/// en: 'An unexpected error occurred. Please try again.'
	String get generic => 'An unexpected error occurred. Please try again.';
}

// Path: onboarding.step1
class TranslationsOnboardingStep1En {
	TranslationsOnboardingStep1En.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'What dances do you like?'
	String get title => 'What dances do you like?';

	/// en: 'Choose your favorite dance styles so we can offer you relevant events'
	String get subtitle => 'Choose your favorite dance styles so we can offer you relevant events';
}

// Path: onboarding.step2
class TranslationsOnboardingStep2En {
	TranslationsOnboardingStep2En.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'What is your level?'
	String get title => 'What is your level?';

	/// en: 'It will help us recommend suitable events and courses'
	String get subtitle => 'It will help us recommend suitable events and courses';
}

// Path: onboarding.step3
class TranslationsOnboardingStep3En {
	TranslationsOnboardingStep3En.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Where are you located?'
	String get title => 'Where are you located?';

	/// en: 'We'll find the nearest dance events in your area'
	String get subtitle => 'We\'ll find the nearest dance events in your area';

	/// en: '10 km'
	String get radius10km => '10 km';

	/// en: '25 km'
	String get radius25km => '25 km';

	/// en: '50 km'
	String get radius50km => '50 km';

	/// en: 'Whole country'
	String get radiusAll => 'Whole country';

	/// en: 'E.g. Prague, Brno...'
	String get cityHint => 'E.g. Prague, Brno...';

	/// en: 'Search events within radius'
	String get searchRadius => 'Search events within radius';

	/// en: 'Use current location'
	String get useCurrentLocation => 'Use current location';
}

// Path: events.detail
class TranslationsEventsDetailEn {
	TranslationsEventsDetailEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Event detail'
	String get header => 'Event detail';

	/// en: 'Event description'
	String get description => 'Event description';

	/// en: 'Additional information'
	String get additionalInfo => 'Additional information';

	/// en: 'Admission'
	String get admission => 'Admission';

	/// en: 'Dresscode'
	String get dresscode => 'Dresscode';

	/// en: 'Buy tickets'
	String get buyTickets => 'Buy tickets';

	/// en: 'Original source'
	String get originalSource => 'Original source';

	/// en: 'Event program'
	String get program => 'Event program';

	/// en: 'Event not found'
	String get notFound => 'Event not found';

	/// en: 'Lector: ${name}'
	String lector({required Object name}) => 'Lector: ${name}';

	/// en: 'DJ: ${name}'
	String dj({required Object name}) => 'DJ: ${name}';
}

// Path: events.filter
class TranslationsEventsFilterEn {
	TranslationsEventsFilterEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '${count} selected'
	String selectedCount({required Object count}) => '${count} selected';

	/// en: 'SELECTED STYLES'
	String get selectedStyles => 'SELECTED STYLES';

	/// en: 'Apply filter'
	String get apply => 'Apply filter';

	/// en: 'Apply filter (${count})'
	String applyCount({required Object count}) => 'Apply filter (${count})';

	/// en: 'Select location'
	String get selectLocation => 'Select location';

	/// en: 'Search city or area...'
	String get searchCityHint => 'Search city or area...';

	/// en: 'Use my location'
	String get useMyLocation => 'Use my location';

	/// en: 'Automatically finds events near you'
	String get useMyLocationSubtitle => 'Automatically finds events near you';

	/// en: 'Popular cities'
	String get popularCities => 'Popular cities';

	/// en: 'All cities'
	String get allCities => 'All cities';

	/// en: 'SELECTED REGIONS'
	String get selectedRegions => 'SELECTED REGIONS';

	/// en: 'No results found'
	String get noResults => 'No results found';

	/// en: 'Abroad'
	String get abroad => 'Abroad';

	/// en: 'Unknown location'
	String get unknownRegion => 'Unknown location';
}

// Path: events.filters
class TranslationsEventsFiltersEn {
	TranslationsEventsFiltersEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'This week'
	String get thisWeek => 'This week';

	/// en: 'This month'
	String get thisMonth => 'This month';

	/// en: 'This weekend'
	String get thisWeekend => 'This weekend';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Evening'
	String get evening => 'Evening';

	/// en: 'Weekend'
	String get weekend => 'Weekend';

	/// en: 'Multi-day'
	String get multiDay => 'Multi-day';
}

// Path: events.edit
class TranslationsEventsEditEn {
	TranslationsEventsEditEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit event'
	String get header => 'Edit event';

	/// en: 'Save changes'
	String get submit => 'Save changes';

	/// en: 'Event updated successfully'
	String get success => 'Event updated successfully';

	/// en: 'Failed to update event'
	String get error => 'Failed to update event';
}

// Path: courses.courseTypes
class TranslationsCoursesCourseTypesEn {
	TranslationsCoursesCourseTypesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All'
	String get all => 'All';

	/// en: 'Workshop'
	String get workshop => 'Workshop';

	/// en: 'Regular course'
	String get regular => 'Regular course';
}

// Path: courses.detail
class TranslationsCoursesDetailEn {
	TranslationsCoursesDetailEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Course detail'
	String get header => 'Course detail';

	/// en: 'Course not found'
	String get notFound => 'Course not found';

	/// en: 'Course description'
	String get description => 'Course description';

	/// en: 'Course details'
	String get details => 'Course details';

	/// en: 'What you'll learn'
	String get whatYouLearn => 'What you\'ll learn';

	/// en: 'About instructor'
	String get aboutInstructor => 'About instructor';

	/// en: 'Share course'
	String get shareCourse => 'Share course';

	/// en: 'Course price'
	String get coursePrice => 'Course price';

	/// en: 'Price not specified'
	String get priceUnknown => 'Price not specified';

	/// en: 'Available spots'
	String get availableSpots => 'Available spots';

	/// en: 'Register for course'
	String get register => 'Register for course';

	/// en: 'Start date'
	String get startDate => 'Start date';

	/// en: 'End date'
	String get endDate => 'End date';

	/// en: 'Day'
	String get day => 'Day';

	/// en: 'Time'
	String get time => 'Time';

	/// en: 'Lessons'
	String get lessons => 'Lessons';

	/// en: 'Duration'
	String get duration => 'Duration';

	/// en: 'Level'
	String get level => 'Level';

	late final TranslationsCoursesDetailLevelsEn levels = TranslationsCoursesDetailLevelsEn.internal(_root);
	late final TranslationsCoursesDetailDaysEn days = TranslationsCoursesDetailDaysEn.internal(_root);

	/// en: '${count} lessons'
	String lessonsCount({required Object count}) => '${count} lessons';

	/// en: '${count} min'
	String durationMin({required Object count}) => '${count} min';

	/// en: '${current} / ${max} participants'
	String participantsCount({required Object current, required Object max}) => '${current} / ${max} participants';

	/// en: '${count} spots available'
	String spotsAvailable({required Object count}) => '${count} spots available';
}

// Path: courses.edit
class TranslationsCoursesEditEn {
	TranslationsCoursesEditEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit course'
	String get header => 'Edit course';

	/// en: 'Save changes'
	String get submit => 'Save changes';

	/// en: 'Course updated successfully'
	String get success => 'Course updated successfully';

	/// en: 'Failed to update course'
	String get error => 'Failed to update course';
}

// Path: profile.legalPage
class TranslationsProfileLegalPageEn {
	TranslationsProfileLegalPageEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Loading content...'
	String get loading => 'Loading content...';

	/// en: 'Failed to load content. Please try again.'
	String get error => 'Failed to load content. Please try again.';

	/// en: 'Try again'
	String get retry => 'Try again';
}

// Path: profile.sections
class TranslationsProfileSectionsEn {
	TranslationsProfileSectionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Support'
	String get support => 'Support';

	/// en: 'About app'
	String get appInfo => 'About app';

	/// en: 'Danger zone'
	String get dangerZone => 'Danger zone';
}

// Path: profile.account
class TranslationsProfileAccountEn {
	TranslationsProfileAccountEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit profile'
	String get editProfile => 'Edit profile';

	/// en: 'Change password'
	String get changePassword => 'Change password';
}

// Path: profile.settings
class TranslationsProfileSettingsEn {
	TranslationsProfileSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Czech'
	String get czech => 'Czech';

	/// en: 'Notifications'
	String get notifications => 'Notifications';

	/// en: 'English'
	String get english => 'English';

	/// en: 'Spanish'
	String get spanish => 'Spanish';
}

// Path: profile.support
class TranslationsProfileSupportEn {
	TranslationsProfileSupportEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Contact author'
	String get contactAuthor => 'Contact author';

	/// en: 'Rate app'
	String get rateApp => 'Rate app';
}

// Path: profile.appInfo
class TranslationsProfileAppInfoEn {
	TranslationsProfileAppInfoEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App version'
	String get version => 'App version';

	/// en: 'Terms of use'
	String get termsOfUse => 'Terms of use';

	/// en: 'Privacy'
	String get privacy => 'Privacy';
}

// Path: profile.danger
class TranslationsProfileDangerEn {
	TranslationsProfileDangerEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Log out'
	String get logout => 'Log out';

	/// en: 'Are you sure you want to log out?'
	String get logoutConfirmBody => 'Are you sure you want to log out?';

	/// en: 'Delete account'
	String get deleteAccount => 'Delete account';
}

// Path: profile.changePassword
class TranslationsProfileChangePasswordEn {
	TranslationsProfileChangePasswordEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Change password'
	String get title => 'Change password';

	/// en: 'Secure your account'
	String get secureAccount => 'Secure your account';

	/// en: 'A strong password must contain at least 8 characters, uppercase and lowercase letters, numbers and special characters.'
	String get secureAccountDetail => 'A strong password must contain at least 8 characters, uppercase and lowercase letters, numbers and special characters.';

	/// en: 'Current password'
	String get currentPassword => 'Current password';

	/// en: 'Enter current password'
	String get currentPasswordHint => 'Enter current password';

	/// en: 'New password'
	String get newPassword => 'New password';

	/// en: 'Enter new password'
	String get newPasswordHint => 'Enter new password';

	/// en: 'Confirm new password'
	String get confirmPassword => 'Confirm new password';

	/// en: 'Enter new password again'
	String get confirmPasswordHint => 'Enter new password again';

	/// en: 'Save new password'
	String get save => 'Save new password';

	/// en: 'PASSWORD REQUIREMENTS'
	String get requirements => 'PASSWORD REQUIREMENTS';

	/// en: 'Minimum 8 characters'
	String get req8chars => 'Minimum 8 characters';

	/// en: 'At least one uppercase letter (A-Z)'
	String get reqUppercase => 'At least one uppercase letter (A-Z)';

	/// en: 'At least one lowercase letter (a-z)'
	String get reqLowercase => 'At least one lowercase letter (a-z)';

	/// en: 'At least one number (0-9)'
	String get reqNumber => 'At least one number (0-9)';

	/// en: 'At least one special character (!@#\$%^&*)'
	String get reqSpecial => 'At least one special character (!@#\$%^&*)';

	/// en: 'Forgot your password?'
	String get forgotPassword => 'Forgot your password?';

	/// en: 'Password strength: Very weak'
	String get strengthVeryWeak => 'Password strength: Very weak';

	/// en: 'Password strength: Weak'
	String get strengthWeak => 'Password strength: Weak';

	/// en: 'Password strength: Medium'
	String get strengthMedium => 'Password strength: Medium';

	/// en: 'Password strength: Strong'
	String get strengthStrong => 'Password strength: Strong';

	/// en: 'Password changed successfully.'
	String get success => 'Password changed successfully.';

	/// en: 'Failed to change password. Please try again.'
	String get error => 'Failed to change password. Please try again.';

	/// en: 'Current password is incorrect.'
	String get incorrectPassword => 'Current password is incorrect.';
}

// Path: profile.editProfile
class TranslationsProfileEditProfileEn {
	TranslationsProfileEditProfileEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit profile'
	String get title => 'Edit profile';

	late final TranslationsProfileEditProfileSectionsEn sections = TranslationsProfileEditProfileSectionsEn.internal(_root);

	/// en: 'Change photo'
	String get changePhoto => 'Change photo';

	/// en: 'Description'
	String get bio => 'Description';

	/// en: 'Write something about yourself...'
	String get bioHint => 'Write something about yourself...';

	/// en: 'Select your favorite dance styles'
	String get selectDanceStyles => 'Select your favorite dance styles';

	/// en: 'Your dance level'
	String get yourLevel => 'Your dance level';

	/// en: 'Instagram'
	String get instagram => 'Instagram';

	/// en: '@your_username'
	String get instagramHint => '@your_username';

	/// en: 'Facebook'
	String get facebook => 'Facebook';

	/// en: 'facebook.com/your.name'
	String get facebookHint => 'facebook.com/your.name';

	late final TranslationsProfileEditProfileNotificationsEn notifications = TranslationsProfileEditProfileNotificationsEn.internal(_root);
	late final TranslationsProfileEditProfileNotificationSubtitlesEn notificationSubtitles = TranslationsProfileEditProfileNotificationSubtitlesEn.internal(_root);

	/// en: 'Save changes'
	String get save => 'Save changes';

	/// en: 'Profile updated successfully.'
	String get updateSuccess => 'Profile updated successfully.';

	/// en: 'Failed to update profile. Please try again.'
	String get updateError => 'Failed to update profile. Please try again.';

	late final TranslationsProfileEditProfileExperienceLevelsEn experienceLevels = TranslationsProfileEditProfileExperienceLevelsEn.internal(_root);
	late final TranslationsProfileEditProfileAvatarEn avatar = TranslationsProfileEditProfileAvatarEn.internal(_root);
}

// Path: contact.form
class TranslationsContactFormEn {
	TranslationsContactFormEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Message subject'
	String get subject => 'Message subject';

	/// en: 'Feedback'
	String get feedback => 'Feedback';

	/// en: 'Report bug'
	String get reportBug => 'Report bug';

	/// en: 'Feature request'
	String get featureRequest => 'Feature request';

	/// en: 'Other'
	String get other => 'Other';

	/// en: 'Message title'
	String get title => 'Message title';

	/// en: 'Briefly describe your issue or suggestion'
	String get titleHint => 'Briefly describe your issue or suggestion';

	/// en: 'Message'
	String get message => 'Message';

	/// en: 'Describe your issue in detail...'
	String get messageHint => 'Describe your issue in detail...';

	/// en: 'Your reply email'
	String get replyEmail => 'Your reply email';

	/// en: 'Sending...'
	String get sending => 'Sending...';

	/// en: 'Sent!'
	String get sent => 'Sent!';

	/// en: 'Send message'
	String get submit => 'Send message';

	/// en: 'Your message has been sent. We'll get back to you soon!'
	String get success => 'Your message has been sent. We\'ll get back to you soon!';

	/// en: 'Failed to send message. Please try again.'
	String get error => 'Failed to send message. Please try again.';

	/// en: 'Please select a message type'
	String get typeRequired => 'Please select a message type';

	/// en: 'Please enter a title'
	String get titleRequired => 'Please enter a title';

	/// en: 'Please enter a message'
	String get messageRequired => 'Please enter a message';

	/// en: 'Please enter your reply email'
	String get emailRequired => 'Please enter your reply email';
}

// Path: contact.deviceInfoLabels
class TranslationsContactDeviceInfoLabelsEn {
	TranslationsContactDeviceInfoLabelsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App:'
	String get app => 'App:';

	/// en: 'Device:'
	String get device => 'Device:';

	/// en: 'System:'
	String get os => 'System:';
}

// Path: courses.detail.levels
class TranslationsCoursesDetailLevelsEn {
	TranslationsCoursesDetailLevelsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Beginner'
	String get beginner => 'Beginner';

	/// en: 'Intermediate'
	String get intermediate => 'Intermediate';

	/// en: 'Advanced'
	String get advanced => 'Advanced';

	/// en: 'All levels'
	String get allLevels => 'All levels';
}

// Path: courses.detail.days
class TranslationsCoursesDetailDaysEn {
	TranslationsCoursesDetailDaysEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Monday'
	String get monday => 'Monday';

	/// en: 'Tuesday'
	String get tuesday => 'Tuesday';

	/// en: 'Wednesday'
	String get wednesday => 'Wednesday';

	/// en: 'Thursday'
	String get thursday => 'Thursday';

	/// en: 'Friday'
	String get friday => 'Friday';

	/// en: 'Saturday'
	String get saturday => 'Saturday';

	/// en: 'Sunday'
	String get sunday => 'Sunday';
}

// Path: profile.editProfile.sections
class TranslationsProfileEditProfileSectionsEn {
	TranslationsProfileEditProfileSectionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Personal information'
	String get personalInfo => 'Personal information';

	/// en: 'About me'
	String get aboutMe => 'About me';

	/// en: 'Favorite dances'
	String get favoriteDances => 'Favorite dances';

	/// en: 'Level'
	String get level => 'Level';

	/// en: 'Social networks'
	String get socialNetworks => 'Social networks';

	/// en: 'Notifications'
	String get notifications => 'Notifications';
}

// Path: profile.editProfile.notifications
class TranslationsProfileEditProfileNotificationsEn {
	TranslationsProfileEditProfileNotificationsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New events'
	String get newEvents => 'New events';

	/// en: 'Event reminders'
	String get eventReminders => 'Event reminders';

	/// en: 'Marketing messages'
	String get marketing => 'Marketing messages';
}

// Path: profile.editProfile.notificationSubtitles
class TranslationsProfileEditProfileNotificationSubtitlesEn {
	TranslationsProfileEditProfileNotificationSubtitlesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Get notified about new events in your area'
	String get newEvents => 'Get notified about new events in your area';

	/// en: 'Reminders before your saved events'
	String get eventReminders => 'Reminders before your saved events';

	/// en: 'Promotional messages and offers'
	String get marketing => 'Promotional messages and offers';
}

// Path: profile.editProfile.experienceLevels
class TranslationsProfileEditProfileExperienceLevelsEn {
	TranslationsProfileEditProfileExperienceLevelsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Beginner'
	String get beginner => 'Beginner';

	/// en: 'Slightly advanced'
	String get slightlyAdvanced => 'Slightly advanced';

	/// en: 'Advanced'
	String get advanced => 'Advanced';

	/// en: 'Expert'
	String get expert => 'Expert';
}

// Path: profile.editProfile.avatar
class TranslationsProfileEditProfileAvatarEn {
	TranslationsProfileEditProfileAvatarEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Change profile photo'
	String get sourceTitle => 'Change profile photo';

	/// en: 'Take a photo'
	String get takePhoto => 'Take a photo';

	/// en: 'Choose from gallery'
	String get chooseFromGallery => 'Choose from gallery';

	/// en: 'Failed to upload photo. Please try again.'
	String get uploadError => 'Failed to upload photo. Please try again.';

	/// en: 'Failed to update profile photo. Please try again.'
	String get linkError => 'Failed to update profile photo. Please try again.';

	/// en: 'Camera or gallery permission is required to change your photo.'
	String get permissionRequired => 'Camera or gallery permission is required to change your photo.';

	/// en: 'Permission required'
	String get permissionDeniedTitle => 'Permission required';

	/// en: 'You have permanently denied access. Please enable it in your device settings to change your profile photo.'
	String get permissionDeniedMessage => 'You have permanently denied access. Please enable it in your device settings to change your profile photo.';

	/// en: 'Open Settings'
	String get openSettings => 'Open Settings';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.appName' => 'Dancee',
			'common.showAll' => 'Show all',
			'common.months.jan' => 'Jan',
			'common.months.feb' => 'Feb',
			'common.months.mar' => 'Mar',
			'common.months.apr' => 'Apr',
			'common.months.may' => 'May',
			'common.months.jun' => 'Jun',
			'common.months.jul' => 'Jul',
			'common.months.aug' => 'Aug',
			'common.months.sep' => 'Sep',
			'common.months.oct' => 'Oct',
			'common.months.nov' => 'Nov',
			'common.months.dec' => 'Dec',
			'common.date' => 'Date',
			'common.save' => 'Save',
			'common.share' => 'Share',
			'common.map' => 'Map',
			'common.skip' => 'Skip',
			'common.continue_' => 'Continue',
			'common.back' => 'Back',
			'common.finish' => 'Finish',
			'common.cancel' => 'Cancel',
			'common.allow' => 'Allow',
			'common.support' => 'Support',
			'common.faq' => 'FAQ',
			'common.clear' => 'Clear',
			'common.clearFilters' => 'Clear filters',
			'common.current' => 'Current',
			'common.saveChanges' => 'Save changes',
			'common.loading' => 'Loading...',
			'common.retry' => 'Retry',
			'common.logoutSuccess' => 'You have been successfully signed out.',
			'common.from' => ({required Object time}) => 'From ${time}',
			'common.form.email' => 'E-mail',
			'common.form.emailHint' => 'your@email.com',
			'common.form.password' => 'Password',
			'common.form.passwordPlaceholder' => '••••••••',
			'common.form.confirmPassword' => 'Confirm password',
			'common.form.firstName' => 'First name',
			'common.form.firstNameHint' => 'Your first name',
			'common.form.lastName' => 'Last name',
			'common.form.lastNameHint' => 'Your last name',
			'common.form.city' => 'City',
			'common.form.phone' => 'Phone',
			'common.form.fullName' => 'Full name',
			'nav.events' => 'Events',
			'nav.courses' => 'Courses',
			'nav.saved' => 'Saved',
			'nav.profile' => 'Profile',
			'nav.home' => 'Home',
			'nav.search' => 'Search',
			'auth.tagline' => 'Discover the dancing world',
			'auth.orContinueWith' => 'or continue with',
			'auth.continueWithGoogle' => 'Continue with Google',
			'auth.continueWithApple' => 'Continue with Apple',
			'auth.termsPrefix' => 'By continuing you agree to our ',
			'auth.termsOfUse' => 'Terms of use',
			'auth.and' => ' and ',
			'auth.privacyPolicy' => 'Privacy policy',
			'auth.agreeWith' => 'I agree with ',
			'auth.orRegisterWith' => 'or register with',
			'auth.login.title' => 'Welcome back!',
			'auth.login.subtitle' => 'Sign in and continue exploring dance events',
			'auth.login.stayLoggedIn' => 'Stay logged in',
			'auth.login.forgotPassword' => 'Forgot password?',
			'auth.login.submit' => 'Sign in',
			'auth.login.noAccount' => 'Don\'t have an account?',
			'auth.login.register' => 'Register',
			'auth.register.title' => 'Create an account',
			'auth.register.subtitle' => 'Register and start exploring dance events',
			'auth.register.passwordsMatch' => 'Passwords match',
			'auth.register.passwordsMismatch' => 'Passwords don\'t match',
			'auth.register.newsletter' => 'I want to receive news about dance events',
			'auth.register.submit' => 'Create account',
			'auth.register.hasAccount' => 'Already have an account?',
			'auth.register.login' => 'Sign in',
			'auth.forgotPassword.title' => 'Forgot password?',
			'auth.forgotPassword.subtitle' => 'Enter your email and we\'ll send you a link to reset your password',
			'auth.forgotPassword.submit' => 'Send link',
			'auth.forgotPassword.checkInbox' => 'Check your inbox',
			'auth.forgotPassword.checkInboxDetail' => 'After sending you\'ll receive an email with a link to reset your password. The link is valid for 24 hours.',
			'auth.forgotPassword.rememberPassword' => 'Remembered your password?',
			'auth.forgotPassword.login' => 'Sign in',
			'auth.forgotPassword.needHelp' => 'Need help?',
			'auth.passwordStrength.weak' => 'Weak password',
			'auth.passwordStrength.medium' => 'Medium',
			'auth.passwordStrength.strong' => 'Strong password',
			'auth.passwordStrength.veryStrong' => 'Very strong',
			'auth.passwordStrength.hint' => 'At least 8 characters',
			'auth.errors.invalidCredential' => 'Invalid email or password',
			'auth.errors.userDisabled' => 'This account has been disabled',
			'auth.errors.emailAlreadyInUse' => 'An account with this email already exists',
			'auth.errors.weakPassword' => 'Password is too weak',
			'auth.errors.tooManyRequests' => 'Too many attempts. Please try again later',
			'auth.errors.networkError' => 'Network error. Please check your connection',
			'auth.errors.generic' => 'An error occurred. Please try again',
			'auth.emailVerification.title' => 'Verify your email',
			'auth.emailVerification.subtitle' => ({required Object email}) => 'We sent a verification email to ${email}',
			'auth.emailVerification.resend' => 'Resend verification email',
			'auth.emailVerification.resendConfirmed' => 'Verification email sent. Please check your inbox.',
			'auth.emailVerification.checkVerified' => 'I\'ve verified my email',
			'auth.emailVerification.notVerifiedYet' => 'Email not verified yet. Please check your inbox.',
			'auth.emailVerification.signOut' => 'Sign out',
			'auth.deleteAccount.confirmTitle' => 'Delete account?',
			'auth.deleteAccount.confirmBody' => 'This action permanently removes all your data. This cannot be undone.',
			'auth.deleteAccount.reauthPrompt' => 'Please confirm your password to continue',
			'auth.deleteAccount.success' => 'Your account has been deleted',
			'auth.deleteAccount.error' => 'Failed to delete account. Please try again.',
			'api.errors.connectionTimeout' => 'Connection timed out. Please check your network.',
			'api.errors.receiveTimeout' => 'Server took too long to respond. Please try again.',
			'api.errors.sendTimeout' => 'Request timed out while sending. Please try again.',
			'api.errors.noConnection' => 'No internet connection. Please check your network.',
			'api.errors.requestCancelled' => 'Request was cancelled.',
			'api.errors.badRequest' => 'Bad request. Please try again.',
			'api.errors.unauthorized' => 'Session expired. Please sign in again.',
			'api.errors.forbidden' => 'Access denied. Please contact support.',
			'api.errors.notFound' => 'The requested resource was not found.',
			'api.errors.conflict' => 'A conflict occurred. Please try again.',
			'api.errors.internalServerError' => 'Server error. Please try again later.',
			'api.errors.badGateway' => 'Server is temporarily unavailable. Please try again later.',
			'api.errors.serviceUnavailable' => 'Service is unavailable. Please try again later.',
			'api.errors.clientError' => 'An error occurred. Please try again.',
			'api.errors.serverError' => 'Server error. Please try again later.',
			'api.errors.generic' => 'An unexpected error occurred. Please try again.',
			'validation.emailRequired' => 'Please enter your email address',
			'validation.invalidEmail' => 'Please enter a valid email address',
			'validation.fieldRequired' => 'This field is required',
			'validation.passwordTooShort' => 'Password must be at least 8 characters',
			'validation.passwordsDoNotMatch' => 'Passwords do not match',
			'onboarding.step1.title' => 'What dances do you like?',
			'onboarding.step1.subtitle' => 'Choose your favorite dance styles so we can offer you relevant events',
			'onboarding.step2.title' => 'What is your level?',
			'onboarding.step2.subtitle' => 'It will help us recommend suitable events and courses',
			'onboarding.step3.title' => 'Where are you located?',
			'onboarding.step3.subtitle' => 'We\'ll find the nearest dance events in your area',
			'onboarding.step3.radius10km' => '10 km',
			'onboarding.step3.radius25km' => '25 km',
			'onboarding.step3.radius50km' => '50 km',
			'onboarding.step3.radiusAll' => 'Whole country',
			'onboarding.step3.cityHint' => 'E.g. Prague, Brno...',
			'onboarding.step3.searchRadius' => 'Search events within radius',
			'onboarding.step3.useCurrentLocation' => 'Use current location',
			'events.featuredEvents' => 'Featured events',
			'events.upcomingEvents' => 'Upcoming events',
			'events.noEventsFound' => 'No events found',
			'events.noEventsForFilter' => 'No events match your current filters. Try adjusting your selection or clear all filters.',
			'events.danceStyles' => 'Dance styles',
			'events.danceStylesLabel' => 'DANCE STYLES',
			'events.location' => 'Location',
			'events.detail.header' => 'Event detail',
			'events.detail.description' => 'Event description',
			'events.detail.additionalInfo' => 'Additional information',
			'events.detail.admission' => 'Admission',
			'events.detail.dresscode' => 'Dresscode',
			'events.detail.buyTickets' => 'Buy tickets',
			'events.detail.originalSource' => 'Original source',
			'events.detail.program' => 'Event program',
			'events.detail.notFound' => 'Event not found',
			'events.detail.lector' => ({required Object name}) => 'Lector: ${name}',
			'events.detail.dj' => ({required Object name}) => 'DJ: ${name}',
			'events.filter.selectedCount' => ({required Object count}) => '${count} selected',
			'events.filter.selectedStyles' => 'SELECTED STYLES',
			'events.filter.apply' => 'Apply filter',
			'events.filter.applyCount' => ({required Object count}) => 'Apply filter (${count})',
			'events.filter.selectLocation' => 'Select location',
			'events.filter.searchCityHint' => 'Search city or area...',
			'events.filter.useMyLocation' => 'Use my location',
			'events.filter.useMyLocationSubtitle' => 'Automatically finds events near you',
			'events.filter.popularCities' => 'Popular cities',
			'events.filter.allCities' => 'All cities',
			'events.filter.selectedRegions' => 'SELECTED REGIONS',
			'events.filter.noResults' => 'No results found',
			'events.filter.abroad' => 'Abroad',
			'events.filter.unknownRegion' => 'Unknown location',
			'events.filters.today' => 'Today',
			'events.filters.thisWeek' => 'This week',
			'events.filters.thisMonth' => 'This month',
			'events.filters.thisWeekend' => 'This weekend',
			'events.filters.all' => 'All',
			'events.filters.evening' => 'Evening',
			'events.filters.weekend' => 'Weekend',
			'events.filters.multiDay' => 'Multi-day',
			'events.edit.header' => 'Edit event',
			'events.edit.submit' => 'Save changes',
			'events.edit.success' => 'Event updated successfully',
			'events.edit.error' => 'Failed to update event',
			'courses.title' => 'Dance courses',
			'courses.subtitle' => 'Find your course',
			'courses.featuredCourses' => 'Featured courses',
			'courses.allCourses' => 'All courses',
			'courses.noCoursesFound' => 'No courses found',
			'courses.noCoursesForFilter' => 'No courses match your current filters. Try adjusting your selection or clear all filters.',
			'courses.courseTypes.all' => 'All',
			'courses.courseTypes.workshop' => 'Workshop',
			'courses.courseTypes.regular' => 'Regular course',
			'courses.detail.header' => 'Course detail',
			'courses.detail.notFound' => 'Course not found',
			'courses.detail.description' => 'Course description',
			'courses.detail.details' => 'Course details',
			'courses.detail.whatYouLearn' => 'What you\'ll learn',
			'courses.detail.aboutInstructor' => 'About instructor',
			'courses.detail.shareCourse' => 'Share course',
			'courses.detail.coursePrice' => 'Course price',
			'courses.detail.priceUnknown' => 'Price not specified',
			'courses.detail.availableSpots' => 'Available spots',
			'courses.detail.register' => 'Register for course',
			'courses.detail.startDate' => 'Start date',
			'courses.detail.endDate' => 'End date',
			'courses.detail.day' => 'Day',
			'courses.detail.time' => 'Time',
			'courses.detail.lessons' => 'Lessons',
			'courses.detail.duration' => 'Duration',
			'courses.detail.level' => 'Level',
			'courses.detail.levels.beginner' => 'Beginner',
			'courses.detail.levels.intermediate' => 'Intermediate',
			'courses.detail.levels.advanced' => 'Advanced',
			'courses.detail.levels.allLevels' => 'All levels',
			'courses.detail.days.monday' => 'Monday',
			'courses.detail.days.tuesday' => 'Tuesday',
			'courses.detail.days.wednesday' => 'Wednesday',
			'courses.detail.days.thursday' => 'Thursday',
			'courses.detail.days.friday' => 'Friday',
			'courses.detail.days.saturday' => 'Saturday',
			'courses.detail.days.sunday' => 'Sunday',
			'courses.detail.lessonsCount' => ({required Object count}) => '${count} lessons',
			'courses.detail.durationMin' => ({required Object count}) => '${count} min',
			'courses.detail.participantsCount' => ({required Object current, required Object max}) => '${current} / ${max} participants',
			'courses.detail.spotsAvailable' => ({required Object count}) => '${count} spots available',
			'courses.edit.header' => 'Edit course',
			'courses.edit.submit' => 'Save changes',
			'courses.edit.success' => 'Course updated successfully',
			'courses.edit.error' => 'Failed to update course',
			'profile.title' => 'Profile',
			'profile.loading' => 'Loading profile...',
			'profile.error' => 'Failed to load profile. Please try again.',
			'profile.legalPage.loading' => 'Loading content...',
			'profile.legalPage.error' => 'Failed to load content. Please try again.',
			'profile.legalPage.retry' => 'Try again',
			'profile.sections.account' => 'Account',
			'profile.sections.settings' => 'Settings',
			'profile.sections.support' => 'Support',
			'profile.sections.appInfo' => 'About app',
			'profile.sections.dangerZone' => 'Danger zone',
			'profile.account.editProfile' => 'Edit profile',
			'profile.account.changePassword' => 'Change password',
			'profile.settings.language' => 'Language',
			'profile.settings.czech' => 'Czech',
			'profile.settings.notifications' => 'Notifications',
			'profile.settings.english' => 'English',
			'profile.settings.spanish' => 'Spanish',
			'profile.support.contactAuthor' => 'Contact author',
			'profile.support.rateApp' => 'Rate app',
			'profile.appInfo.version' => 'App version',
			'profile.appInfo.termsOfUse' => 'Terms of use',
			'profile.appInfo.privacy' => 'Privacy',
			'profile.danger.logout' => 'Log out',
			'profile.danger.logoutConfirmBody' => 'Are you sure you want to log out?',
			'profile.danger.deleteAccount' => 'Delete account',
			'profile.changePassword.title' => 'Change password',
			'profile.changePassword.secureAccount' => 'Secure your account',
			'profile.changePassword.secureAccountDetail' => 'A strong password must contain at least 8 characters, uppercase and lowercase letters, numbers and special characters.',
			'profile.changePassword.currentPassword' => 'Current password',
			'profile.changePassword.currentPasswordHint' => 'Enter current password',
			'profile.changePassword.newPassword' => 'New password',
			'profile.changePassword.newPasswordHint' => 'Enter new password',
			'profile.changePassword.confirmPassword' => 'Confirm new password',
			'profile.changePassword.confirmPasswordHint' => 'Enter new password again',
			'profile.changePassword.save' => 'Save new password',
			'profile.changePassword.requirements' => 'PASSWORD REQUIREMENTS',
			'profile.changePassword.req8chars' => 'Minimum 8 characters',
			'profile.changePassword.reqUppercase' => 'At least one uppercase letter (A-Z)',
			'profile.changePassword.reqLowercase' => 'At least one lowercase letter (a-z)',
			'profile.changePassword.reqNumber' => 'At least one number (0-9)',
			'profile.changePassword.reqSpecial' => 'At least one special character (!@#\$%^&*)',
			'profile.changePassword.forgotPassword' => 'Forgot your password?',
			'profile.changePassword.strengthVeryWeak' => 'Password strength: Very weak',
			'profile.changePassword.strengthWeak' => 'Password strength: Weak',
			'profile.changePassword.strengthMedium' => 'Password strength: Medium',
			'profile.changePassword.strengthStrong' => 'Password strength: Strong',
			'profile.changePassword.success' => 'Password changed successfully.',
			'profile.changePassword.error' => 'Failed to change password. Please try again.',
			'profile.changePassword.incorrectPassword' => 'Current password is incorrect.',
			'profile.editProfile.title' => 'Edit profile',
			'profile.editProfile.sections.personalInfo' => 'Personal information',
			'profile.editProfile.sections.aboutMe' => 'About me',
			'profile.editProfile.sections.favoriteDances' => 'Favorite dances',
			'profile.editProfile.sections.level' => 'Level',
			'profile.editProfile.sections.socialNetworks' => 'Social networks',
			'profile.editProfile.sections.notifications' => 'Notifications',
			'profile.editProfile.changePhoto' => 'Change photo',
			'profile.editProfile.bio' => 'Description',
			'profile.editProfile.bioHint' => 'Write something about yourself...',
			'profile.editProfile.selectDanceStyles' => 'Select your favorite dance styles',
			'profile.editProfile.yourLevel' => 'Your dance level',
			'profile.editProfile.instagram' => 'Instagram',
			'profile.editProfile.instagramHint' => '@your_username',
			'profile.editProfile.facebook' => 'Facebook',
			'profile.editProfile.facebookHint' => 'facebook.com/your.name',
			'profile.editProfile.notifications.newEvents' => 'New events',
			'profile.editProfile.notifications.eventReminders' => 'Event reminders',
			'profile.editProfile.notifications.marketing' => 'Marketing messages',
			'profile.editProfile.notificationSubtitles.newEvents' => 'Get notified about new events in your area',
			'profile.editProfile.notificationSubtitles.eventReminders' => 'Reminders before your saved events',
			'profile.editProfile.notificationSubtitles.marketing' => 'Promotional messages and offers',
			'profile.editProfile.save' => 'Save changes',
			'profile.editProfile.updateSuccess' => 'Profile updated successfully.',
			'profile.editProfile.updateError' => 'Failed to update profile. Please try again.',
			'profile.editProfile.experienceLevels.beginner' => 'Beginner',
			'profile.editProfile.experienceLevels.slightlyAdvanced' => 'Slightly advanced',
			'profile.editProfile.experienceLevels.advanced' => 'Advanced',
			'profile.editProfile.experienceLevels.expert' => 'Expert',
			'profile.editProfile.avatar.sourceTitle' => 'Change profile photo',
			'profile.editProfile.avatar.takePhoto' => 'Take a photo',
			'profile.editProfile.avatar.chooseFromGallery' => 'Choose from gallery',
			'profile.editProfile.avatar.uploadError' => 'Failed to upload photo. Please try again.',
			'profile.editProfile.avatar.linkError' => 'Failed to update profile photo. Please try again.',
			'profile.editProfile.avatar.permissionRequired' => 'Camera or gallery permission is required to change your photo.',
			'profile.editProfile.avatar.permissionDeniedTitle' => 'Permission required',
			'profile.editProfile.avatar.permissionDeniedMessage' => 'You have permanently denied access. Please enable it in your device settings to change your profile photo.',
			'profile.editProfile.avatar.openSettings' => 'Open Settings',
			'premium.title' => 'Dancee Premium',
			'premium.bannerSubtitle' => 'Unlock all features',
			'premium.heroTitle' => 'Unlock full potential',
			'premium.heroSubtitle' => 'Get access to all premium features and improve your dance experiences',
			'premium.featuresTitle' => 'What you get with Premium',
			'premium.testimonialsTitle' => 'What our users say',
			'premium.faqTitle' => 'Frequently asked questions',
			'premium.ctaTitle' => 'Ready to start?',
			'premium.ctaSubtitle' => 'Join thousands of satisfied dancers',
			'premium.ctaButton' => 'Get Premium now',
			'premium.ctaNote' => '7 days free · Cancel anytime',
			'saved.title' => 'Saved events',
			'saved.subtitle' => 'Your favorite events',
			'saved.emptyTitle' => 'No saved events',
			'saved.emptySubtitle' => 'Events you save will appear here',
			'authGate.title' => 'Sign in required',
			'authGate.message' => 'Create an account or sign in to access your saved events and profile.',
			'authGate.actionMessage' => 'You need to sign in to use this feature.',
			'authGate.login' => 'Log in',
			'authGate.register' => 'Create account',
			'authGate.logoutTitle' => 'Signed out successfully',
			'authGate.logoutMessage' => 'You can sign in again anytime.',
			'contact.teamName' => 'Dancee Team',
			'contact.description' => 'We\'d love to read your feedback...',
			'contact.responseTime' => 'Response time',
			'contact.responseTimeDetail' => 'We usually respond within 24 hours on working days. Thank you for your patience!',
			'contact.deviceInfo' => 'Device information',
			'contact.autoAttached' => 'Automatically attached',
			'contact.form.subject' => 'Message subject',
			'contact.form.feedback' => 'Feedback',
			'contact.form.reportBug' => 'Report bug',
			'contact.form.featureRequest' => 'Feature request',
			'contact.form.other' => 'Other',
			'contact.form.title' => 'Message title',
			'contact.form.titleHint' => 'Briefly describe your issue or suggestion',
			'contact.form.message' => 'Message',
			'contact.form.messageHint' => 'Describe your issue in detail...',
			'contact.form.replyEmail' => 'Your reply email',
			'contact.form.sending' => 'Sending...',
			'contact.form.sent' => 'Sent!',
			'contact.form.submit' => 'Send message',
			'contact.form.success' => 'Your message has been sent. We\'ll get back to you soon!',
			'contact.form.error' => 'Failed to send message. Please try again.',
			'contact.form.typeRequired' => 'Please select a message type',
			'contact.form.titleRequired' => 'Please enter a title',
			'contact.form.messageRequired' => 'Please enter a message',
			'contact.form.emailRequired' => 'Please enter your reply email',
			'contact.deviceInfoLabels.app' => 'App:',
			'contact.deviceInfoLabels.device' => 'Device:',
			'contact.deviceInfoLabels.os' => 'System:',
			_ => null,
		};
	}
}
