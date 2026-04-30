# Requirements Document

## Introduction

This feature spec covers the completion of the Profile Page in the dancee_app Flutter frontend. It addresses backend integration for user profile data, contact form submission, legal pages (Terms of Use, Privacy Policy) served from Directus CMS, real app version display, email notifications for contact messages, and cleanup of the unfinished Premium section. The scope spans the Flutter frontend, Directus CMS collections, and the dancee_workflow backend service.

## Glossary

- **Profile_Screen**: The main profile page widget at `lib/screens/profile/profile/profile_screen.dart` that displays user information, settings, and navigation to sub-pages
- **Profile_Card**: The `ProfileCardSection` widget that displays the user's name, email, avatar, and dance tags
- **Profile_Edit_Screen**: The screen at `lib/screens/profile/profile_edit/profile_edit_screen.dart` for editing user profile fields
- **Change_Password_Screen**: The screen at `lib/screens/profile/change_password/change_password_screen.dart` for changing the user's password
- **Contact_Form**: The `ContactFormSection` widget at `lib/screens/profile/author_contact/sections/contact_form_section.dart` for sending messages to the app author
- **Profile_Repository**: The `ProfileRepository` class at `lib/data/profile_repository.dart` that provides profile data to the UI
- **DirectusClient**: The Dio-based HTTP client at `lib/core/clients.dart` that communicates with the Directus CMS REST API
- **Auth_Cubit**: The `AuthCubit` BLoC at `lib/logic/cubits/auth_cubit.dart` that manages authentication state including current user email and UID
- **Directus_CMS**: The headless CMS (Directus) at `backend/dancee_cms/` that stores all application data including user profiles, events, and content
- **Workflow_Service**: The Restate-based backend service at `backend/dancee_workflow/` that handles API requests and business logic
- **Premium_Section**: The `PremiumBanner` widget and associated `SectionLabel` rendered on the Profile_Screen
- **Legal_Page**: A screen that displays either Terms of Use or Privacy Policy content fetched from Directus_CMS
- **Contact_Message**: A Directus collection record containing the message type, title, message body, reply email, phone number, and device info submitted via the Contact_Form

## Requirements

### Requirement 1: Display Real User Profile Data

**User Story:** As a user, I want to see my real profile information (name, email, avatar, dance tags) on the profile page, so that I can verify my account details are correct.

#### Acceptance Criteria

1. WHEN the Profile_Screen loads, THE Profile_Repository SHALL fetch the current user's profile data from Directus_CMS via the DirectusClient using the authenticated user's Directus session token
2. WHEN the user profile data is successfully fetched, THE Profile_Card SHALL display the user's real name, email, avatar URL, and dance tags from the Directus_CMS response
3. WHILE the user profile data is loading, THE Profile_Screen SHALL display a loading placeholder in the Profile_Card area
4. IF the user profile data fetch fails, THEN THE Profile_Screen SHALL display an error indicator and allow the user to retry the fetch
5. WHEN the Profile_Screen loads, THE Profile_Repository SHALL retrieve the current user's Firebase UID from Auth_Cubit to query the correct Directus user record

### Requirement 2: Edit Profile with Backend Persistence

**User Story:** As a user, I want my profile edits (name, phone, city, bio, dance preferences, experience level) to be saved to the backend, so that my changes persist across sessions.

#### Acceptance Criteria

1. WHEN the user taps the save button on the Profile_Edit_Screen, THE Profile_Edit_Screen SHALL submit the updated profile fields to Directus_CMS via the DirectusClient PATCH endpoint for the current user's record
2. WHEN the profile update request succeeds, THE Profile_Edit_Screen SHALL navigate back to the Profile_Screen and the Profile_Card SHALL reflect the updated data
3. IF the profile update request fails, THEN THE Profile_Edit_Screen SHALL display an error message to the user
4. WHILE the profile update request is in progress, THE Profile_Edit_Screen SHALL display a loading indicator and disable the save button to prevent duplicate submissions
5. WHEN the Profile_Edit_Screen loads, THE Profile_Edit_Screen SHALL fetch the current user's profile data from Directus_CMS instead of using hardcoded mock data
6. THE Profile_Edit_Screen SHALL NOT display social link fields (the profile data model and edit form shall exclude social links entirely)
7. THE Profile_Edit_Screen SHALL use minimal bottom padding below the save button so that no excessive empty space is visible beneath the save action

### Requirement 3: Change Password with Backend Integration

**User Story:** As a user, I want to change my password through the app and have it update in Firebase Auth, so that my new password takes effect immediately.

#### Acceptance Criteria

1. WHEN the user submits the change password form with valid current and new passwords, THE Change_Password_Screen SHALL reauthenticate the user with Firebase Auth using the current password and then update the password via Firebase Auth
2. WHEN the password change succeeds, THE Change_Password_Screen SHALL display a success message and navigate back to the Profile_Screen
3. IF the current password is incorrect, THEN THE Change_Password_Screen SHALL display an error message indicating invalid credentials
4. IF the new password does not meet strength requirements (minimum length, at least one uppercase letter, at least one lowercase letter, at least one digit), THEN THE Change_Password_Screen SHALL prevent submission and display validation errors (special characters are not required)
5. WHILE the password change request is in progress, THE Change_Password_Screen SHALL display a loading indicator and disable the form buttons
6. THE Change_Password_Screen SHALL NOT display a "Forgot password?" link

### Requirement 4: Terms of Use and Privacy Policy Pages

**User Story:** As a user, I want to read the Terms of Use and Privacy Policy in my preferred language, so that I understand the legal terms of using the app.

#### Acceptance Criteria

1. WHEN the user taps "Terms of Use" in the App Info section, THE Profile_Screen SHALL navigate to a Legal_Page that displays the Terms of Use content
2. WHEN the user taps "Privacy Policy" in the App Info section, THE Profile_Screen SHALL navigate to a Legal_Page that displays the Privacy Policy content
3. WHEN a Legal_Page loads, THE Legal_Page SHALL fetch the content from Directus_CMS in the user's current app language (en, cs, or es)
4. THE Directus_CMS SHALL store Terms of Use and Privacy Policy content in Markdown format in a translatable collection with translations for all three supported languages (en, cs, es), using a Directus Markdown editor interface for content authoring
5. WHILE the legal content is loading, THE Legal_Page SHALL display a loading indicator
6. IF the legal content fetch fails, THEN THE Legal_Page SHALL display an error message with a retry option
7. THE Legal_Page SHALL render the Markdown content using a Flutter Markdown rendering package (e.g., flutter_markdown) to display formatted text with headings, paragraphs, lists, bold, italic, links, and other standard Markdown elements

### Requirement 5: Real App Version Display

**User Story:** As a user, I want to see the actual app version on the profile page, so that I can reference it when reporting issues.

#### Acceptance Criteria

1. WHEN the App Info section loads, THE App_Info_Section SHALL display the real application version number and build number obtained from the platform's package info
2. THE Profile_Repository SHALL retrieve the app version using the `package_info_plus` Flutter plugin instead of returning a hardcoded string

### Requirement 6: Contact Form Improvements

**User Story:** As a user, I want the contact form to auto-fill my email and phone number and display real device info, so that I can submit support messages quickly and accurately.

#### Acceptance Criteria

1. WHEN the Contact_Form loads, THE Contact_Form SHALL auto-fill the reply email field with the current user's registration email obtained from Auth_Cubit
2. WHEN the Contact_Form loads, THE Contact_Form SHALL display the user's phone number from the user profile data fetched from Directus_CMS
3. WHEN the Contact_Form loads, THE Contact_Form SHALL display real device information (app version, device model, OS version) obtained from the platform
4. THE Profile_Repository SHALL retrieve real device information using the `package_info_plus` and `device_info_plus` Flutter plugins instead of returning hardcoded values

### Requirement 7: Contact Form Submission to CMS

**User Story:** As a user, I want my contact message to be saved in the CMS when I tap "Send message", so that the app author receives and can manage my feedback.

#### Acceptance Criteria

1. WHEN the user taps "Send message" with all required fields filled (type, title, message, reply email), THE Contact_Form SHALL submit the Contact_Message data to Directus_CMS via a POST request to the contact_messages collection
2. THE Contact_Message record SHALL include: message type (enum: bug, feature, feedback, other), title, message body, reply email, user phone number, and a device_info JSON object containing app version, device model, OS version, and the submitting user's Firebase UID
3. WHEN the submission succeeds, THE Contact_Form SHALL display a success confirmation to the user
4. IF the submission fails, THEN THE Contact_Form SHALL display an error message and allow the user to retry
5. WHILE the submission is in progress, THE Contact_Form SHALL display a loading indicator on the send button and disable the button to prevent duplicate submissions
6. IF any required field (type, title, message, reply email) is empty, THEN THE Contact_Form SHALL prevent submission and highlight the missing fields with validation errors

### Requirement 8: Email Notification for Contact Messages

**User Story:** As the app author, I want to receive an email notification when a user submits a contact message, so that I can respond to user feedback promptly.

#### Acceptance Criteria

1. WHEN a new Contact_Message record is created in Directus_CMS, THE Directus_CMS SHALL trigger a Directus Flow that sends an email notification to the configured author email address
2. THE email notification SHALL include the message type, title, message body, reply email of the sender, and the submission timestamp
3. THE Directus_CMS SHALL use the configured SMTP email transport settings for sending the notification email
4. IF the email sending fails, THEN THE Directus_CMS SHALL log the failure without affecting the Contact_Message record creation

### Requirement 9: Comment Out Dancee Premium Section

**User Story:** As a developer, I want the Dancee Premium section hidden from the profile page, so that unfinished functionality is not visible to users.

#### Acceptance Criteria

1. WHEN the Profile_Screen renders, THE Profile_Screen SHALL NOT display the Premium_Section (PremiumBanner widget and its SectionLabel)
2. THE Premium_Section code SHALL be commented out in the Profile_Screen build method rather than deleted, to preserve the implementation for future use
3. THE PremiumBanner widget file and PremiumRoute SHALL remain unchanged in the codebase

### Requirement 10: Profile Page Translation Compliance

**User Story:** As a user, I want all text on the profile page and its sub-pages to appear in my selected language, so that I can use the profile features in Czech, English, or Spanish.

#### Acceptance Criteria

1. THE Profile_Screen SHALL use slang translation keys for all user-facing strings instead of hardcoded English text
2. THE Profile_Edit_Screen SHALL use slang translation keys for all labels, placeholders, button text, and validation messages
3. THE Change_Password_Screen SHALL use slang translation keys for all labels, placeholders, button text, and validation messages
4. WHEN a new user-facing string is added to any profile-related screen, THE developer SHALL add the corresponding translation key to all three language files (strings.i18n.json, strings_cs.i18n.json, strings_es.i18n.json)
5. THE Contact_Form SHALL use slang translation keys for all labels, placeholders, button text, and validation messages
6. THE Legal_Page SHALL use slang translation keys for all static UI elements (page titles, loading text, error messages, retry button text)

