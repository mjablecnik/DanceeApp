# Requirements Document

## Introduction

This feature enables anonymous (unauthenticated) browsing of the Dancee App. Currently, the `RouterGuard` redirects all unauthenticated users to `/login`, blocking access to public content like events and courses. This feature changes the routing strategy so that anonymous users can browse event lists, course lists, and detail pages without signing in. Protected actions (saving favorites, accessing the profile) are gated behind an informational "auth gate" page that explains the need to log in and offers registration. Additionally, when a user logs in or reopens the app, the event/course filters are automatically prefilled based on their profile preferences (favorite dance styles and city/region).

The scope covers:
- Modifying the `RouterGuard` to allow anonymous access to public routes
- Creating an auth gate page shown instead of protected content for anonymous users
- Auto-prefilling filters from user profile data on login or app resume
- Adjusting the initial route from `/login` to `/events`

## Glossary

- **App**: The Dancee Flutter frontend application (`frontend/dancee_app`)
- **Router_Guard**: The GoRouter redirect function at `lib/core/router_guard.dart` that evaluates `AuthState` and redirects users based on authentication status
- **Auth_Gate_Page**: A new informational page displayed to anonymous users when they attempt to access protected content, explaining the need to log in and offering navigation to login and registration screens
- **Anonymous_User**: A user who has not signed in — the `AuthCubit` is in the `unauthenticated` state
- **Authenticated_User**: A user who has signed in via Firebase Auth — the `AuthCubit` is in the `authenticated` state with `emailVerified = true`
- **Public_Route**: A route accessible without authentication: `/events`, `/courses`, `/events/detail`, `/courses/detail`, `/events/filter-dance`, `/events/filter-location`
- **Protected_Route**: A route that requires authentication: `/saved`, `/profile` and all profile sub-routes
- **Protected_Action**: An action that requires authentication: toggling a favorite (save/unsave an event or course)
- **Filter_Cubit**: The `FilterCubit` at `lib/logic/cubits/filter_cubit.dart` that manages selected dance styles, regions, event duration types, and course types
- **Profile_Cubit**: The `ProfileCubit` at `lib/logic/cubits/profile_cubit.dart` that loads and manages the user's profile data from Directus CMS
- **User_Profile**: The `UserProfile` entity containing `danceTags` (list of dance style codes) and `city` (user's location string)
- **Auth_Cubit**: The `AuthCubit` at `lib/logic/cubits/auth_cubit.dart` that manages authentication state

## Requirements

### Requirement 1: Anonymous Access to Public Content

**User Story:** As an anonymous user, I want to browse event lists, course lists, and their detail pages without signing in, so that I can explore the app's content before deciding to create an account.

#### Acceptance Criteria

1. WHEN an anonymous user opens the App, THE Router_Guard SHALL allow navigation to `/events` without redirecting to `/login`
2. THE Router_Guard SHALL allow anonymous users to access all Public_Routes: `/events`, `/courses`, `/events/detail`, `/courses/detail`, `/events/filter-dance`, and `/events/filter-location`
3. THE App SHALL use `/events` as the initial route instead of `/login`
4. WHEN an anonymous user navigates to `/events`, THE App SHALL load and display the event list using the public Directus access token (static fallback token)
5. WHEN an anonymous user navigates to `/courses`, THE App SHALL load and display the course list using the public Directus access token
6. WHEN an anonymous user navigates to `/events/detail`, THE App SHALL load and display the event detail page
7. WHEN an anonymous user navigates to `/courses/detail`, THE App SHALL load and display the course detail page
8. THE App SHALL hide the favorite/save button (heart icon) on event and course cards and detail pages when the user is anonymous, so that the user does not encounter an error when attempting to save without authentication

### Requirement 2: Auth Gate for Protected Pages

**User Story:** As an anonymous user, I want to see an informational page explaining that I need to log in when I try to access protected content, so that I understand why the content is restricted and how to gain access.

#### Acceptance Criteria

1. WHEN an anonymous user navigates to `/saved`, THE App SHALL display the Auth_Gate_Page instead of the saved events list
2. WHEN an anonymous user navigates to `/profile` or any profile sub-route, THE App SHALL display the Auth_Gate_Page instead of the profile screen
3. THE Auth_Gate_Page SHALL display an informational message explaining that the user needs to log in to access the requested content
4. THE Auth_Gate_Page SHALL display a "Log in" button that navigates to the `/login` screen
5. THE Auth_Gate_Page SHALL display a "Create account" button or link that navigates to the `/register` screen
6. THE Auth_Gate_Page SHALL display an icon or illustration that visually communicates the authentication requirement
7. THE Auth_Gate_Page SHALL use slang translation keys for all user-facing strings
8. WHEN an authenticated user navigates to `/saved` or `/profile`, THE App SHALL display the normal saved events list or profile screen (Auth_Gate_Page is not shown)

### Requirement 3: Auth Gate for Protected Actions

**User Story:** As an anonymous user, I want to be informed that I need to log in when I attempt a protected action (like saving an event), so that I understand why the action is unavailable.

#### Acceptance Criteria

1. WHEN an anonymous user taps the favorite/save button on an event card or detail page, THE App SHALL display a dialog or bottom sheet explaining that the user needs to log in to save events
2. THE dialog or bottom sheet SHALL provide a "Log in" button that navigates to the `/login` screen
3. THE dialog or bottom sheet SHALL provide a "Create account" button or link that navigates to the `/register` screen
4. THE dialog or bottom sheet SHALL use slang translation keys for all user-facing strings
5. WHEN an authenticated user taps the favorite/save button, THE App SHALL toggle the favorite status as it does currently (no change to existing behavior)

### Requirement 4: Router Guard Update for Anonymous Browsing

**User Story:** As a developer, I want the router guard to distinguish between public and protected routes, so that anonymous users can browse public content while protected content remains gated.

#### Acceptance Criteria

1. THE Router_Guard SHALL NOT redirect anonymous users away from Public_Routes (`/events`, `/courses`, `/events/detail`, `/courses/detail`, `/events/filter-dance`, `/events/filter-location`)
2. THE Router_Guard SHALL redirect anonymous users from Protected_Routes (`/saved`, `/profile` and profile sub-routes) to display the Auth_Gate_Page
3. THE Router_Guard SHALL continue to redirect authenticated users with verified email away from auth screens (`/login`, `/register`, `/forgot-password`) to `/events`
4. THE Router_Guard SHALL continue to redirect authenticated users with unverified email to `/verify-email`
5. THE Router_Guard SHALL allow anonymous users to access auth screens (`/login`, `/register`, `/forgot-password`) without redirect
6. WHEN an anonymous user is on a Public_Route and signs in, THE Router_Guard SHALL re-evaluate and allow continued access to the current route

### Requirement 5: Auto-Prefill Filters from User Profile

**User Story:** As a logged-in user, I want the event and course filters to be automatically prefilled with my favorite dance styles and location from my profile, so that I immediately see relevant content without manually configuring filters every time.

#### Acceptance Criteria

1. WHEN a user successfully signs in (AuthState changes from unauthenticated to authenticated), THE App SHALL load the user's profile and prefill the Filter_Cubit with the user's `danceTags` as selected dance styles
2. WHEN a user successfully signs in, THE App SHALL prefill the Filter_Cubit with the user's `city` mapped to the corresponding region as the selected location filter
3. WHEN the App resumes from background and the user is authenticated, THE App SHALL check if filters are currently empty and prefill them from the user profile if no filters are actively set
4. THE App SHALL NOT overwrite manually set filters — auto-prefill SHALL only apply when the Filter_Cubit has no active filters (all selections are empty)
5. IF the user's profile has no `danceTags` (empty list), THEN THE App SHALL leave the dance style filter empty (no prefill)
6. IF the user's profile has no `city` (null or empty), THEN THE App SHALL leave the location filter empty (no prefill)
7. WHEN the user signs out, THE App SHALL clear all filters in the Filter_Cubit to reset to the default empty state

### Requirement 6: Bottom Navigation for Anonymous Users

**User Story:** As an anonymous user, I want to see the bottom navigation bar with all tabs, so that I can discover what the app offers and understand that some features require authentication.

#### Acceptance Criteria

1. THE App SHALL display the bottom navigation bar with all tabs (Events, Courses, Saved, Profile) for anonymous users
2. WHEN an anonymous user taps the "Saved" tab, THE App SHALL navigate to `/saved` and display the Auth_Gate_Page
3. WHEN an anonymous user taps the "Profile" tab, THE App SHALL navigate to `/profile` and display the Auth_Gate_Page
4. THE bottom navigation bar SHALL visually indicate the currently selected tab for anonymous users the same way it does for authenticated users

### Requirement 7: Internationalization

**User Story:** As a user, I want all new UI elements (auth gate page, dialogs) to be fully translated, so that I can use the app in my preferred language.

#### Acceptance Criteria

1. ALL user-facing strings in the Auth_Gate_Page SHALL be defined in the slang i18n translation files (en, cs, es) and accessed via the `t` global variable
2. ALL user-facing strings in the auth gate dialog/bottom sheet SHALL be defined in the slang i18n translation files (en, cs, es)
3. NO new user-facing string SHALL be hardcoded in Dart source code
4. WHEN new translation keys are added, THEY SHALL be added to all three language files: `strings.i18n.json` (en), `strings_cs.i18n.json` (cs), and `strings_es.i18n.json` (es)

### Requirement 8: Return to Original Destination After Login

**User Story:** As an anonymous user who was shown the auth gate, I want to be taken back to the content I originally tried to access after I successfully log in, so that my browsing flow is not interrupted.

#### Acceptance Criteria

1. WHEN an anonymous user is shown the Auth_Gate_Page and taps "Log in", THE App SHALL store the intended destination route (e.g., `/saved` or `/profile`)
2. WHEN the user successfully completes login from the Auth_Gate_Page flow, THE App SHALL navigate to the originally intended destination instead of the default `/events` route
3. WHEN the user successfully completes registration and email verification from the Auth_Gate_Page flow, THE App SHALL navigate to the originally intended destination
4. IF no intended destination is stored (user navigated to `/login` directly), THEN THE App SHALL navigate to `/events` after login as the default behavior
