# Requirements Document

## Introduction

This feature enables authenticated users with the "Editor" role to edit existing events and courses directly from the detail page. Currently, the detail page header shows a non-functional three-dots button in the top-right corner. For Editor users, this button is replaced with a pencil (edit) icon. Clicking it opens the same form used for adding new events/courses, but pre-filled with the existing item's data. All fields are editable. Upon submission, changes are applied immediately to Directus CMS without any approval or draft workflow. After a successful update, the user sees a success message and is navigated back to the updated detail page with the latest data.

The scope covers:
- Exposing the user's Directus role to the Flutter app
- Replacing the three-dots button with an edit button for Editor users on event/course detail pages
- Reusing the existing add event/course form in edit mode with pre-filled data
- Submitting updates directly to Directus CMS via PATCH requests
- Displaying a success confirmation and navigating back to the refreshed detail page

## Glossary

- **App**: The Dancee Flutter frontend application (`frontend/dancee_app`)
- **Editor_User**: An authenticated user whose Directus role is "Editor" — this role grants permission to modify event and course items
- **Detail_Header**: The `DetailHeaderSection` widget at `lib/shared/sections/detail_header_section.dart` that renders the top bar on detail pages with a back button, title, and action area
- **Edit_Button**: A pencil icon button displayed in the Detail_Header action area for Editor_Users, replacing the current non-functional three-dots button
- **Add_Event_Screen**: The existing screen at `lib/screens/events/add_event/add_event_screen.dart` used for creating new events
- **Add_Course_Screen**: The existing screen at `lib/screens/courses/add_course/add_course_screen.dart` used for creating new courses
- **Event_Form**: The form composed of sections within Add_Event_Screen (basic info, datetime, location, organizer, styles, additional info, program, submit)
- **Course_Form**: The form composed of sections within Add_Course_Screen (basic info, description, schedule, location, instructor, details, pricing, content, image)
- **Directus_CMS**: The headless CMS backend at `backend/dancee_cms` that stores event and course data
- **Event_Entity**: The `Event` class at `lib/data/entities/event.dart` representing an event's data
- **Course_Entity**: The `Course` class at `lib/data/entities/course.dart` representing a course's data
- **Profile_Cubit**: The cubit managing user profile state, including the user's role
- **User_Profile**: The `UserProfile` entity at `lib/data/entities/user_profile.dart`

## Requirements

### Requirement 1: Editor Role Detection

**User Story:** As a developer, I want the app to know whether the current user has the Editor role, so that edit functionality can be conditionally displayed.

#### Acceptance Criteria

1. WHEN the App fetches the user profile from Directus via `/users/me`, THE App SHALL include the `role` field in the response and store it in the User_Profile entity
2. THE User_Profile entity SHALL expose a `role` property containing the Directus role identifier (UUID string)
3. THE Profile_Cubit SHALL expose a computed `isEditor` getter that returns true when the user's role matches the configured Editor role ID
4. THE App SHALL store the Editor role ID as a configuration constant in `lib/core/config.dart`
5. IF the user is not authenticated, THEN THE App SHALL treat the user as non-editor (edit button is not shown)

### Requirement 2: Edit Button on Event Detail Page

**User Story:** As an Editor user, I want to see a pencil/edit button on the event detail page, so that I can quickly navigate to edit the event.

#### Acceptance Criteria

1. WHEN an Editor_User views the event detail page, THE Detail_Header SHALL display the Edit_Button (pencil icon) in the top-right action area instead of the three-dots button
2. WHEN a non-editor authenticated user views the event detail page, THE Detail_Header SHALL display the existing three-dots button (current behavior)
3. WHEN an anonymous user views the event detail page, THE Detail_Header SHALL display the existing three-dots button (current behavior)
4. WHEN the Editor_User taps the Edit_Button on the event detail page, THE App SHALL navigate to the event edit screen with the current event's ID as a parameter

### Requirement 3: Edit Button on Course Detail Page

**User Story:** As an Editor user, I want to see a pencil/edit button on the course detail page, so that I can quickly navigate to edit the course.

#### Acceptance Criteria

1. WHEN an Editor_User views the course detail page, THE Detail_Header SHALL display the Edit_Button (pencil icon) in the top-right action area instead of the three-dots button
2. WHEN a non-editor authenticated user views the course detail page, THE Detail_Header SHALL display the existing three-dots button (current behavior)
3. WHEN an anonymous user views the course detail page, THE Detail_Header SHALL display the existing three-dots button (current behavior)
4. WHEN the Editor_User taps the Edit_Button on the course detail page, THE App SHALL navigate to the course edit screen with the current course's ID as a parameter

### Requirement 4: Event Edit Screen with Pre-filled Data

**User Story:** As an Editor user, I want the event form to open pre-filled with the existing event data, so that I can see current values and modify only what needs changing.

#### Acceptance Criteria

1. WHEN the event edit screen opens, THE Event_Form SHALL be pre-filled with all fields from the Event_Entity: title, description, start date, end date, start time, end time, venue name, venue address, venue city, organizer name, organizer email, dance styles, price range, dresscode, ticket URL, source URL, and program items
2. THE event edit screen header SHALL display a title indicating edit mode (e.g., "Edit event") instead of "Add event"
3. THE event edit screen SHALL reuse the same form sections as the Add_Event_Screen
4. ALL fields in the Event_Form SHALL be editable by the Editor_User
5. WHEN the event has an associated image, THE Event_Form SHALL display the current image in the image section (read-only, not editable)

### Requirement 5: Course Edit Screen with Pre-filled Data

**User Story:** As an Editor user, I want the course form to open pre-filled with the existing course data, so that I can see current values and modify only what needs changing.

#### Acceptance Criteria

1. WHEN the course edit screen opens, THE Course_Form SHALL be pre-filled with all fields from the Course_Entity: title, description, dance type, level, start date, end date, schedule (day and time), venue name, venue address, instructor name, instructor bio, lesson count, lesson duration, max participants, price, price note, learning items, source URL, registration URL, and image
2. THE course edit screen header SHALL display a title indicating edit mode (e.g., "Edit course") instead of "Add course"
3. THE course edit screen SHALL reuse the same form sections as the Add_Course_Screen
4. ALL fields in the Course_Form SHALL be editable by the Editor_User
5. WHEN the course has an associated image, THE Course_Form SHALL display the current image in the image section (read-only, not editable)

### Requirement 6: Direct Update Submission

**User Story:** As an Editor user, I want my changes to be applied immediately upon submission without any approval workflow, so that updates are reflected right away.

#### Acceptance Criteria

1. WHEN the Editor_User submits the event edit form, THE App SHALL send a PATCH request to the Directus CMS endpoint `/items/events/{id}` with the modified fields
2. WHEN the Editor_User submits the course edit form, THE App SHALL send a PATCH request to the Directus CMS endpoint `/items/courses/{id}` with the modified fields
3. THE App SHALL NOT require any approval, review, or draft-saving step before applying changes
4. THE submit button on the edit form SHALL display text indicating a direct update action (e.g., "Save changes") instead of "Submit for approval"
5. WHILE the update request is in progress, THE App SHALL display a loading indicator on the submit button to prevent duplicate submissions

### Requirement 7: Success Feedback and Navigation After Update

**User Story:** As an Editor user, I want to see confirmation that my changes were saved and be returned to the updated detail page, so that I can verify the changes took effect.

#### Acceptance Criteria

1. WHEN the update request completes successfully, THE App SHALL display a success message (e.g., a snackbar or toast) confirming the event/course was updated
2. WHEN the success message is shown, THE App SHALL navigate back to the detail page of the updated event/course
3. THE detail page SHALL display the latest saved data after returning from the edit screen (the page refreshes or re-fetches the item)
4. WHEN the user presses the back button from the refreshed detail page, THE App SHALL navigate to the event/course list page
5. IF the update request fails, THEN THE App SHALL display an error message and keep the user on the edit form with their entered data preserved

### Requirement 8: Routing for Edit Screens

**User Story:** As a developer, I want dedicated routes for the event and course edit screens, so that navigation is clean and supports deep linking.

#### Acceptance Criteria

1. THE App SHALL register a route for event editing at a path that includes the event ID (e.g., `/events/edit/:id`)
2. THE App SHALL register a route for course editing at a path that includes the course ID (e.g., `/courses/edit/:id`)
3. THE edit routes SHALL only be accessible to authenticated users with the Editor role
4. IF a non-editor user navigates to an edit route directly, THEN THE App SHALL redirect to the corresponding detail page

### Requirement 9: Internationalization for Edit Feature

**User Story:** As a user, I want all edit-related UI text to be fully translated, so that I can use the feature in my preferred language.

#### Acceptance Criteria

1. ALL user-facing strings in the edit screens (header title, submit button, success message, error messages) SHALL be defined in the slang i18n translation files (en, cs, es)
2. NO new user-facing string SHALL be hardcoded in Dart source code
3. WHEN new translation keys are added, THEY SHALL be added to all three language files: `strings.i18n.json` (en), `strings_cs.i18n.json` (cs), and `strings_es.i18n.json` (es)

### Requirement 10: Automatic Translation After Edit

**User Story:** As an Editor user, I want my edits to be automatically translated into the other supported languages, so that all language versions stay consistent without manual translation effort.

#### Acceptance Criteria

1. WHEN the Editor_User submits an edit in a given language (determined by the App's current locale), THE system SHALL save the changes under that language's translation in Directus
2. AFTER the translation for the edited language is saved successfully, THE system SHALL trigger an asynchronous translation process on the workflow service to translate the modified text fields into the remaining two languages (e.g., edit in cs → translate to en and es)
3. THE translation process SHALL use the existing OpenAI-based translation infrastructure in `dancee_workflow` (event-translator service)
4. THE translation process SHALL only translate text fields that were modified (title, description, program item names/descriptions, and other translatable content) — non-text fields (dates, URLs, coordinates) are not translated
5. THE App SHALL include the current language code in the update request so the backend knows which language was the source of the edit
6. IF the translation process fails for one or more target languages, THE system SHALL log the error but NOT revert the editor's original changes — the edited language remains saved
7. IF the translation process fails, THE system SHALL rely on Restate's built-in retry mechanism (exponential backoff) to automatically reattempt the translation
8. IF the translation is incomplete after retries, THE system SHALL set the item's `translation_status` field to `"partial"` in Directus so that incomplete translations are visible in the admin UI
9. THE translation process SHALL run asynchronously (fire-and-forget from the App's perspective) — the editor does not need to wait for translations to complete before seeing the success confirmation
