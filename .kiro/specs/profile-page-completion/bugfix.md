# Bugfix Requirements Document

## Introduction

The `ProfileScreen` in the dancee_app Flutter frontend only renders 2 out of 7 sections defined in the HTML design mockup (`profile-page.html`). All section widgets and components already exist as separate files but are not wired into the main screen's build method. Additionally, the `SettingsSection` is missing a Notifications toggle that the design specifies, and the header is missing an edit icon button for navigating to profile edit.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN the user opens the Profile screen THEN the system only renders the Settings section (language picker) and the Danger Zone section (logout/delete), omitting 5 other sections that the design mockup specifies

1.2 WHEN the user opens the Profile screen THEN the system does not render the User Profile card (name, email, avatar, dance tags) even though `ProfileCardSection` widget exists and `UserRepository` provides the data

1.3 WHEN the user opens the Profile screen THEN the system does not render the Account section (Edit Profile, Change Password buttons) even though `AccountSection` widget exists and routes (`ProfileEditRoute`, `ChangePasswordRoute`) are defined

1.4 WHEN the user opens the Profile screen THEN the system does not render the Premium banner even though `PremiumBanner` widget exists and `PremiumRoute` is defined

1.5 WHEN the user opens the Profile screen THEN the system does not render the Support section (Contact Author, Rate App) even though `SupportSection` widget exists and `AuthorContactRoute` is defined

1.6 WHEN the user opens the Profile screen THEN the system does not render the App Info section (Version, Terms of Use, Privacy) even though `AppInfoSection` widget exists

1.7 WHEN the user opens the Profile screen THEN the Settings section only shows a Language picker and does not include a Notifications toggle as specified in the design mockup

1.8 WHEN the user opens the Profile screen THEN the header shows a plain `BackButtonHeader` with no trailing action, whereas the design mockup shows an edit icon button on the right side that navigates to profile edit

### Expected Behavior (Correct)

2.1 WHEN the user opens the Profile screen THEN the system SHALL render all 7 sections in the design-specified order: User Profile card, Account, Settings, Premium banner, Support, App Info, and Danger Zone

2.2 WHEN the user opens the Profile screen THEN the system SHALL render the `ProfileCardSection` with the current user's name, email, avatar, and dance tags fetched from `UserRepository`

2.3 WHEN the user opens the Profile screen THEN the system SHALL render the `AccountSection` with Edit Profile and Change Password buttons that navigate to `ProfileEditRoute` and `ChangePasswordRoute` respectively

2.4 WHEN the user opens the Profile screen THEN the system SHALL render the `PremiumBanner` that navigates to `PremiumRoute` when tapped

2.5 WHEN the user opens the Profile screen THEN the system SHALL render the `SupportSection` with Contact Author and Rate App items, where Contact Author navigates to `AuthorContactRoute`

2.6 WHEN the user opens the Profile screen THEN the system SHALL render the `AppInfoSection` showing app version, Terms of Use, and Privacy items

2.7 WHEN the user opens the Profile screen THEN the `SettingsSection` SHALL include both a Language picker and a Notifications toggle

2.8 WHEN the user opens the Profile screen THEN the header SHALL display an edit icon button on the right side (trailing position) that navigates to `ProfileEditRoute`

### Unchanged Behavior (Regression Prevention)

3.1 WHEN the user taps the Logout button in the Danger Zone section THEN the system SHALL CONTINUE TO show a confirmation dialog and sign out the user upon confirmation

3.2 WHEN the user taps the Delete Account button in the Danger Zone section THEN the system SHALL CONTINUE TO show a confirmation dialog, request re-authentication for email providers, and delete the account upon confirmation

3.3 WHEN the user changes the language in the Settings section THEN the system SHALL CONTINUE TO update the app locale via `SettingsCubit`

3.4 WHEN the user taps the back button in the header THEN the system SHALL CONTINUE TO navigate back via `context.pop()`

3.5 WHEN an auth error occurs during logout or account deletion THEN the system SHALL CONTINUE TO display the error banner above the Danger Zone section

3.6 WHEN a loading state is active (during logout or account deletion) THEN the system SHALL CONTINUE TO show the loading overlay and disable action buttons
