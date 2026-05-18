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
class TranslationsCs extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsCs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.cs,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <cs>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsCs _root = this; // ignore: unused_field

	@override 
	TranslationsCs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsCs(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsCommonCs common = _TranslationsCommonCs._(_root);
	@override late final _TranslationsNavCs nav = _TranslationsNavCs._(_root);
	@override late final _TranslationsAuthCs auth = _TranslationsAuthCs._(_root);
	@override late final _TranslationsApiCs api = _TranslationsApiCs._(_root);
	@override late final _TranslationsValidationCs validation = _TranslationsValidationCs._(_root);
	@override late final _TranslationsOnboardingCs onboarding = _TranslationsOnboardingCs._(_root);
	@override late final _TranslationsEventsCs events = _TranslationsEventsCs._(_root);
	@override late final _TranslationsCoursesCs courses = _TranslationsCoursesCs._(_root);
	@override late final _TranslationsProfileCs profile = _TranslationsProfileCs._(_root);
	@override late final _TranslationsPremiumCs premium = _TranslationsPremiumCs._(_root);
	@override late final _TranslationsSavedCs saved = _TranslationsSavedCs._(_root);
	@override late final _TranslationsAuthGateCs authGate = _TranslationsAuthGateCs._(_root);
	@override late final _TranslationsContactCs contact = _TranslationsContactCs._(_root);
}

// Path: common
class _TranslationsCommonCs extends TranslationsCommonEn {
	_TranslationsCommonCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Dancee';
	@override String get showAll => 'Zobrazit vše';
	@override late final _TranslationsCommonMonthsCs months = _TranslationsCommonMonthsCs._(_root);
	@override String get date => 'Datum';
	@override String get save => 'Uložit';
	@override String get share => 'Sdílet';
	@override String get map => 'Mapa';
	@override String get skip => 'Přeskočit';
	@override String get continue_ => 'Pokračovat';
	@override String get back => 'Zpět';
	@override String get finish => 'Dokončit';
	@override String get cancel => 'Zrušit';
	@override String get allow => 'Povolit';
	@override String get support => 'Podpora';
	@override String get faq => 'FAQ';
	@override String get clear => 'Vymazat';
	@override String get clearFilters => 'Vymazat filtry';
	@override String get current => 'Aktuální';
	@override String get saveChanges => 'Uložit změny';
	@override String get loading => 'Načítání...';
	@override String get retry => 'Zkusit znovu';
	@override String get logoutSuccess => 'Byli jste úspěšně odhlášeni.';
	@override String from({required Object time}) => 'Od ${time}';
	@override late final _TranslationsCommonFormCs form = _TranslationsCommonFormCs._(_root);
}

// Path: nav
class _TranslationsNavCs extends TranslationsNavEn {
	_TranslationsNavCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get events => 'Události';
	@override String get courses => 'Kurzy';
	@override String get saved => 'Uložené';
	@override String get profile => 'Profil';
	@override String get home => 'Domů';
	@override String get search => 'Hledat';
}

// Path: auth
class _TranslationsAuthCs extends TranslationsAuthEn {
	_TranslationsAuthCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
	@override late final _TranslationsAuthLoginCs login = _TranslationsAuthLoginCs._(_root);
	@override late final _TranslationsAuthRegisterCs register = _TranslationsAuthRegisterCs._(_root);
	@override late final _TranslationsAuthForgotPasswordCs forgotPassword = _TranslationsAuthForgotPasswordCs._(_root);
	@override late final _TranslationsAuthPasswordStrengthCs passwordStrength = _TranslationsAuthPasswordStrengthCs._(_root);
	@override late final _TranslationsAuthErrorsCs errors = _TranslationsAuthErrorsCs._(_root);
	@override late final _TranslationsAuthEmailVerificationCs emailVerification = _TranslationsAuthEmailVerificationCs._(_root);
	@override late final _TranslationsAuthDeleteAccountCs deleteAccount = _TranslationsAuthDeleteAccountCs._(_root);
}

// Path: api
class _TranslationsApiCs extends TranslationsApiEn {
	_TranslationsApiCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsApiErrorsCs errors = _TranslationsApiErrorsCs._(_root);
}

// Path: validation
class _TranslationsValidationCs extends TranslationsValidationEn {
	_TranslationsValidationCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get emailRequired => 'Zadejte prosím svou e-mailovou adresu';
	@override String get invalidEmail => 'Zadejte prosím platnou e-mailovou adresu';
	@override String get fieldRequired => 'Toto pole je povinné';
	@override String get passwordTooShort => 'Heslo musí mít alespoň 8 znaků';
	@override String get passwordsDoNotMatch => 'Hesla se neshodují';
}

// Path: onboarding
class _TranslationsOnboardingCs extends TranslationsOnboardingEn {
	_TranslationsOnboardingCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOnboardingStep1Cs step1 = _TranslationsOnboardingStep1Cs._(_root);
	@override late final _TranslationsOnboardingStep2Cs step2 = _TranslationsOnboardingStep2Cs._(_root);
	@override late final _TranslationsOnboardingStep3Cs step3 = _TranslationsOnboardingStep3Cs._(_root);
}

// Path: events
class _TranslationsEventsCs extends TranslationsEventsEn {
	_TranslationsEventsCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get featuredEvents => 'Doporučené akce';
	@override String get upcomingEvents => 'Nadcházející akce';
	@override String get noEventsFound => 'Žádné akce nenalezeny';
	@override String get noEventsForFilter => 'Pro zvolené filtry nebyly nalezeny žádné akce. Zkuste upravit výběr nebo vymazat filtry.';
	@override String get danceStyles => 'Taneční styly';
	@override String get danceStylesLabel => 'TANEČNÍ STYLY';
	@override String get location => 'Lokalita';
	@override late final _TranslationsEventsDetailCs detail = _TranslationsEventsDetailCs._(_root);
	@override late final _TranslationsEventsFilterCs filter = _TranslationsEventsFilterCs._(_root);
	@override late final _TranslationsEventsFiltersCs filters = _TranslationsEventsFiltersCs._(_root);
	@override late final _TranslationsEventsEditCs edit = _TranslationsEventsEditCs._(_root);
}

// Path: courses
class _TranslationsCoursesCs extends TranslationsCoursesEn {
	_TranslationsCoursesCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Taneční kurzy';
	@override String get subtitle => 'Najdi svůj kurz';
	@override String get featuredCourses => 'Doporučené kurzy';
	@override String get allCourses => 'Všechny kurzy';
	@override String get noCoursesFound => 'Žádné kurzy nenalezeny';
	@override String get noCoursesForFilter => 'Pro zvolené filtry nebyly nalezeny žádné kurzy. Zkuste upravit výběr nebo vymazat filtry.';
	@override late final _TranslationsCoursesCourseTypesCs courseTypes = _TranslationsCoursesCourseTypesCs._(_root);
	@override late final _TranslationsCoursesDetailCs detail = _TranslationsCoursesDetailCs._(_root);
	@override late final _TranslationsCoursesEditCs edit = _TranslationsCoursesEditCs._(_root);
}

// Path: profile
class _TranslationsProfileCs extends TranslationsProfileEn {
	_TranslationsProfileCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Profil';
	@override String get loading => 'Načítání profilu...';
	@override String get error => 'Nepodařilo se načíst profil. Zkuste to prosím znovu.';
	@override late final _TranslationsProfileLegalPageCs legalPage = _TranslationsProfileLegalPageCs._(_root);
	@override late final _TranslationsProfileSectionsCs sections = _TranslationsProfileSectionsCs._(_root);
	@override late final _TranslationsProfileAccountCs account = _TranslationsProfileAccountCs._(_root);
	@override late final _TranslationsProfileSettingsCs settings = _TranslationsProfileSettingsCs._(_root);
	@override late final _TranslationsProfileSupportCs support = _TranslationsProfileSupportCs._(_root);
	@override late final _TranslationsProfileAppInfoCs appInfo = _TranslationsProfileAppInfoCs._(_root);
	@override late final _TranslationsProfileDangerCs danger = _TranslationsProfileDangerCs._(_root);
	@override late final _TranslationsProfileChangePasswordCs changePassword = _TranslationsProfileChangePasswordCs._(_root);
	@override late final _TranslationsProfileEditProfileCs editProfile = _TranslationsProfileEditProfileCs._(_root);
}

// Path: premium
class _TranslationsPremiumCs extends TranslationsPremiumEn {
	_TranslationsPremiumCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
class _TranslationsSavedCs extends TranslationsSavedEn {
	_TranslationsSavedCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Uložené akce';
	@override String get subtitle => 'Tvoje oblíbené akce';
	@override String get emptyTitle => 'Žádné uložené akce';
	@override String get emptySubtitle => 'Akce, které si uložíš, se zobrazí zde';
}

// Path: authGate
class _TranslationsAuthGateCs extends TranslationsAuthGateEn {
	_TranslationsAuthGateCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vyžaduje přihlášení';
	@override String get message => 'Vytvořte si účet nebo se přihlaste pro přístup k uloženým akcím a profilu.';
	@override String get actionMessage => 'Pro použití této funkce se musíte přihlásit.';
	@override String get login => 'Přihlásit se';
	@override String get register => 'Vytvořit účet';
	@override String get logoutTitle => 'Odhlášení proběhlo úspěšně';
	@override String get logoutMessage => 'Můžete se kdykoli znovu přihlásit.';
}

// Path: contact
class _TranslationsContactCs extends TranslationsContactEn {
	_TranslationsContactCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get teamName => 'Tým Dancee';
	@override String get description => 'Rádi si přečteme vaše zpětné vazby...';
	@override String get responseTime => 'Doba odezvy';
	@override String get responseTimeDetail => 'Obvykle odpovídáme do 24 hodin v pracovní dny. Děkujeme za trpělivost!';
	@override String get deviceInfo => 'Informace o zařízení';
	@override String get autoAttached => 'Automaticky přiloženo';
	@override late final _TranslationsContactFormCs form = _TranslationsContactFormCs._(_root);
	@override late final _TranslationsContactDeviceInfoLabelsCs deviceInfoLabels = _TranslationsContactDeviceInfoLabelsCs._(_root);
}

// Path: common.months
class _TranslationsCommonMonthsCs extends TranslationsCommonMonthsEn {
	_TranslationsCommonMonthsCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
class _TranslationsCommonFormCs extends TranslationsCommonFormEn {
	_TranslationsCommonFormCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
class _TranslationsAuthLoginCs extends TranslationsAuthLoginEn {
	_TranslationsAuthLoginCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
class _TranslationsAuthRegisterCs extends TranslationsAuthRegisterEn {
	_TranslationsAuthRegisterCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
class _TranslationsAuthForgotPasswordCs extends TranslationsAuthForgotPasswordEn {
	_TranslationsAuthForgotPasswordCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
class _TranslationsAuthPasswordStrengthCs extends TranslationsAuthPasswordStrengthEn {
	_TranslationsAuthPasswordStrengthCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get weak => 'Slabé heslo';
	@override String get medium => 'Středně silné';
	@override String get strong => 'Silné heslo';
	@override String get veryStrong => 'Velmi silné';
	@override String get hint => 'Alespoň 8 znaků';
}

// Path: auth.errors
class _TranslationsAuthErrorsCs extends TranslationsAuthErrorsEn {
	_TranslationsAuthErrorsCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
class _TranslationsAuthEmailVerificationCs extends TranslationsAuthEmailVerificationEn {
	_TranslationsAuthEmailVerificationCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
class _TranslationsAuthDeleteAccountCs extends TranslationsAuthDeleteAccountEn {
	_TranslationsAuthDeleteAccountCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get confirmTitle => 'Smazat účet?';
	@override String get confirmBody => 'Tato akce trvale odstraní všechna vaše data. Tuto akci nelze vrátit zpět.';
	@override String get reauthPrompt => 'Pro pokračování potvrďte své heslo';
	@override String get success => 'Váš účet byl smazán';
	@override String get error => 'Nepodařilo se smazat účet. Zkuste to prosím znovu.';
}

// Path: api.errors
class _TranslationsApiErrorsCs extends TranslationsApiErrorsEn {
	_TranslationsApiErrorsCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
class _TranslationsOnboardingStep1Cs extends TranslationsOnboardingStep1En {
	_TranslationsOnboardingStep1Cs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Jaké tance tě baví?';
	@override String get subtitle => 'Vyber své oblíbené taneční styly, abychom ti mohli nabídnout relevantní akce';
}

// Path: onboarding.step2
class _TranslationsOnboardingStep2Cs extends TranslationsOnboardingStep2En {
	_TranslationsOnboardingStep2Cs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Jaká je tvoje úroveň?';
	@override String get subtitle => 'Pomůže nám to doporučit ti vhodné akce a kurzy';
}

// Path: onboarding.step3
class _TranslationsOnboardingStep3Cs extends TranslationsOnboardingStep3En {
	_TranslationsOnboardingStep3Cs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
class _TranslationsEventsDetailCs extends TranslationsEventsDetailEn {
	_TranslationsEventsDetailCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
class _TranslationsEventsFilterCs extends TranslationsEventsFilterEn {
	_TranslationsEventsFilterCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
class _TranslationsEventsFiltersCs extends TranslationsEventsFiltersEn {
	_TranslationsEventsFiltersCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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

// Path: events.edit
class _TranslationsEventsEditCs extends TranslationsEventsEditEn {
	_TranslationsEventsEditCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get header => 'Upravit akci';
	@override String get submit => 'Uložit změny';
	@override String get success => 'Akce byla úspěšně aktualizována';
	@override String get error => 'Nepodařilo se aktualizovat akci';
}

// Path: courses.courseTypes
class _TranslationsCoursesCourseTypesCs extends TranslationsCoursesCourseTypesEn {
	_TranslationsCoursesCourseTypesCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get all => 'Vše';
	@override String get workshop => 'Workshop';
	@override String get regular => 'Pravidelný kurz';
}

// Path: courses.detail
class _TranslationsCoursesDetailCs extends TranslationsCoursesDetailEn {
	_TranslationsCoursesDetailCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
	@override late final _TranslationsCoursesDetailLevelsCs levels = _TranslationsCoursesDetailLevelsCs._(_root);
	@override late final _TranslationsCoursesDetailDaysCs days = _TranslationsCoursesDetailDaysCs._(_root);
	@override String lessonsCount({required Object count}) => '${count} lekcí';
	@override String durationMin({required Object count}) => '${count} min';
	@override String participantsCount({required Object current, required Object max}) => '${current} / ${max} účastníků';
	@override String spotsAvailable({required Object count}) => '${count} volných míst';
}

// Path: courses.edit
class _TranslationsCoursesEditCs extends TranslationsCoursesEditEn {
	_TranslationsCoursesEditCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get header => 'Upravit kurz';
	@override String get submit => 'Uložit změny';
	@override String get success => 'Kurz byl úspěšně aktualizován';
	@override String get error => 'Nepodařilo se aktualizovat kurz';
}

// Path: profile.legalPage
class _TranslationsProfileLegalPageCs extends TranslationsProfileLegalPageEn {
	_TranslationsProfileLegalPageCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Načítání obsahu...';
	@override String get error => 'Nepodařilo se načíst obsah. Zkuste to prosím znovu.';
	@override String get retry => 'Zkusit znovu';
}

// Path: profile.sections
class _TranslationsProfileSectionsCs extends TranslationsProfileSectionsEn {
	_TranslationsProfileSectionsCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get account => 'Účet';
	@override String get settings => 'Nastavení';
	@override String get support => 'Podpora';
	@override String get appInfo => 'O aplikaci';
	@override String get dangerZone => 'Nebezpečná zóna';
}

// Path: profile.account
class _TranslationsProfileAccountCs extends TranslationsProfileAccountEn {
	_TranslationsProfileAccountCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get editProfile => 'Upravit profil';
	@override String get changePassword => 'Změnit heslo';
}

// Path: profile.settings
class _TranslationsProfileSettingsCs extends TranslationsProfileSettingsEn {
	_TranslationsProfileSettingsCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get language => 'Jazyk';
	@override String get czech => 'Čeština';
	@override String get notifications => 'Oznámení';
	@override String get english => 'Angličtina';
	@override String get spanish => 'Španělština';
}

// Path: profile.support
class _TranslationsProfileSupportCs extends TranslationsProfileSupportEn {
	_TranslationsProfileSupportCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get contactAuthor => 'Napsat autorovi';
	@override String get rateApp => 'Ohodnotit aplikaci';
}

// Path: profile.appInfo
class _TranslationsProfileAppInfoCs extends TranslationsProfileAppInfoEn {
	_TranslationsProfileAppInfoCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get version => 'Verze aplikace';
	@override String get termsOfUse => 'Podmínky použití';
	@override String get privacy => 'Ochrana soukromí';
}

// Path: profile.danger
class _TranslationsProfileDangerCs extends TranslationsProfileDangerEn {
	_TranslationsProfileDangerCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get logout => 'Odhlásit se';
	@override String get logoutConfirmBody => 'Opravdu se chcete odhlásit?';
	@override String get deleteAccount => 'Smazat účet';
}

// Path: profile.changePassword
class _TranslationsProfileChangePasswordCs extends TranslationsProfileChangePasswordEn {
	_TranslationsProfileChangePasswordCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
	@override String get success => 'Heslo bylo úspěšně změněno.';
	@override String get error => 'Nepodařilo se změnit heslo. Zkuste to prosím znovu.';
	@override String get incorrectPassword => 'Současné heslo je nesprávné.';
}

// Path: profile.editProfile
class _TranslationsProfileEditProfileCs extends TranslationsProfileEditProfileEn {
	_TranslationsProfileEditProfileCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Upravit profil';
	@override late final _TranslationsProfileEditProfileSectionsCs sections = _TranslationsProfileEditProfileSectionsCs._(_root);
	@override String get changePhoto => 'Změnit fotku';
	@override String get bio => 'Popis';
	@override String get bioHint => 'Napište něco o sobě...';
	@override String get selectDanceStyles => 'Vyberte své oblíbené tanční styly';
	@override String get yourLevel => 'Vaše taneční úroveň';
	@override String get instagram => 'Instagram';
	@override String get instagramHint => '@vase_uzivatelske_jmeno';
	@override String get facebook => 'Facebook';
	@override String get facebookHint => 'facebook.com/vase.jmeno';
	@override late final _TranslationsProfileEditProfileNotificationsCs notifications = _TranslationsProfileEditProfileNotificationsCs._(_root);
	@override late final _TranslationsProfileEditProfileNotificationSubtitlesCs notificationSubtitles = _TranslationsProfileEditProfileNotificationSubtitlesCs._(_root);
	@override String get save => 'Uložit změny';
	@override String get updateSuccess => 'Profil byl úspěšně aktualizován.';
	@override String get updateError => 'Nepodařilo se aktualizovat profil. Zkuste to prosím znovu.';
	@override late final _TranslationsProfileEditProfileExperienceLevelsCs experienceLevels = _TranslationsProfileEditProfileExperienceLevelsCs._(_root);
	@override late final _TranslationsProfileEditProfileAvatarCs avatar = _TranslationsProfileEditProfileAvatarCs._(_root);
}

// Path: contact.form
class _TranslationsContactFormCs extends TranslationsContactFormEn {
	_TranslationsContactFormCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
	@override String get success => 'Vaše zpráva byla odeslána. Brzy se vám ozveme!';
	@override String get error => 'Nepodařilo se odeslat zprávu. Zkuste to prosím znovu.';
	@override String get typeRequired => 'Vyberte prosím typ zprávy';
	@override String get titleRequired => 'Zadejte prosím název zprávy';
	@override String get messageRequired => 'Zadejte prosím zprávu';
	@override String get emailRequired => 'Zadejte prosím svůj e-mail pro odpověď';
}

// Path: contact.deviceInfoLabels
class _TranslationsContactDeviceInfoLabelsCs extends TranslationsContactDeviceInfoLabelsEn {
	_TranslationsContactDeviceInfoLabelsCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get app => 'Aplikace:';
	@override String get device => 'Zařízení:';
	@override String get os => 'Systém:';
}

// Path: courses.detail.levels
class _TranslationsCoursesDetailLevelsCs extends TranslationsCoursesDetailLevelsEn {
	_TranslationsCoursesDetailLevelsCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get beginner => 'Začátečník';
	@override String get intermediate => 'Mírně pokročilý';
	@override String get advanced => 'Pokročilý';
	@override String get allLevels => 'Všechny úrovně';
}

// Path: courses.detail.days
class _TranslationsCoursesDetailDaysCs extends TranslationsCoursesDetailDaysEn {
	_TranslationsCoursesDetailDaysCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

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
class _TranslationsProfileEditProfileSectionsCs extends TranslationsProfileEditProfileSectionsEn {
	_TranslationsProfileEditProfileSectionsCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get personalInfo => 'Osobní údaje';
	@override String get aboutMe => 'O mně';
	@override String get favoriteDances => 'Oblíbené tance';
	@override String get level => 'Úroveň';
	@override String get socialNetworks => 'Sociální sítě';
	@override String get notifications => 'Oznámení';
}

// Path: profile.editProfile.notifications
class _TranslationsProfileEditProfileNotificationsCs extends TranslationsProfileEditProfileNotificationsEn {
	_TranslationsProfileEditProfileNotificationsCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get newEvents => 'Nové akce';
	@override String get eventReminders => 'Připomínky akcí';
	@override String get marketing => 'Marketingové zprávy';
}

// Path: profile.editProfile.notificationSubtitles
class _TranslationsProfileEditProfileNotificationSubtitlesCs extends TranslationsProfileEditProfileNotificationSubtitlesEn {
	_TranslationsProfileEditProfileNotificationSubtitlesCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get newEvents => 'Dostávejte upozornění o nových akcích ve vašem okolí';
	@override String get eventReminders => 'Připomínky před vašimi uloženými akcemi';
	@override String get marketing => 'Propagační zprávy a nabídky';
}

// Path: profile.editProfile.experienceLevels
class _TranslationsProfileEditProfileExperienceLevelsCs extends TranslationsProfileEditProfileExperienceLevelsEn {
	_TranslationsProfileEditProfileExperienceLevelsCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get beginner => 'Začátečník';
	@override String get slightlyAdvanced => 'Mírně pokročilý';
	@override String get advanced => 'Pokročilý';
	@override String get expert => 'Expert';
}

// Path: profile.editProfile.avatar
class _TranslationsProfileEditProfileAvatarCs extends TranslationsProfileEditProfileAvatarEn {
	_TranslationsProfileEditProfileAvatarCs._(TranslationsCs root) : this._root = root, super.internal(root);

	final TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get sourceTitle => 'Změnit profilovou fotku';
	@override String get takePhoto => 'Pořídit fotografii';
	@override String get chooseFromGallery => 'Vybrat z galerie';
	@override String get uploadError => 'Nepodařilo se nahrát fotografii. Zkuste to prosím znovu.';
	@override String get linkError => 'Nepodařilo se aktualizovat profilovou fotku. Zkuste to prosím znovu.';
	@override String get permissionRequired => 'Pro změnu fotky je vyžadováno oprávnění ke kameře nebo galerii.';
	@override String get permissionDeniedTitle => 'Vyžadováno oprávnění';
	@override String get permissionDeniedMessage => 'Přístup jste trvale zamítli. Pro změnu profilové fotky jej prosím povolte v nastavení zařízení.';
	@override String get openSettings => 'Otevřít nastavení';
}

/// The flat map containing all translations for locale <cs>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsCs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.appName' => 'Dancee',
			'common.showAll' => 'Zobrazit vše',
			'common.months.jan' => 'Led',
			'common.months.feb' => 'Úno',
			'common.months.mar' => 'Bře',
			'common.months.apr' => 'Dub',
			'common.months.may' => 'Kvě',
			'common.months.jun' => 'Čvn',
			'common.months.jul' => 'Čvc',
			'common.months.aug' => 'Srp',
			'common.months.sep' => 'Zář',
			'common.months.oct' => 'Říj',
			'common.months.nov' => 'Lis',
			'common.months.dec' => 'Pro',
			'common.date' => 'Datum',
			'common.save' => 'Uložit',
			'common.share' => 'Sdílet',
			'common.map' => 'Mapa',
			'common.skip' => 'Přeskočit',
			'common.continue_' => 'Pokračovat',
			'common.back' => 'Zpět',
			'common.finish' => 'Dokončit',
			'common.cancel' => 'Zrušit',
			'common.allow' => 'Povolit',
			'common.support' => 'Podpora',
			'common.faq' => 'FAQ',
			'common.clear' => 'Vymazat',
			'common.clearFilters' => 'Vymazat filtry',
			'common.current' => 'Aktuální',
			'common.saveChanges' => 'Uložit změny',
			'common.loading' => 'Načítání...',
			'common.retry' => 'Zkusit znovu',
			'common.logoutSuccess' => 'Byli jste úspěšně odhlášeni.',
			'common.from' => ({required Object time}) => 'Od ${time}',
			'common.form.email' => 'E-mail',
			'common.form.emailHint' => 'tvuj@email.cz',
			'common.form.password' => 'Heslo',
			'common.form.passwordPlaceholder' => '••••••••',
			'common.form.confirmPassword' => 'Potvrzení hesla',
			'common.form.firstName' => 'Jméno',
			'common.form.firstNameHint' => 'Tvoje jméno',
			'common.form.lastName' => 'Příjmení',
			'common.form.lastNameHint' => 'Tvoje příjmení',
			'common.form.city' => 'Město',
			'common.form.phone' => 'Telefon',
			'common.form.fullName' => 'Jméno a příjmení',
			'nav.events' => 'Události',
			'nav.courses' => 'Kurzy',
			'nav.saved' => 'Uložené',
			'nav.profile' => 'Profil',
			'nav.home' => 'Domů',
			'nav.search' => 'Hledat',
			'auth.tagline' => 'Objevuj taneční svět',
			'auth.orContinueWith' => 'nebo pokračuj s',
			'auth.continueWithGoogle' => 'Pokračovat s Google',
			'auth.continueWithApple' => 'Pokračovat s Apple',
			'auth.termsPrefix' => 'Pokračováním souhlasíš s našimi ',
			'auth.termsOfUse' => 'Podmínkami používání',
			'auth.and' => ' a ',
			'auth.privacyPolicy' => 'Zásadami ochrany osobních údajů',
			'auth.agreeWith' => 'Souhlasím s ',
			'auth.orRegisterWith' => 'nebo se zaregistruj s',
			'auth.login.title' => 'Vítej zpět!',
			'auth.login.subtitle' => 'Přihlaš se a pokračuj v objevování tanečních akcí',
			'auth.login.stayLoggedIn' => 'Zůstat přihlášen',
			'auth.login.forgotPassword' => 'Zapomenuté heslo?',
			'auth.login.submit' => 'Přihlásit se',
			'auth.login.noAccount' => 'Nemáš ještě účet?',
			'auth.login.register' => 'Zaregistruj se',
			'auth.register.title' => 'Vytvoř si účet',
			'auth.register.subtitle' => 'Zaregistruj se a začni objevovat taneční akce',
			'auth.register.passwordsMatch' => 'Hesla se shodují',
			'auth.register.passwordsMismatch' => 'Hesla se neshodují',
			'auth.register.newsletter' => 'Chci dostávat novinky o tanečních akcích',
			'auth.register.submit' => 'Vytvořit účet',
			'auth.register.hasAccount' => 'Už máš účet?',
			'auth.register.login' => 'Přihlaš se',
			'auth.forgotPassword.title' => 'Zapomenuté heslo?',
			'auth.forgotPassword.subtitle' => 'Zadej svůj e-mail a pošleme ti odkaz pro obnovení hesla',
			'auth.forgotPassword.submit' => 'Odeslat odkaz',
			'auth.forgotPassword.checkInbox' => 'Zkontroluj svou e-mailovou schránku',
			'auth.forgotPassword.checkInboxDetail' => 'Po odeslání obdržíš e-mail s odkazem pro obnovení hesla. Odkaz je platný 24 hodin.',
			'auth.forgotPassword.rememberPassword' => 'Vzpomněl sis na heslo?',
			'auth.forgotPassword.login' => 'Přihlásit se',
			'auth.forgotPassword.needHelp' => 'Potřebuješ pomoc?',
			'auth.passwordStrength.weak' => 'Slabé heslo',
			'auth.passwordStrength.medium' => 'Středně silné',
			'auth.passwordStrength.strong' => 'Silné heslo',
			'auth.passwordStrength.veryStrong' => 'Velmi silné',
			'auth.passwordStrength.hint' => 'Alespoň 8 znaků',
			'auth.errors.invalidCredential' => 'Neplatný e-mail nebo heslo',
			'auth.errors.userDisabled' => 'Tento účet byl deaktivován',
			'auth.errors.emailAlreadyInUse' => 'Účet s tímto e-mailem již existuje',
			'auth.errors.weakPassword' => 'Heslo je příliš slabé',
			'auth.errors.tooManyRequests' => 'Příliš mnoho pokusů. Zkuste to prosím později',
			'auth.errors.networkError' => 'Chyba sítě. Zkontrolujte své připojení',
			'auth.errors.generic' => 'Došlo k chybě. Zkuste to prosím znovu',
			'auth.emailVerification.title' => 'Ověřte svůj e-mail',
			'auth.emailVerification.subtitle' => ({required Object email}) => 'Zaslali jsme ověřovací e-mail na adresu ${email}',
			'auth.emailVerification.resend' => 'Znovu odeslat ověřovací e-mail',
			'auth.emailVerification.resendConfirmed' => 'Ověřovací e-mail odeslán. Zkontrolujte prosím svou doručenou poštu.',
			'auth.emailVerification.checkVerified' => 'Ověřil jsem svůj e-mail',
			'auth.emailVerification.notVerifiedYet' => 'E-mail ještě nebyl ověřen. Zkontrolujte prosím svou doručenou poštu.',
			'auth.emailVerification.signOut' => 'Odhlásit se',
			'auth.deleteAccount.confirmTitle' => 'Smazat účet?',
			'auth.deleteAccount.confirmBody' => 'Tato akce trvale odstraní všechna vaše data. Tuto akci nelze vrátit zpět.',
			'auth.deleteAccount.reauthPrompt' => 'Pro pokračování potvrďte své heslo',
			'auth.deleteAccount.success' => 'Váš účet byl smazán',
			'auth.deleteAccount.error' => 'Nepodařilo se smazat účet. Zkuste to prosím znovu.',
			'api.errors.connectionTimeout' => 'Vypršel časový limit připojení. Zkontrolujte síťové připojení.',
			'api.errors.receiveTimeout' => 'Server reagoval příliš pomalu. Zkuste to prosím znovu.',
			'api.errors.sendTimeout' => 'Vypršel časový limit odesílání. Zkuste to prosím znovu.',
			'api.errors.noConnection' => 'Žádné internetové připojení. Zkontrolujte své připojení.',
			'api.errors.requestCancelled' => 'Požadavek byl zrušen.',
			'api.errors.badRequest' => 'Chybný požadavek. Zkuste to prosím znovu.',
			'api.errors.unauthorized' => 'Relace vypršela. Přihlaste se prosím znovu.',
			'api.errors.forbidden' => 'Přístup odepřen. Kontaktujte prosím podporu.',
			'api.errors.notFound' => 'Požadovaný zdroj nebyl nalezen.',
			'api.errors.conflict' => 'Došlo ke konfliktu. Zkuste to prosím znovu.',
			'api.errors.internalServerError' => 'Chyba serveru. Zkuste to prosím později.',
			'api.errors.badGateway' => 'Server je dočasně nedostupný. Zkuste to prosím později.',
			'api.errors.serviceUnavailable' => 'Služba není dostupná. Zkuste to prosím později.',
			'api.errors.clientError' => 'Došlo k chybě. Zkuste to prosím znovu.',
			'api.errors.serverError' => 'Chyba serveru. Zkuste to prosím později.',
			'api.errors.generic' => 'Došlo k neočekávané chybě. Zkuste to prosím znovu.',
			'validation.emailRequired' => 'Zadejte prosím svou e-mailovou adresu',
			'validation.invalidEmail' => 'Zadejte prosím platnou e-mailovou adresu',
			'validation.fieldRequired' => 'Toto pole je povinné',
			'validation.passwordTooShort' => 'Heslo musí mít alespoň 8 znaků',
			'validation.passwordsDoNotMatch' => 'Hesla se neshodují',
			'onboarding.step1.title' => 'Jaké tance tě baví?',
			'onboarding.step1.subtitle' => 'Vyber své oblíbené taneční styly, abychom ti mohli nabídnout relevantní akce',
			'onboarding.step2.title' => 'Jaká je tvoje úroveň?',
			'onboarding.step2.subtitle' => 'Pomůže nám to doporučit ti vhodné akce a kurzy',
			'onboarding.step3.title' => 'Kde se nacházíš?',
			'onboarding.step3.subtitle' => 'Najdeme pro tebe nejbližší taneční akce ve tvém okolí',
			'onboarding.step3.radius10km' => '10 km',
			'onboarding.step3.radius25km' => '25 km',
			'onboarding.step3.radius50km' => '50 km',
			'onboarding.step3.radiusAll' => 'Celá republika',
			'onboarding.step3.cityHint' => 'Např. Praha, Brno...',
			'onboarding.step3.searchRadius' => 'Vyhledat akce v okruhu',
			'onboarding.step3.useCurrentLocation' => 'Použít aktuální polohu',
			'events.featuredEvents' => 'Doporučené akce',
			'events.upcomingEvents' => 'Nadcházející akce',
			'events.noEventsFound' => 'Žádné akce nenalezeny',
			'events.noEventsForFilter' => 'Pro zvolené filtry nebyly nalezeny žádné akce. Zkuste upravit výběr nebo vymazat filtry.',
			'events.danceStyles' => 'Taneční styly',
			'events.danceStylesLabel' => 'TANEČNÍ STYLY',
			'events.location' => 'Lokalita',
			'events.detail.header' => 'Detail akce',
			'events.detail.description' => 'Popis akce',
			'events.detail.additionalInfo' => 'Dodatečné informace',
			'events.detail.admission' => 'Vstupné',
			'events.detail.dresscode' => 'Dresscode',
			'events.detail.buyTickets' => 'Koupit vstupenky',
			'events.detail.originalSource' => 'Původní zdroj',
			'events.detail.program' => 'Program akce',
			'events.detail.notFound' => 'Akce nenalezena',
			'events.detail.lector' => ({required Object name}) => 'Lektor: ${name}',
			'events.detail.dj' => ({required Object name}) => 'DJ: ${name}',
			'events.filter.selectedCount' => ({required Object count}) => '${count} vybraných',
			'events.filter.selectedStyles' => 'VYBRANÉ STYLY',
			'events.filter.apply' => 'Použít filtr',
			'events.filter.applyCount' => ({required Object count}) => 'Použít filtr (${count})',
			'events.filter.selectLocation' => 'Vybrat lokalitu',
			'events.filter.searchCityHint' => 'Hledat město nebo oblast...',
			'events.filter.useMyLocation' => 'Použít moji polohu',
			'events.filter.useMyLocationSubtitle' => 'Automaticky najde akce ve vašem okolí',
			'events.filter.popularCities' => 'Oblíbená města',
			'events.filter.allCities' => 'Všechna města',
			'events.filter.selectedRegions' => 'VYBRANÉ OBLASTI',
			'events.filter.noResults' => 'Žádné výsledky',
			'events.filter.abroad' => 'Zahraničí',
			'events.filter.unknownRegion' => 'Neznámá lokalita',
			'events.filters.today' => 'Dnes',
			'events.filters.thisWeek' => 'Tento týden',
			'events.filters.thisMonth' => 'Tento měsíc',
			'events.filters.thisWeekend' => 'Tento víkend',
			'events.filters.all' => 'Vše',
			'events.filters.evening' => 'Večerní',
			'events.filters.weekend' => 'Víkendové',
			'events.filters.multiDay' => 'Několikadenní',
			'events.edit.header' => 'Upravit akci',
			'events.edit.submit' => 'Uložit změny',
			'events.edit.success' => 'Akce byla úspěšně aktualizována',
			'events.edit.error' => 'Nepodařilo se aktualizovat akci',
			'courses.title' => 'Taneční kurzy',
			'courses.subtitle' => 'Najdi svůj kurz',
			'courses.featuredCourses' => 'Doporučené kurzy',
			'courses.allCourses' => 'Všechny kurzy',
			'courses.noCoursesFound' => 'Žádné kurzy nenalezeny',
			'courses.noCoursesForFilter' => 'Pro zvolené filtry nebyly nalezeny žádné kurzy. Zkuste upravit výběr nebo vymazat filtry.',
			'courses.courseTypes.all' => 'Vše',
			'courses.courseTypes.workshop' => 'Workshop',
			'courses.courseTypes.regular' => 'Pravidelný kurz',
			'courses.detail.header' => 'Detail kurzu',
			'courses.detail.notFound' => 'Kurz nenalezen',
			'courses.detail.description' => 'Popis kurzu',
			'courses.detail.details' => 'Podrobnosti kurzu',
			'courses.detail.whatYouLearn' => 'Co se naučíte',
			'courses.detail.aboutInstructor' => 'O lektorovi',
			'courses.detail.shareCourse' => 'Sdílet kurz',
			'courses.detail.coursePrice' => 'Cena kurzu',
			'courses.detail.priceUnknown' => 'Cena neuvedena',
			'courses.detail.availableSpots' => 'Volná místa',
			'courses.detail.register' => 'Registrovat se na kurz',
			'courses.detail.startDate' => 'Datum začátku',
			'courses.detail.endDate' => 'Datum konce',
			'courses.detail.day' => 'Den',
			'courses.detail.time' => 'Čas',
			'courses.detail.lessons' => 'Lekce',
			'courses.detail.duration' => 'Délka',
			'courses.detail.level' => 'Úroveň',
			'courses.detail.levels.beginner' => 'Začátečník',
			'courses.detail.levels.intermediate' => 'Mírně pokročilý',
			'courses.detail.levels.advanced' => 'Pokročilý',
			'courses.detail.levels.allLevels' => 'Všechny úrovně',
			'courses.detail.days.monday' => 'Pondělí',
			'courses.detail.days.tuesday' => 'Úterý',
			'courses.detail.days.wednesday' => 'Středa',
			'courses.detail.days.thursday' => 'Čtvrtek',
			'courses.detail.days.friday' => 'Pátek',
			'courses.detail.days.saturday' => 'Sobota',
			'courses.detail.days.sunday' => 'Neděle',
			'courses.detail.lessonsCount' => ({required Object count}) => '${count} lekcí',
			'courses.detail.durationMin' => ({required Object count}) => '${count} min',
			'courses.detail.participantsCount' => ({required Object current, required Object max}) => '${current} / ${max} účastníků',
			'courses.detail.spotsAvailable' => ({required Object count}) => '${count} volných míst',
			'courses.edit.header' => 'Upravit kurz',
			'courses.edit.submit' => 'Uložit změny',
			'courses.edit.success' => 'Kurz byl úspěšně aktualizován',
			'courses.edit.error' => 'Nepodařilo se aktualizovat kurz',
			'profile.title' => 'Profil',
			'profile.loading' => 'Načítání profilu...',
			'profile.error' => 'Nepodařilo se načíst profil. Zkuste to prosím znovu.',
			'profile.legalPage.loading' => 'Načítání obsahu...',
			'profile.legalPage.error' => 'Nepodařilo se načíst obsah. Zkuste to prosím znovu.',
			'profile.legalPage.retry' => 'Zkusit znovu',
			'profile.sections.account' => 'Účet',
			'profile.sections.settings' => 'Nastavení',
			'profile.sections.support' => 'Podpora',
			'profile.sections.appInfo' => 'O aplikaci',
			'profile.sections.dangerZone' => 'Nebezpečná zóna',
			'profile.account.editProfile' => 'Upravit profil',
			'profile.account.changePassword' => 'Změnit heslo',
			'profile.settings.language' => 'Jazyk',
			'profile.settings.czech' => 'Čeština',
			'profile.settings.notifications' => 'Oznámení',
			'profile.settings.english' => 'Angličtina',
			'profile.settings.spanish' => 'Španělština',
			'profile.support.contactAuthor' => 'Napsat autorovi',
			'profile.support.rateApp' => 'Ohodnotit aplikaci',
			'profile.appInfo.version' => 'Verze aplikace',
			'profile.appInfo.termsOfUse' => 'Podmínky použití',
			'profile.appInfo.privacy' => 'Ochrana soukromí',
			'profile.danger.logout' => 'Odhlásit se',
			'profile.danger.logoutConfirmBody' => 'Opravdu se chcete odhlásit?',
			'profile.danger.deleteAccount' => 'Smazat účet',
			'profile.changePassword.title' => 'Změnit heslo',
			'profile.changePassword.secureAccount' => 'Zabezpečte svůj účet',
			'profile.changePassword.secureAccountDetail' => 'Silné heslo musí obsahovat alespoň 8 znaků, velká a malá písmena, čísla a speciální znaky.',
			'profile.changePassword.currentPassword' => 'Současné heslo',
			'profile.changePassword.currentPasswordHint' => 'Zadejte současné heslo',
			'profile.changePassword.newPassword' => 'Nové heslo',
			'profile.changePassword.newPasswordHint' => 'Zadejte nové heslo',
			'profile.changePassword.confirmPassword' => 'Potvrdit nové heslo',
			'profile.changePassword.confirmPasswordHint' => 'Zadejte nové heslo znovu',
			'profile.changePassword.save' => 'Uložit nové heslo',
			'profile.changePassword.requirements' => 'POŽADAVKY NA HESLO',
			'profile.changePassword.req8chars' => 'Minimálně 8 znaků',
			'profile.changePassword.reqUppercase' => 'Alespoň jedno velké písmeno (A-Z)',
			'profile.changePassword.reqLowercase' => 'Alespoň jedno malé písmeno (a-z)',
			'profile.changePassword.reqNumber' => 'Alespoň jedno číslo (0-9)',
			'profile.changePassword.reqSpecial' => 'Alespoň jeden speciální znak (!@#\$%^&*)',
			'profile.changePassword.forgotPassword' => 'Zapomněli jste heslo?',
			'profile.changePassword.strengthVeryWeak' => 'Síla hesla: Velmi slabé',
			'profile.changePassword.strengthWeak' => 'Síla hesla: Slabé',
			'profile.changePassword.strengthMedium' => 'Síla hesla: Střední',
			'profile.changePassword.strengthStrong' => 'Síla hesla: Silné',
			'profile.changePassword.success' => 'Heslo bylo úspěšně změněno.',
			'profile.changePassword.error' => 'Nepodařilo se změnit heslo. Zkuste to prosím znovu.',
			'profile.changePassword.incorrectPassword' => 'Současné heslo je nesprávné.',
			'profile.editProfile.title' => 'Upravit profil',
			'profile.editProfile.sections.personalInfo' => 'Osobní údaje',
			'profile.editProfile.sections.aboutMe' => 'O mně',
			'profile.editProfile.sections.favoriteDances' => 'Oblíbené tance',
			'profile.editProfile.sections.level' => 'Úroveň',
			'profile.editProfile.sections.socialNetworks' => 'Sociální sítě',
			'profile.editProfile.sections.notifications' => 'Oznámení',
			'profile.editProfile.changePhoto' => 'Změnit fotku',
			'profile.editProfile.bio' => 'Popis',
			'profile.editProfile.bioHint' => 'Napište něco o sobě...',
			'profile.editProfile.selectDanceStyles' => 'Vyberte své oblíbené tanční styly',
			'profile.editProfile.yourLevel' => 'Vaše taneční úroveň',
			'profile.editProfile.instagram' => 'Instagram',
			'profile.editProfile.instagramHint' => '@vase_uzivatelske_jmeno',
			'profile.editProfile.facebook' => 'Facebook',
			'profile.editProfile.facebookHint' => 'facebook.com/vase.jmeno',
			'profile.editProfile.notifications.newEvents' => 'Nové akce',
			'profile.editProfile.notifications.eventReminders' => 'Připomínky akcí',
			'profile.editProfile.notifications.marketing' => 'Marketingové zprávy',
			'profile.editProfile.notificationSubtitles.newEvents' => 'Dostávejte upozornění o nových akcích ve vašem okolí',
			'profile.editProfile.notificationSubtitles.eventReminders' => 'Připomínky před vašimi uloženými akcemi',
			'profile.editProfile.notificationSubtitles.marketing' => 'Propagační zprávy a nabídky',
			'profile.editProfile.save' => 'Uložit změny',
			'profile.editProfile.updateSuccess' => 'Profil byl úspěšně aktualizován.',
			'profile.editProfile.updateError' => 'Nepodařilo se aktualizovat profil. Zkuste to prosím znovu.',
			'profile.editProfile.experienceLevels.beginner' => 'Začátečník',
			'profile.editProfile.experienceLevels.slightlyAdvanced' => 'Mírně pokročilý',
			'profile.editProfile.experienceLevels.advanced' => 'Pokročilý',
			'profile.editProfile.experienceLevels.expert' => 'Expert',
			'profile.editProfile.avatar.sourceTitle' => 'Změnit profilovou fotku',
			'profile.editProfile.avatar.takePhoto' => 'Pořídit fotografii',
			'profile.editProfile.avatar.chooseFromGallery' => 'Vybrat z galerie',
			'profile.editProfile.avatar.uploadError' => 'Nepodařilo se nahrát fotografii. Zkuste to prosím znovu.',
			'profile.editProfile.avatar.linkError' => 'Nepodařilo se aktualizovat profilovou fotku. Zkuste to prosím znovu.',
			'profile.editProfile.avatar.permissionRequired' => 'Pro změnu fotky je vyžadováno oprávnění ke kameře nebo galerii.',
			'profile.editProfile.avatar.permissionDeniedTitle' => 'Vyžadováno oprávnění',
			'profile.editProfile.avatar.permissionDeniedMessage' => 'Přístup jste trvale zamítli. Pro změnu profilové fotky jej prosím povolte v nastavení zařízení.',
			'profile.editProfile.avatar.openSettings' => 'Otevřít nastavení',
			'premium.title' => 'Dancee Premium',
			'premium.bannerSubtitle' => 'Odemkněte všechny funkce',
			'premium.heroTitle' => 'Odemkněte plný potenciál',
			'premium.heroSubtitle' => 'Získejte přístup ke všem prémiové funkcím a zlepšete své taneční zážitky',
			'premium.featuresTitle' => 'Co získáte s Premium',
			'premium.testimonialsTitle' => 'Co říkají naši uživatelé',
			'premium.faqTitle' => 'Časté otázky',
			'premium.ctaTitle' => 'Připraveni začít?',
			'premium.ctaSubtitle' => 'Připojte se k tisícům spokojených tanečníků',
			'premium.ctaButton' => 'Získat Premium nyní',
			'premium.ctaNote' => '7 dní zdarma · Zrušte kdykoliv',
			'saved.title' => 'Uložené akce',
			'saved.subtitle' => 'Tvoje oblíbené akce',
			'saved.emptyTitle' => 'Žádné uložené akce',
			'saved.emptySubtitle' => 'Akce, které si uložíš, se zobrazí zde',
			'authGate.title' => 'Vyžaduje přihlášení',
			'authGate.message' => 'Vytvořte si účet nebo se přihlaste pro přístup k uloženým akcím a profilu.',
			'authGate.actionMessage' => 'Pro použití této funkce se musíte přihlásit.',
			'authGate.login' => 'Přihlásit se',
			'authGate.register' => 'Vytvořit účet',
			'authGate.logoutTitle' => 'Odhlášení proběhlo úspěšně',
			'authGate.logoutMessage' => 'Můžete se kdykoli znovu přihlásit.',
			'contact.teamName' => 'Tým Dancee',
			'contact.description' => 'Rádi si přečteme vaše zpětné vazby...',
			'contact.responseTime' => 'Doba odezvy',
			'contact.responseTimeDetail' => 'Obvykle odpovídáme do 24 hodin v pracovní dny. Děkujeme za trpělivost!',
			'contact.deviceInfo' => 'Informace o zařízení',
			'contact.autoAttached' => 'Automaticky přiloženo',
			'contact.form.subject' => 'Předmět zprávy',
			'contact.form.feedback' => 'Zpětná vazba',
			'contact.form.reportBug' => 'Nahlásit problém',
			'contact.form.featureRequest' => 'Návrh na vylepšení',
			'contact.form.other' => 'Ostatní',
			'contact.form.title' => 'Název zprávy',
			'contact.form.titleHint' => 'Stručně popište váš problém nebo návrh',
			'contact.form.message' => 'Zpráva',
			'contact.form.messageHint' => 'Podrobně popište váš problém...',
			'contact.form.replyEmail' => 'Váš e-mail pro odpověď',
			'contact.form.sending' => 'Odesílání...',
			'contact.form.sent' => 'Odesláno!',
			'contact.form.submit' => 'Odeslat zprávu',
			'contact.form.success' => 'Vaše zpráva byla odeslána. Brzy se vám ozveme!',
			'contact.form.error' => 'Nepodařilo se odeslat zprávu. Zkuste to prosím znovu.',
			'contact.form.typeRequired' => 'Vyberte prosím typ zprávy',
			'contact.form.titleRequired' => 'Zadejte prosím název zprávy',
			'contact.form.messageRequired' => 'Zadejte prosím zprávu',
			'contact.form.emailRequired' => 'Zadejte prosím svůj e-mail pro odpověď',
			'contact.deviceInfoLabels.app' => 'Aplikace:',
			'contact.deviceInfoLabels.device' => 'Zařízení:',
			'contact.deviceInfoLabels.os' => 'Systém:',
			_ => null,
		};
	}
}
