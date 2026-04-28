# Firebase Authentication Setup Guide

This guide covers the complete setup of Firebase Authentication for the Dancee App (`dancee_app2`), including Email/Password, Google Sign-In, and Apple Sign-In.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Firebase Project Setup](#firebase-project-setup)
3. [Enable Authentication Providers](#enable-authentication-providers)
4. [FlutterFire CLI Configuration](#flutterfire-cli-configuration)
5. [Platform-Specific Configuration](#platform-specific-configuration)
6. [Google Sign-In Configuration](#google-sign-in-configuration)
7. [Apple Sign-In Configuration](#apple-sign-in-configuration)
8. [Directus CMS Configuration](#directus-cms-configuration)
9. [Environment Variables and config.dart](#environment-variables-and-configdart)
10. [Verification](#verification)

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and on your PATH
- [Firebase CLI](https://firebase.google.com/docs/cli) installed: `npm install -g firebase-tools`
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) installed: `dart pub global activate flutterfire_cli`
- A Google account with access to [Firebase Console](https://console.firebase.google.com)
- (For Apple Sign-In) An Apple Developer account with access to [Apple Developer Portal](https://developer.apple.com)

---

## Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com) and click **Add project**.
2. Enter a project name (e.g. `dancee-app`), choose your analytics settings, and click **Create project**.
3. Once the project is created, click **Continue** to open the project dashboard.
4. Register your app platforms:
   - **Android**: Click the Android icon, enter the package name from `android/app/build.gradle` (e.g. `com.example.dancee_app2`), and download `google-services.json`.
   - **iOS**: Click the iOS icon, enter the bundle ID from `ios/Runner.xcodeproj` (e.g. `com.example.danceeApp2`), and download `GoogleService-Info.plist`.
   - **Web**: Click the Web icon, register the app, and note the Firebase web config object (used by FlutterFire CLI).

---

## Enable Authentication Providers

In the Firebase Console, navigate to **Authentication > Sign-in method** and enable the following providers:

### Email/Password

1. Click **Email/Password** in the provider list.
2. Toggle **Enable** on.
3. Optionally enable **Email link (passwordless sign-in)** if needed.
4. Click **Save**.

### Google

1. Click **Google** in the provider list.
2. Toggle **Enable** on.
3. Enter a **Project support email**.
4. Click **Save**.

### Apple

1. Click **Apple** in the provider list.
2. Toggle **Enable** on.
3. Enter the **Services ID** (created in the Apple Developer Portal — see [Apple Sign-In Configuration](#apple-sign-in-configuration)).
4. Enter the **Apple Team ID**, **Key ID**, and upload the **private key** (`.p8` file) from your Apple Developer account.
5. Under **Authorized domains**, confirm your app's domain is listed (Firebase adds the default domain automatically).
6. Note the **callback URL** shown (format: `https://YOUR-PROJECT.firebaseapp.com/__/auth/handler`) — you will need it when configuring the Apple Service ID.
7. Click **Save**.

---

## FlutterFire CLI Configuration

The FlutterFire CLI generates `lib/firebase_options.dart` containing your Firebase project configuration for all platforms. This file is safe to commit (it contains only project IDs and API keys, not secrets).

1. Log in to Firebase:
   ```bash
   firebase login
   ```

2. From the `frontend/dancee_app2/` directory, run:
   ```bash
   flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
   ```
   Replace `YOUR_FIREBASE_PROJECT_ID` with your project ID (visible in the Firebase Console under **Project settings**).

3. Select the platforms you want to support (Android, iOS, Web) when prompted.

4. The CLI generates `lib/firebase_options.dart`. Verify it exists:
   ```bash
   ls lib/firebase_options.dart
   ```

5. **Do not edit** `firebase_options.dart` manually. Re-run `flutterfire configure` if your Firebase project settings change.

---

## Platform-Specific Configuration

### Android

1. Copy `google-services.json` (downloaded from Firebase Console) into:
   ```
   android/app/google-services.json
   ```

2. Verify that `android/app/build.gradle` applies the Google services plugin:
   ```groovy
   apply plugin: 'com.google.gms.google-services'
   ```

3. Verify that `android/build.gradle` includes the Google services classpath:
   ```groovy
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```

4. `google-services.json` is listed in `.gitignore` and must never be committed.

### iOS

1. Copy `GoogleService-Info.plist` (downloaded from Firebase Console) into:
   ```
   ios/Runner/GoogleService-Info.plist
   ```

2. Open `ios/Runner.xcworkspace` in Xcode and verify the file appears under the **Runner** target in the project navigator.

3. `GoogleService-Info.plist` is listed in `.gitignore` and must never be committed.

### Web

Web configuration is handled automatically by `firebase_options.dart` generated by the FlutterFire CLI. No additional files are required for Web.

---

## Google Sign-In Configuration

Google Sign-In requires OAuth 2.0 client IDs configured in [Google Cloud Console](https://console.cloud.google.com).

### Android

1. In [Google Cloud Console](https://console.cloud.google.com), navigate to **APIs & Services > Credentials**.
2. Click **Create credentials > OAuth client ID**.
3. Select **Android** as the application type.
4. Enter the package name (e.g. `com.example.dancee_app2`).
5. Enter the **SHA-1 certificate fingerprint** of your signing key:
   - Debug keystore: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android`
   - Release keystore: use your release keystore and alias.
6. Click **Create**. The client ID is embedded in `google-services.json` — no further action needed.

### iOS

1. In Google Cloud Console, click **Create credentials > OAuth client ID**.
2. Select **iOS** as the application type.
3. Enter your iOS bundle ID (e.g. `com.example.danceeApp2`).
4. Click **Create** and download the `GoogleService-Info.plist` — the `CLIENT_ID` field contains the OAuth client ID.
5. In Xcode, open `ios/Runner/Info.plist` and verify that the `CFBundleURLTypes` array contains a URL scheme matching your reversed client ID (e.g. `com.googleusercontent.apps.YOUR-CLIENT-ID`). The FlutterFire CLI typically adds this automatically.

### Web

1. In Google Cloud Console, click **Create credentials > OAuth client ID**.
2. Select **Web application** as the application type.
3. Add your app's domain to **Authorized JavaScript origins** and **Authorized redirect URIs**.
4. The web client ID is included in `firebase_options.dart` under `webClientId`.

---

## Apple Sign-In Configuration

Apple Sign-In requires setup in both the Apple Developer Portal and Firebase Console.

### Apple Developer Portal

1. Log in to [Apple Developer Portal](https://developer.apple.com/account).
2. Navigate to **Certificates, Identifiers & Profiles > Identifiers**.
3. Select your App ID (bundle ID) and enable the **Sign In with Apple** capability. Click **Save**.
4. Navigate to **Identifiers** and click **+** to register a new **Services ID**:
   - Description: e.g. `Dancee App Sign-In`
   - Identifier: e.g. `com.example.danceeApp2.signin` (this is the **Services ID**)
   - Enable **Sign In with Apple** and click **Configure**:
     - Primary App ID: select your App ID
     - Domains and Subdomains: enter your Firebase project domain (e.g. `YOUR-PROJECT.firebaseapp.com`)
     - Return URLs: enter the Firebase callback URL from the Firebase Console Apple provider setup (e.g. `https://YOUR-PROJECT.firebaseapp.com/__/auth/handler`)
   - Click **Save**, then **Continue**, then **Register**.
5. Navigate to **Keys** and click **+** to create a new key:
   - Key name: e.g. `Dancee App Sign-In Key`
   - Enable **Sign In with Apple** and click **Configure**, selecting your primary App ID.
   - Click **Save**, then **Continue**, then **Register**.
   - Download the `.p8` key file. **It can only be downloaded once.** Store it securely.
   - Note the **Key ID**.
6. Note your **Team ID** from the top-right of the Apple Developer Portal.

### Firebase Console

1. Return to **Authentication > Sign-in method > Apple** in Firebase Console.
2. Enter:
   - **Services ID**: the identifier from step 4 above (e.g. `com.example.danceeApp2.signin`)
   - **Apple Team ID**: from step 6
   - **Key ID**: from step 5
   - **Private key**: upload the `.p8` file from step 5
3. Click **Save**.

### Xcode

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the **Runner** target > **Signing & Capabilities**.
3. Click **+ Capability** and add **Sign In with Apple**.

> **Note:** The Apple Sign-In button is only shown on iOS and macOS platforms in the app (`Platform.isIOS || Platform.isMacOS`).

---

## Directus CMS Configuration

The app uses Firebase UID as the user identifier for all CMS operations (favorites, preferences). The following describes the expected Directus configuration.

### User Identity

- The app passes a Firebase ID token as a Bearer token in the `Authorization` header of Directus API requests.
- The Directus instance must be configured to accept Firebase ID tokens. This can be done via a custom Directus extension/hook that validates Firebase tokens and resolves the corresponding Directus user.
- Alternatively, a static Directus access token can be used for public/unauthenticated requests (fallback behavior already implemented in `DirectusClient`).

### Collections

No new Directus collections are required beyond the existing `favorites` collection. The existing `user_id` field in `favorites` must accept Firebase UIDs (strings).

### Access Control

Configure Directus access control rules so that:
- Authenticated requests (with valid Firebase Bearer token) can read and write the user's own favorites.
- Unauthenticated requests (with static access token) can read public data (events, courses) but not user-specific data.

### Account Deletion

When a user deletes their account, the app deletes all Directus user data (favorites, preferences) before deleting the Firebase account. Ensure the Directus API allows deletion of user records via the configured access token or Firebase token.

---

## Environment Variables and config.dart

Firebase configuration is **not** stored in `lib/config.dart`. It is generated by the FlutterFire CLI into `lib/firebase_options.dart`.

The only Firebase-related entry you may add to `lib/config.dart` is optional metadata (e.g. project ID for logging), but it is not required for authentication to work.

### config.dart entries (Directus — existing)

Copy `lib/config.example.dart` to `lib/config.dart` and fill in your values:

```dart
// lib/config.dart (gitignored — never commit)

const String directusBaseUrl = 'https://your-directus-instance.example.com';
const String directusAccessToken = 'your-access-token-here';
```

`config.dart` is listed in `.gitignore`. Use `lib/config.example.dart` as the template — it contains placeholder comments and is safe to commit.

### firebase_options.dart

Generated by `flutterfire configure`. Contains platform-specific Firebase project IDs and API keys. This file is safe to commit as it contains no secrets.

### Files that must NOT be committed (gitignored)

| File | Platform |
|---|---|
| `android/app/google-services.json` | Android |
| `ios/Runner/GoogleService-Info.plist` | iOS |
| `lib/config.dart` | All |

Verify these are in `.gitignore`:
```bash
grep -E "google-services|GoogleService-Info|config\.dart" .gitignore
```

---

## Verification

After completing all steps above, verify the setup:

1. Run the app on an Android emulator or device:
   ```bash
   flutter run
   ```

2. Attempt to register a new account with Email/Password. You should receive a verification email.

3. Attempt Google Sign-In. The Google account picker should appear.

4. On iOS, attempt Apple Sign-In. The Apple ID dialog should appear.

5. Check the Firebase Console under **Authentication > Users** — authenticated users should appear.

6. Check the Directus admin panel — favorites created by authenticated users should use the Firebase UID as `user_id`.

If any step fails, check:
- `lib/firebase_options.dart` exists and matches your Firebase project.
- `google-services.json` is in `android/app/`.
- `GoogleService-Info.plist` is in `ios/Runner/` and added to the Xcode target.
- Firebase Authentication providers are enabled in the Firebase Console.
- SHA-1 fingerprint is registered in Firebase/Google Cloud Console for Android Google Sign-In.
- Apple Sign-In capability is enabled in Xcode and the Apple Developer Portal.
