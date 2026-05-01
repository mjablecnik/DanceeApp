# Requirements Document

## Introduction

This feature adds profile avatar upload functionality to the Dancee App. Users can change their profile photo from the Edit Profile screen by taking a photo with the camera or selecting one from the device gallery. After selection, the user can crop and adjust the image before it is uploaded to Directus CMS via the `/files` endpoint. The uploaded file ID is then linked to the user's profile via `PATCH /users/me`. The avatar is displayed from Directus across the profile card and edit profile screens.

## Glossary

- **App**: The Dancee Flutter application (Android, iOS, Web)
- **Image_Picker**: The component responsible for presenting the user with a choice of image source (camera or gallery) and acquiring the selected image
- **Image_Cropper**: The component responsible for presenting a native crop/edit UI where the user can zoom, resize, and crop the selected image
- **Avatar_Uploader**: The component responsible for uploading the processed image file to Directus CMS and linking the returned file ID to the user's profile
- **DirectusClient**: The existing Dio-based HTTP client used for all Directus CMS REST API communication
- **ProfileRepository**: The existing data layer class that handles user profile read/write operations against Directus
- **ProfileCubit**: The existing state management class (Cubit) that orchestrates profile loading and updating
- **Directus_CMS**: The headless CMS backend (Directus) that stores user data and files, using PostgreSQL on Supabase and S3 storage on Supabase
- **ProfilePhotoSection**: The existing widget that displays the avatar circle with a camera icon overlay and "Change photo" text on the Edit Profile screen

## Requirements

### Requirement 1: Image Source Selection

**User Story:** As a user, I want to choose between taking a photo with my camera or picking one from my gallery, so that I can use any image as my profile avatar.

#### Acceptance Criteria

1. WHEN the user taps the avatar image or the "Change photo" text on the Edit Profile screen, THE Image_Picker SHALL present a bottom sheet dialog with options to take a photo using the camera or select an image from the gallery
2. WHEN the user selects the camera option, THE Image_Picker SHALL open the device camera to capture a new photo
3. WHEN the user selects the gallery option, THE Image_Picker SHALL open the device image gallery to select an existing photo
4. WHEN the user dismisses the bottom sheet without selecting an option, THE Image_Picker SHALL close the dialog and leave the current avatar unchanged
5. IF the device does not grant camera or gallery permission, THEN THE App SHALL display an informative message to the user explaining that permission is required

### Requirement 2: Image Editing

**User Story:** As a user, I want to crop and adjust my selected photo before uploading, so that I can control how my avatar looks.

#### Acceptance Criteria

1. WHEN the user has selected or captured an image, THE Image_Cropper SHALL present a crop interface allowing the user to zoom, pan, and crop the image
2. THE Image_Cropper SHALL enforce a 1:1 (square) aspect ratio for the crop area
3. WHEN the user confirms the crop, THE Image_Cropper SHALL return the cropped image data for upload
4. WHEN the user cancels the crop, THE Image_Cropper SHALL discard the selection and return the user to the Edit Profile screen with the current avatar unchanged

### Requirement 3: File Upload to Directus

**User Story:** As a user, I want my cropped avatar image to be uploaded to the CMS, so that it is stored and accessible from any device.

#### Acceptance Criteria

1. WHEN the user confirms a cropped image, THE Avatar_Uploader SHALL upload the image to Directus_CMS via a multipart/form-data POST request to the `/files` endpoint
2. THE DirectusClient SHALL support multipart file upload requests with authentication headers identical to existing JSON requests
3. WHEN the Directus_CMS returns a successful response containing a file object with an `id` field, THE Avatar_Uploader SHALL extract the file ID from the response
4. IF the file upload request fails, THEN THE Avatar_Uploader SHALL display a localized error message to the user and leave the current avatar unchanged

### Requirement 4: Link Avatar to User Profile

**User Story:** As a user, I want my uploaded avatar to be linked to my profile, so that it appears as my profile picture across the app.

#### Acceptance Criteria

1. WHEN a file ID is obtained from a successful upload, THE Avatar_Uploader SHALL send a PATCH request to `/users/me` with the body `{ "avatar": "<fileId>" }` to link the uploaded file to the user's profile
2. WHEN the PATCH request succeeds, THE ProfileCubit SHALL update its state with the new avatar URL constructed as `{directusBaseUrl}/assets/{fileId}`
3. WHEN the avatar is updated in the ProfileCubit state, THE ProfilePhotoSection SHALL immediately display the new avatar image
4. IF the PATCH request to link the avatar fails, THEN THE Avatar_Uploader SHALL display a localized error message to the user

### Requirement 5: Upload Progress Feedback

**User Story:** As a user, I want to see visual feedback while my avatar is being uploaded, so that I know the operation is in progress.

#### Acceptance Criteria

1. WHILE the avatar image is being uploaded and linked, THE ProfilePhotoSection SHALL display a loading indicator over the avatar area
2. WHILE the avatar upload is in progress, THE Image_Picker source selection and the "Change photo" text SHALL be non-interactive to prevent duplicate uploads
3. WHEN the upload and linking process completes (success or failure), THE ProfilePhotoSection SHALL remove the loading indicator and restore interactivity

### Requirement 6: Avatar Display

**User Story:** As a user, I want my avatar to be displayed consistently across the app, so that my profile picture is visible wherever my profile appears.

#### Acceptance Criteria

1. THE App SHALL construct avatar URLs using the pattern `{directusBaseUrl}/assets/{fileId}` for display
2. WHEN the user has no avatar set, THE ProfilePhotoSection SHALL display the user's initials as a fallback
3. WHEN the avatar URL fails to load (network error, missing file), THE ProfilePhotoSection SHALL display the initials fallback instead of a broken image

### Requirement 7: Localization

**User Story:** As a user, I want all avatar-related UI text to appear in my selected language, so that the experience is consistent with the rest of the app.

#### Acceptance Criteria

1. THE App SHALL provide translations for all avatar upload UI strings (source selection options, error messages, permission messages) in English, Czech, and Spanish
2. THE App SHALL use the slang_flutter localization system for all avatar-related user-facing strings
3. THE App SHALL NOT contain any hardcoded user-facing strings related to avatar upload functionality

### Requirement 8: Cross-Platform Compatibility

**User Story:** As a user, I want the avatar upload to work on Android, iOS, and Web, so that I can change my profile photo from any device.

#### Acceptance Criteria

1. THE Image_Picker SHALL function on Android, iOS, and Web platforms, using platform-appropriate APIs for camera and gallery access
2. THE Image_Cropper SHALL function on Android, iOS, and Web platforms, providing a consistent crop experience across all platforms
3. ON Web, IF the camera option is not available, THEN THE Image_Picker SHALL only show the gallery option in the source selection dialog
4. THE file upload and avatar linking logic SHALL work identically across all three platforms without platform-specific code paths

### Requirement 9: Design Consistency

**User Story:** As a user, I want the avatar upload flow to look and feel like the rest of the app, so that the experience is seamless.

#### Acceptance Criteria

1. THE source selection bottom sheet SHALL use the app's existing dark theme colors (appBg, appSurface, appBorder, appText, appMuted, appPrimary) and typography (AppTypography) consistent with other bottom sheets and dialogs in the app
2. THE Image_Cropper theme SHALL use dark background colors and primary accent color matching the app's design system
3. THE loading indicator displayed during upload SHALL use the same CircularProgressIndicator style and appPrimary color used elsewhere in the app
4. THE error messages SHALL be displayed using the same error banner/snackbar pattern used in other profile screens
